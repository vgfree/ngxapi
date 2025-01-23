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
	local ok = FM_utils.is_normalize_path(path)
	if not ok then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_INVALID"))
		return
	end
	local full_path = string.format("/nfs/guest_%s/%s", username, path)

	local info, err = lfs.attributes(full_path)
	if not info then
		gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
		return
	end

	local ok = FM_utils.clear_path(full_path)
	if not ok then
		only.log('E', 'remove %s failed!', full_path)
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end

	gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
	return
end

FM_utils.main_call(handle)
