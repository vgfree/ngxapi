local cjson = require("cjson")
local gosay = require('gosay')
local mysql_api = require('mysql_pool_api')
local MSG = require('MSG')
local AM_utils = require('AM_utils')
local only = require('only')

local APP_KEY_LIST = {
	ownstor_web = "alkIIllmsdk",
}

local sql_fmt = {
	user_del = "DELETE FROM user_list WHERE username='%s'",
	user_list = "SELECT username, password FROM user_list",
}

local function check_args(args)
	--if not args['appKey'] or args['appKey'] == "" or not APP_KEY_LIST[args['appKey']] then
	--	gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
	--	return
	--end
end

local function handle()
	AM_utils.token_check()

	local args = ngx.req.get_uri_args()

	-->> 1)检查参数
	check_args(args)

	local body = ngx.req.get_body_data()
	local res = cjson.decode(body)
	if not res then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end
	local username = res["username"]
	if not username then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end

	-->> 获取用户列表
	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'SELECT', sql_fmt["user_list"])
	if not ok then
		only.log('E','select mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end

	local list = {}
	for _, sub in ipairs(res) do
		list[sub["username"]] = sub["password"]
	end
	list[username] = nil

	-->> 配置vsftp
	ok = AM_utils.config_vsftp(list)
	if not ok then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	-->> 配置samba
	ok = AM_utils.config_samba(list)
	if not ok then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	ok = AM_utils.config_samba_del(username)
	if not ok then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end

	-->> 删除用户
	local sql = string.format(sql_fmt["user_del"], username)
	only.log('I','sql:%s', sql)
	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'DELETE', sql)
	if not ok then
		only.log('E','delete mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end

	local cmd = string.format([[/usr/sbin/userdel -r guest_%s]], username)
	os.execute(cmd)


	gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
end

AM_utils.main_call(handle)
