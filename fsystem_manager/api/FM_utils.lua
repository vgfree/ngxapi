local string = require("string")
local only = require('only')
local jwt = require("resty.jwt")
local os = require("os")
local gosay = require('gosay')
local MSG = require('MSG')
local lfs = require("lfs")

------> only use for handle
local function main_call(F, ...)
	ngx.header["Content-Type"] = "application/json"
	local info = { pcall(F, ...) }
	if not info[1] then
		only.log("E", info[2])
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
	end
end

local function user_sign(username, password)
	local secret = "ownstor"
	local expiration_time = os.time() + 1800	--秒

	local jwt_obj = {
		header = {
			typ = "JWT",
			alg = "HS256"
		},
		payload = {
			exp = expiration_time,
			username = username,
			password = password
		}
	}

	local jwt_token = jwt:sign(secret, jwt_obj)
	return jwt_token
end

local function user_verify(jwt_token)
	local secret = "ownstor"

	local jwt_obj = jwt:verify(secret, jwt_token)
	if not jwt_obj["verified"] then
		only.log('E','token:%s!', jwt_obj["reason"])
		return nil
	end
	return {username = jwt_obj["payload"]["username"], password = jwt_obj["payload"]["password"]}
end

local function token_check()
	local headers = ngx.req.get_headers()
	local authorization_header = headers["Authorization"]
	if not authorization_header then
		gosay.out_status(401)
	end
	local token = string.match(authorization_header, "Bearer (.+)$")
	local result = user_verify(token)
	if not result then
		gosay.out_status(401)
	end
	return result
end

-- 简单路径规范化函数：移除冗余的路径元素
local function is_normalize_path(path)
	if path:match("^/") or path:match("^%./") or path:match("^%.%./") then
		return false
	end
	-- 移除多余的路径分隔符，例如 "///" => "/"
	local path = path:gsub("//+", "/")

	-- 路径部分拆分
	local parts = {}
	for part in path:gmatch("[^/]+") do
		table.insert(parts, part)
	end

	local result = {}
	local current_directory_level = 0

	for _, part in ipairs(parts) do
		if part == ".." then
			if current_directory_level > 0 then
				current_directory_level = current_directory_level - 1
			else
				-- 如果已经在根目录，无法跳到父级，说明跳出了当前目录
				return false
			end
		elseif part ~= "." then
			table.insert(result, part)
			current_directory_level = current_directory_level + 1
		end
	end

	return true
end

-- 迭代删除目录及其内容
local function remove_path(path)
	-- 获取路径的属性
	local attr = lfs.attributes(path)
	if not attr then
		only.log('E', 'path:%s get attr failed!', path)
		return false
	end

	-- 如果是文件，直接删除
	if attr.mode ~= "directory" then
		local ok, err = os.remove(path)
		if not ok then
			only.log('E', 'path:%s remove failed:%s', path, err)
		end
		return ok
	end

	-- 如果是目录，使用栈遍历删除
	local stack = {path}  -- 使用栈存储需要删除的目录路径
	local directories_to_delete = {}

	while #stack > 0 do
		local current_path = table.remove(stack)  -- 获取栈顶路径
		local has_subdirectories = false  -- 标记是否有子目录

		for file in lfs.dir(current_path) do
			if file ~= "." and file ~= ".." then
				local file_path = current_path .. "/" .. file
				local attr = lfs.attributes(file_path)
				if not attr then
					only.log('E', 'path:%s get attr failed!', file_path)
					return false
				else
					if attr.mode == "directory" then
						-- 如果是子目录，加入栈中等待删除
						table.insert(stack, file_path)
						has_subdirectories = true
					else
						-- 如果是文件，删除文件
						local ok, err = os.remove(file_path)
						if not ok then
							only.log('E', 'path:%s remove failed:%s', file_path, err)
							return false
						end
					end
				end
			end
		end

		-- 删除空目录
		if has_subdirectories then
			table.insert(directories_to_delete, current_path)
		else
			local ok, err = lfs.rmdir(current_path)
			if not ok then
				only.log('E', 'path:%s remove failed:%s', current_path, err)
				return false
			end
		end
	end

	-- 对字符串数组进行排序
	table.sort(directories_to_delete, function(str1, str2)
		return #str1 > #str2  -- 如果 str1 的长度小于 str2 的长度，则返回 true
	end)

	-- 删除所有空目录
	for _, dir in ipairs(directories_to_delete) do
		local ok, err = lfs.rmdir(dir)
		if not ok then
			only.log('E', 'path:%s remove failed:%s', dir, err)
			return false
		end
	end

	return true
