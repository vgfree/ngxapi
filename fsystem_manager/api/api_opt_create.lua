local gosay = require('gosay')
local cjson = require('cjson')
local MSG = require('MSG')
local FM_utils = require('FM_utils')
local only = require('only')
local lfs = require('lfs')

local function handle()
	local result = FM_utils.token_check()

	local username = result["username"]
	local body = ngx.req.get_body_data()
	local res = cjson.decode(body)
	if not res then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end

	local path = res["path"]
	local is_dir = res["isDir"]
	local ok = FM_utils.is_normalize_path(path)
	if not ok then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_INVALID"))
		return
	end

	local full_path = string.format("/nfs/guest_%s/%s", username, path)
	local attr = lfs.attributes(full_path)
	if attr then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_EXISTS"))
		return
	end
	if is_dir then
		local ok, err_msg = lfs.mkdir(full_path)
		if not ok then
			if err_msg == "File exists" then
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_EXISTS"))
				return
			end

			only.log('E', 'mkdir (%s) failed:%s', full_path, err_msg)
			gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
			return
		end
	else
		local file = io.open(full_path, "w")  -- "w" 模式会清空文件
		if file then
			file:close()  -- 关闭文件
		else
			only.log('E', 'touch (%s) failed!', full_path)
			gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
			return
		end
	end

	gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
	return
end

FM_utils.main_call(handle)
