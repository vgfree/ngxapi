local gosay = require('gosay')
local mysql_api = require('mysql_pool_api')
local cjson = require('cjson')
local MSG = require('MSG')
local only = require('only')
local AM_utils = require('AM_utils')

local sql_fmt = {
	user_list = "SELECT username, save_time FROM user_list WHERE accepted=0",
}

local function handle()
	AM_utils.token_check()

	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'SELECT', sql_fmt["user_list"])
	if not ok then
		only.log('E','select mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	if #res ~= 0 then
		local msg = cjson.encode(res)
		gosay.out_message(MSG.fmt_api_message(msg))
	else
		gosay.out_message(MSG.fmt_api_message("[]"))
	end
end

AM_utils.main_call(handle)