end

-- 迭代删除目录内容
local function clear_path(path)
	-- 获取路径的属性
	local attr = lfs.attributes(path)
	if not attr then
		only.log('E', 'path:%s get attr failed!', path)
		return false
	end

	-- 如果是文件，直接删除
	if attr.mode ~= "directory" then
		local file = io.open(path, "w")  -- "w" 模式会清空文件
		if file then
			file:close()  -- 关闭文件
			return true
		else
			only.log('E', 'path:%s clear failed!', path)
			return false
		end
	end

	-- 如果是目录，使用栈遍历删除
	local stack = {path}  -- 使用栈存储需要删除的目录路径
	local directories_to_delete = {}

	while #stack > 0 do
		local current_path = table.remove(stack)  -- 获取栈顶路径
		local has_subdirectories = false  -- 标记是否有子目录

		for file in lfs.dir(current_path) do
			if file ~= "." and file ~= ".." then
				local file_path = current_path .. "/" .. file
				local attr = lfs.attributes(file_path)
				if not attr then
					only.log('E', 'path:%s get attr failed!', file_path)
					return false
				else
					if attr.mode == "directory" then
						-- 如果是子目录，加入栈中等待删除
						table.insert(stack, file_path)
						has_subdirectories = true
					else
						-- 如果是文件，删除文件
						local ok, err = os.remove(file_path)
						if not ok then
							only.log('E', 'path:%s remove failed:%s', file_path, err)
							return false
						end
					end
				end
			end
		end

		-- 删除空目录
		if current_path ~= path then
			if has_subdirectories then
				table.insert(directories_to_delete, current_path)
			else
				local ok, err = lfs.rmdir(current_path)
				if not ok then
					only.log('E', 'path:%s remove failed:%s', current_path, err)
					return false
				end
			end
		end
	end

	-- 对字符串数组进行排序
	table.sort(directories_to_delete, function(str1, str2)
		return #str1 > #str2  -- 如果 str1 的长度小于 str2 的长度，则返回 true
	end)

	-- 删除所有空目录
	for _, dir in ipairs(directories_to_delete) do
		local ok, err = lfs.rmdir(dir)
		if not ok then
			only.log('E', 'path:%s remove failed:%s', dir, err)
			return false
		end
	end

	return true
end

local function get_file_mime_type(file_path)
	-- 通过文件扩展名判断 MIME 类型
	local ext = file_path:match(".+%.(.+)$")
	if ext then
		ext = ext:lower()
		if ext == "jpg" or ext == "jpeg" then
			return "image/jpeg"
		elseif ext == "png" then
			return "image/png"
		elseif ext == "gif" then
			return "image/gif"
		elseif ext == "pdf" then
			return "application/pdf"
		elseif ext == "txt" then
			return "text/plain"
		elseif ext == "mp4" then
			return "video/mp4"
		else
			return "application/octet-stream"
		end
	end
	return "application/octet-stream"
end

return {
	main_call = main_call,
	user_sign = user_sign,
	token_check = token_check,
	is_normalize_path = is_normalize_path,
	remove_path = remove_path,
	clear_path = clear_path,
	get_file_mime_type = get_file_mime_type,
}
