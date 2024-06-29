local mysql_api = require('mysql_pool_api')
local cjson = require("cjson")
local gosay = require('gosay')
local MSG = require('MSG')
local jwt = require("resty.jwt")
local only = require('only')

local sql_fmt = {
	one_update = "UPDATE sys_info SET secret='%s' WHERE id=1",
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
	local secret = res["secret"]
	if not secret then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end

	local sql = string.format(sql_fmt["one_update"], secret)
	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'UPDATE', sql)
	if not ok then
		only.log('E','select mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	if res == 1 then
		gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
	else
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
	end
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
