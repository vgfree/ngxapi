local gosay = require('gosay')
local cjson = require('cjson')
local MSG = require('MSG')
local FM_utils = require('FM_utils')
local only = require('only')


local function parse_range_header(range, file_size)
	-- 解析 Range 头部 (支持多个范围)
	local ranges = {}
	for start_byte, end_byte in range:gmatch("bytes=(%d+)-(%d+)") do
		start_byte = tonumber(start_byte)
		end_byte = tonumber(end_byte)

		-- 如果请求的范围超出了文件大小
		if end_byte > file_size - 1 then
			end_byte = file_size - 1
		end

		-- 如果 start_byte 大于 end_byte，跳过此范围
		if start_byte <= end_byte then
			table.insert(ranges, {start = start_byte, ["end"] = end_byte})
		end
	end

	return ranges
end

local function send_file_part(file_path, start_byte, end_byte, file_size)
	-- 打开文件
	local file, err = io.open(file_path, "rb")
	if not file then
		ngx.log(ngx.ERR, "Failed to open file: ", err)
		ngx.status = 404
		ngx.say("File not found")
		return ngx.exit(404)
	end

	-- 跳转到起始字节
	local success, err = file:seek("set", start_byte)
	if not success then
		ngx.log(ngx.ERR, "Failed to seek to byte position: ", err)
		file:close()
		ngx.status = 500
		ngx.say("Failed to seek to the byte position")
		return ngx.exit(500)
	end

	-- 计算文件部分大小
	local chunk_size = end_byte - start_byte + 1

	-- 读取指定大小的数据
	local chunk = file:read(chunk_size)
	if not chunk then
		ngx.log(ngx.ERR, "Failed to read file chunk")
		file:close()
		ngx.status = 500
		ngx.say("Failed to read the requested file chunk")
		return ngx.exit(500)
	end

	-- 设置响应头
	ngx.status = 206  -- Partial Content
	ngx.header["Content-Range"] = string.format("bytes %d-%d/%d", start_byte, end_byte, file_size)
	ngx.header["Content-Length"] = #chunk
	ngx.header["Content-Type"] = "application/octet-stream"

	-- 将文件内容返回给客户端
	ngx.print(chunk)

	-- 关闭文件
	file:close()
end

local function handle_multiple_ranges(file_path, ranges, file_size)
	-- 如果有多个范围请求，则分别发送每个范围的数据
	for _, range in ipairs(ranges) do
		send_file_part(file_path, range.start, range["end"], file_size)
	end
end


local function handle()
	local result = FM_utils.token_check()

	local username = result["username"]
	local body = ngx.req.get_body_data()
	local res = cjson.decode(body)
	if not res then
		gosay.out_status(400)
		return
	end

	local path = res["path"]
	local ok = FM_utils.is_normalize_path(path)
	if not ok then
		gosay.out_status(400)
		return
	end

	local full_path = string.format("/nfs/guest_%s/%s", username, path)

	local file = io.open(full_path, "rb")
	if not file then
		-- 如果文件不存在，返回 404
		only.log('E', 'open %s failed!', full_path)
		ngx.status = 404
		ngx.say("File not found")
		return ngx.exit(404)
	end

	-- 获取文件的总大小
	local file_size = file:seek("end")
	file:close()

	-- 获取 Range 头部
	local range = ngx.var.http_range

	if range then
		-- 解析 Range 头部（支持多个范围请求）
		local ranges = parse_range_header(range, file_size)

		if #ranges > 0 then
			ngx.status = 206  -- Partial Content
			ngx.header["Content-Type"] = "application/octet-stream"

			-- 合并多个范围请求
			handle_multiple_ranges(full_path, ranges, file_size)
		else
			ngx.status = 416
			ngx.header["Content-Range"] = "bytes */" .. file_size
			ngx.say("Requested Range Not Satisfiable")
			return ngx.exit(416)
		end
	else
		-- 如果没有 Range 头部，返回整个文件
		local file, err = io.open(full_path, "rb")
		if not file then
			only.log('E', 'open %s failed:%s', full_path, err)
			ngx.status = 404
			ngx.say("File not found")
			return ngx.exit(404)
		end

		ngx.status = 200
		ngx.header["Content-Length"] = file_size
		ngx.header["Content-Type"] = FM_utils.get_file_mime_type(full_path)

		-- 读取并返回整个文件
		local chunk
		while true do
			chunk = file:read(4096)
			if not chunk then
				break
			end
			ngx.print(chunk)
		end

		file:close()
	end

end

FM_utils.main_call(handle)
