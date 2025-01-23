local gosay = require('gosay')
local cjson = require('cjson')
local MSG = require('MSG')
local FM_utils = require('FM_utils')
local only = require('only')
local lfs = require('lfs')
local sys = require('sys')

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
	local uuid = res["UUID"]
	local chunks = res["totalChunks"]
	if not path or not uuid or not chunks then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end
	local ok = FM_utils.is_normalize_path(path)
	if not ok then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_INVALID"))
		return
	end
	local ok = FM_utils.is_normalize_path(uuid)
	if not ok then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_INVALID"))
		return
	end

	local dst_full_path = string.format("/nfs/guest_%s/%s", username, path)
	local src_full_path = string.format("/nfs/guest_%s/.UPLOAD_CACHE/%s_part_", username, uuid)
	local final_file = io.open(dst_full_path, "wb")
	if not final_file then
		only.log('E', 'open %s failed!', dst_full_path)
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_INVALID"))
		return
	end

	for i = 1, chunks do
		local part_path = src_full_path .. i
		local part_file = io.open(part_path, "rb")
		if part_file then
			final_file:write(part_file:read("*all"))
			part_file:close()
			os.remove(part_path)
		else
			final_file:close()
			only.log('E', 'open %s failed!', part_path)
			gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_NOT_EXISTS"))
			return
		end
	end
	final_file:close()

	gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
	return
end

FM_utils.main_call(handle)

