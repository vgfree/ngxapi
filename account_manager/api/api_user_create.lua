local sys = require('sys')
local gosay = require('gosay')
local mysql_api = require('mysql_pool_api')
local MSG = require('MSG')

local APP_KEY_LIST = {
	ownstor_web = "alkIIllmsdk",
}

local sql_fmt = {
	user_info = "SELECT * FROM user_list WHERE username='%s'",
	user_add = "INSERT INTO user_list (username, password, scale_token) VALUES ('%s', '%s', '%s')",
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
	local password = args["password"]

	local sql = string.format(sql_fmt["user_info"], username)
	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'SELECT', sql)
	if not ok then
		only.log('E','select mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	if #res ~= 0 then
		only.log('E','mysql username %s is exist!', username)
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_USER_EXIST"))
		return
	end

	local cmd = string.format(
		[[/usr/sbin/useradd -m -d /home/guest%s guest%s 2>&1 && /bin/chown -R guest%s:guest%s /home/guest%s 2>&1]],
		username, username, username, username, username)
	local ok, errmsg = sys.execute(cmd)
	if not ok then
		only.log('E', '%s', errmsg)
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_USER_EXIST"))
	else
		local cmd = string.format([[/bin/echo 'guest%s:%s'|/usr/sbin/chpasswd 2>&1]], username, password)
		local ok, errmsg = sys.execute(cmd)
		if not ok then
			local cmd = string.format([[/usr/sbin/userdel -r guest%s]], username)
			sys.execute(cmd)
			only.log('E', 'password %s is invalid!', password)
			gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		else
			local cmd = string.format([[/usr/sbin/usermod -s /sbin/nologin guest%s]], username)
			sys.execute(cmd)

			local sql = string.format(sql_fmt["user_add"], username, password, "1111")
			local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'INSERT', sql)
			if not ok then
				only.log('E','insert mysql failed!')
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
				return
			end
			gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
		end
	end
end

ngx.header["Content-Type"] = "application/json"
handle()


