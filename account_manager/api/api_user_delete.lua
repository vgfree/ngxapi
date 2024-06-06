local sys = require('sys')
local gosay = require('gosay')
local mysql_api = require('mysql_pool_api')
local MSG = require('MSG')

local APP_KEY_LIST = {
	ownstor_web = "alkIIllmsdk",
}

local sql_fmt = {
	user_del = "DELETE FROM user_list WHERE username='%s'",
}

local function check_args(args)
	--if not args['appKey'] or args['appKey'] == "" or not APP_KEY_LIST[args['appKey']] then
	--	gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
	--	return
	--end
end

local function handle()
	local args = ngx.req.get_uri_args()

	-->> 1)检查参数
	check_args(args)

	local username = args["username"]

	local sql = string.format(sql_fmt["user_del"], username)
	only.log('I','sql:%s', sql)
	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'DELETE', sql)
	if not ok then
		only.log('E','delete mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end

	local cmd = string.format([[/usr/sbin/userdel -r guest%s]], username)
	sys.execute(cmd)
	gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
end

ngx.header["Content-Type"] = "application/json"
handle()


