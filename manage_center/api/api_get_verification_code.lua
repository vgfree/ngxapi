local gosay = require('gosay')
local cjson = require('cjson')
local MSG = require('MSG')
local MC_utils = require('MC_utils')
local only = require('only')

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

	-->>TODO:send sms
	local verification_code = "666666"

	MC_utils.set_with_expire(identity .. "_" .. nas_uuid, verification_code, 60)
	gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
end

MC_utils.main_call(handle)
