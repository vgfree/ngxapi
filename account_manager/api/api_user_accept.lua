local sys = require('sys')
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
	user_info = "SELECT password, accepted FROM user_list WHERE username='%s'",
	user_update = "UPDATE user_list SET accepted=1 WHERE username='%s'",
	user_list = "SELECT username, password FROM user_list WHERE accepted=1",
	disk_list = "SELECT * FROM disk_list",
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


	local sql = string.format(sql_fmt["user_info"], username)
	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'SELECT', sql)
	if not ok then
		only.log('E','select mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	if #res == 0 then
		only.log('E','mysql username %s is not exist!', username)
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_USER_NOT_EXIST"))
		return
	end
	local password = res[1]["password"]
	local accepted = res[1]["accepted"]
	if tonumber(accepted) == 1 then
		only.log('W','username %s is already accepted!', username)
		gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
		return
	end

	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'SELECT', sql_fmt["disk_list"])
	if not ok then
		only.log('E','select mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	if #res == 0 then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_DISK_POOL_EMPTY"))
		return
	end
	for _, one in ipairs(res) do
		local cmd = string.format([[/usr/sbin/blkid | grep -q 'UUID="%s"']], one["uuid"])
		local ok = sys.execute(cmd)
		if not ok then
			gosay.out_message(MSG.fmt_err_message("MSG_ERROR_DISK_POOL_INACTIVE"))
			return
		end
	end

	local cmd = string.format(
		[[/usr/sbin/useradd -m -d /nfs/guest_%s guest_%s 2>&1 && /usr/bin/chown -R guest_%s:guest_%s /nfs/guest_%s 2>&1]],
		username, username, username, username, username)
	local ok, errmsg = sys.execute(cmd)
	if not ok then
		only.log('E', '%s', errmsg)
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_USER_EXIST"))
	else
		local cmd = string.format([[/usr/bin/echo 'guest_%s:%s'|/usr/sbin/chpasswd 2>&1]], username, password)
		local ok, errmsg = sys.execute(cmd)
		if not ok then
			local cmd = string.format([[/usr/sbin/userdel -r guest_%s]], username)
			os.execute(cmd)
			only.log('E', 'password %s is invalid!', password)
			gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		else
			local cmd = string.format([[/usr/sbin/usermod -s /sbin/nologin guest_%s]], username)
			sys.execute(cmd)

			-->> 配置vsftp
			local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'SELECT', sql_fmt["user_list"])
			if not ok then
				only.log('E','select mysql failed!')
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
				return
			end

			local list = {}
			list[username] = password
			for _, sub in ipairs(res) do
				list[sub["username"]] = sub["password"]
			end

			ok = AM_utils.config_vsftp(list)
			if not ok then
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
				return
			end
			-->> 配置samba
			ok = AM_utils.config_samba_add(username, password)
			if not ok then
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
				return
			end
			ok = AM_utils.config_samba(list)
			if not ok then
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
				return
			end

			local sql = string.format(sql_fmt["user_update"], username)
			local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'UPDATE', sql)
			if not ok then
				only.log('E','update mysql failed!')
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
				return
			end

			gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
			return
		end
	end
end

AM_utils.main_call(handle)
