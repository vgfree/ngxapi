local gosay = require('gosay')
local cjson = require('cjson')
local MSG = require('MSG')
local MC_utils = require('MC_utils')
local only = require('only')
local sys = require('sys')

local function handle()
	MC_utils.token_check()

	local body = ngx.req.get_body_data()
	local res = cjson.decode(body)
	if not res then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end
	local nas_uuid = res["nas_uuid"]
	if not nas_uuid then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end
	local identity = res["identity"]
	if not identity then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end
	local verification_code = res["verification_code"]
	if not verification_code then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end
	local cached_verification_code = MC_utils.get_with_expire(identity .. "_" .. nas_uuid)
	if not cached_verification_code then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_VERIFICATION_CODE_EXPIRED"))
		return
	end
	if verification_code ~= cached_verification_code then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_VERIFICATION_CODE_WRONG"))
		return
	end

	local dev = string.format("%s--%s", identity, nas_uuid)
	-->>创建user
	local cmd = string.format("/usr/local/bin/headscale user create '%s'", dev)
	local ok, errmsg = sys.execute(cmd)
	if not ok then
		only.log('E', '%s', errmsg)
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	local cmd = string.format("/usr/local/bin/headscale preauthkeys create -e 100y --reusable -u '%s' 2>/dev/null", dev)
	local ok, authkey = sys.execute(cmd)
	if not ok then
		only.log('E', '%s', authkey)
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end

	local info = {}
	info["scale_token"] = authkey:sub(1, -2)
	info["identity"] = identity

	local msg = cjson.encode(info)
	gosay.out_message(MSG.fmt_api_message(msg))
end

MC_utils.main_call(handle)
