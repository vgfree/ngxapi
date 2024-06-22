local cjson = require("cjson")
local gosay = require('gosay')
local mysql_api = require('mysql_pool_api')
local MSG = require('MSG')
local jwt = require("resty.jwt")
local AM_utils = require('AM_utils')

local APP_KEY_LIST = {
	ownstor_web = "alkIIllmsdk",
}

local sql_fmt = {
	user_del = "DELETE FROM user_list WHERE username='%s'",
	user_list = "SELECT username, password FROM user_list",
}

local function admin_verify(jwt_token)
	local secret = "ownstor"

	local jwt_obj = jwt:verify(secret, jwt_token)
	if not jwt_obj["verified"] then
		only.log('E','token:%s!', jwt_obj["reason"])
		return false
	end
	return true
end

local function check_args(args)
	--if not args['appKey'] or args['appKey'] == "" or not APP_KEY_LIST[args['appKey']] then
	--	gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
	--	return
	--end
end

local function handle()
	local headers = ngx.req.get_headers() 
	local authorization_header = headers["Authorization"] 
	if not authorization_header then 
		gosay.out_status(401)
	end
	local token = string.match(authorization_header, "Bearer (.+)$")
	if not admin_verify(token) then
		gosay.out_status(401)
	end

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

	-->> 配置vsftp
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

	ok = AM_utils.config_vsftp(list)
	if not ok then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end


	gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
end

ngx.header["Content-Type"] = "application/json"
------> only use for handle
local function main_call(F, ...)
	local info = { pcall(F, ...) }
	if not info[1] then
		only.log("E", info[2])
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
	end
end

main_call(handle)
