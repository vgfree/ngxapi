local string = require("string")
local only = require('only')
local jwt = require("resty.jwt")
local os = require("os")
local gosay = require('gosay')
local MSG = require('MSG')

------> only use for handle
local function main_call(F, ...)
	ngx.header["Content-Type"] = "application/json"
	local info = { pcall(F, ...) }
	if not info[1] then
		only.log("E", info[2])
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
	end
end

local function admin_sign()
	local shared_dict = ngx.shared.storehouse
	local secret = shared_dict:get("am-secret")
	local expiration_time = os.time() + 3600	--秒

	local jwt_obj = {
		header = {
			typ = "JWT",
			alg = "HS256"
		},
		payload = {
			exp = expiration_time
		}
	}

	local jwt_token = jwt:sign(secret, jwt_obj)
	return jwt_token
end

local function admin_verify(jwt_token)
	local shared_dict = ngx.shared.storehouse
	local secret = shared_dict:get("am-secret")

	local jwt_obj = jwt:verify(secret, jwt_token)
	if not jwt_obj["verified"] then
		only.log('E','token:%s!', jwt_obj["reason"])
		return false
	end
	return true
end

local function token_check()
	local headers = ngx.req.get_headers()
	local authorization_header = headers["Authorization"]
	if not authorization_header then
		gosay.out_status(401)
	end
	local token = string.match(authorization_header, "Bearer (.+)$")
	if not admin_verify(token) then
		gosay.out_status(401)
	end
end

local function config_vsftp(list)
	-->> 清空写
	local msg = 'homeshare\n123456\n'
	for username, password in pairs(list) do
		msg = msg .. username .. "\n" .. password .. "\n"
	end

	local file = io.open("/tmp/vuser_passwd.conf", "w")
	if not file then
		only.log('E', 'open vuser_passwd.conf failed!')
		return false
	end
	file:write(msg)
	file:close()

	os.execute("/usr/bin/rm -f /opt/data/etc/vsftpd/vuser_passwd.db")
	os.execute("/usr/bin/db_load -T -t hash -f /tmp/vuser_passwd.conf /opt/data/etc/vsftpd/vuser_passwd.db")
	os.execute("/usr/bin/rm -f /tmp/vuser_passwd.conf")
	os.execute("/usr/bin/chmod 600 /opt/data/etc/vsftpd/vuser_passwd.db")

	-->> 创建虚拟配置文件目录
	for username, _ in pairs(list) do
		local info = string.format([[local_root=/nfs/guest_%s
write_enable=YES
anon_umask=022
anon_world_readable_only=NO
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
]], username)
		os.execute(string.format("/usr/bin/echo '%s' > /opt/data/etc/vsftpd/vuser_conf/%s", info, username))
		os.execute(string.format("/usr/bin/mkdir -p /nfs/guest_%s", username))
		os.execute(string.format("/usr/bin/chmod -R 777 /nfs/guest_%s", username))
	end
	return true
end

local function config_samba(list)
	os.execute("/usr/bin/mkdir -p /opt/data/etc/samba/")
	-->> 清空写
	local msg = ''
	for username, _ in pairs(list) do
		msg = msg .. string.format("guest_%s = %s\n", username, username)
	end

	local file = io.open("/opt/data/etc/samba/smb_user_map", "w")
	if not file then
		only.log('E', 'open smb_user_map failed!')
		return false
	end
	file:write(msg)
	file:close()
	return true
end

local function config_samba_add(username, password)
	local cmd = string.format("/usr/bin/echo -e '%s\n%s\n'|/usr/bin/pdbedit -a -u 'guest_%s'", password, password, username)
	os.execute(cmd)
	return true
end

local function config_samba_del(username)
	local cmd = string.format("/usr/bin/pdbedit -x 'guest_%s'", username)
	os.execute(cmd)
	return true
end

return {
	main_call = main_call,
	admin_sign = admin_sign,
	token_check = token_check,
	config_vsftp = config_vsftp,
	config_samba = config_samba,
	config_samba_add = config_samba_add,
	config_samba_del = config_samba_del,
}
