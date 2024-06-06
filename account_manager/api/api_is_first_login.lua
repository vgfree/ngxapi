local mysql_api = require('mysql_pool_api')
local gosay = require('gosay')
local MSG = require('MSG')

local sql_fmt = {
	one_user = "SELECT * FROM user_list LIMIT 1",
}

local function handle()
	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'SELECT', sql_fmt["one_user"])
	if not ok then
		only.log('E','select mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	if #res ~= 0 then
		gosay.out_message(MSG.fmt_api_message([[{"isFirstLogin":false}]]))
	else
		gosay.out_message(MSG.fmt_api_message([[{"isFirstLogin":true}]]))
	end
end

ngx.header["Content-Type"] = "application/json"
handle()
