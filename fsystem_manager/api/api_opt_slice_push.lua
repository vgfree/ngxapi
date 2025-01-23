local gosay = require('gosay')
local MSG = require('MSG')
local FM_utils = require('FM_utils')
local only = require('only')
local lfs = require('lfs')
local sys = require('sys')
local upload = require("resty.upload")

local function handle()
	local result = FM_utils.token_check()

	local username = result["username"]

	local form, err = upload:new(4096)	-- 每次读取 4KB
	if not form then
		only.log('E', "failed to create upload form: %s", err)
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end

	local full_path = string.format("/nfs/guest_%s/.UPLOAD_CACHE/", username)
	local finfo = {}
	local field = nil
	while true do
		local typ, res, err = form:read()

		if not typ then
			only.log('E', "failed to read form data: %s", err)
			gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
			return
		end

		if typ == "header" then
			local key, value = res[1], res[2]
			if key == "Content-Disposition" then
				-- 提取字段名称
				local name = value:match('name="(.-)"')
				if name then
					field = name
				else
					field = nil
				end
			end
		elseif typ == "body" then
			if field then
				if not finfo[field] then
					finfo[field] = res
				else
					finfo[field] = finfo[field] .. res
				end
			end
		elseif typ == "part_end" then
			field = nil
		elseif typ == "eof" then
			if not finfo["chunkIndex"] then
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
				return
			end
			if not finfo["totalChunks"] then
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
				return
			end
			if not finfo["UUID"] then
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
				return
			end
			if not finfo["file"] then
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
				return
			end
			local file_path = finfo["UUID"]
			local ok = FM_utils.is_normalize_path(file_path)
			if not ok then
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_INVALID"))
				return
			end
			local ok, err_msg = lfs.mkdir(full_path)
			if not ok then
				if err_msg ~= "File exists" then
					only.log('E', 'mkdir (%s) failed:%s', full_path, err_msg)
					gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
					return
				end
			end
			full_path = full_path .. file_path .. "_part_" .. finfo["chunkIndex"]
			--[[
			local attr = lfs.attributes(full_path)
			if attr then
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_EXISTS"))
				return
			end
			]]--
			-- 写文件内容
			local file = io.open(full_path, "wb")
			if file then
				file:write(finfo["file"])
				file:close()
			else
				only.log('E', 'open %s failed!', full_path)
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
				return
			end
			only.log('D', "Upload one slice complete!")
			break
		end
	end


	gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
	return
end

FM_utils.main_call(handle)

