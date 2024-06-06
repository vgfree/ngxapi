local gosay = require('gosay')
local mysql_api = require('mysql_pool_api')
local cjson = require('cjson')
local MSG = require('MSG')

local sql_fmt = {
	user_list = "SELECT * FROM user_list",
}

local function handle()
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

ngx.header["Content-Type"] = "application/json"
handle()
