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

	local src_path = res["src_path"]
	local dst_path = res["dst_path"]
	local ok = FM_utils.is_normalize_path(src_path)
	if not ok then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_INVALID"))
		return
	end
	local ok = FM_utils.is_normalize_path(dst_path)
	if not ok then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_INVALID"))
		return
	end
	local src_full_path = string.format("/nfs/guest_%s/%s", username, src_path)
	local dst_full_path = string.format("/nfs/guest_%s/%s", username, dst_path)

	local info, err = lfs.attributes(src_full_path)
	if not info then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_NOT_EXISTS"))
		return
	end
	local info, err = lfs.attributes(dst_full_path)
	if info then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_EXISTS"))
		return
	end

	local ok, err = os.rename(src_full_path, dst_full_path)
	if not ok then
		local cmd = string.format([[/usr/bin/mv '%s' '%s' 2>&1]], src_full_path:gsub("'", "''"), dst_full_path:gsub("'", "''"))
		local ok, err = sys.execute(cmd)
		if not ok then
			only.log('E','mv %s %s:%s', src_full_path, dst_full_path, err or "")
			gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
			return
		end
	end

	gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
	return
end

FM_utils.main_call(handle)
