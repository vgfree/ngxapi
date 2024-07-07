local gosay = require('gosay')
local cjson = require('cjson')
local MSG = require('MSG')
local jwt = require("resty.jwt")
local SM_utils = require('SM_utils')
local only = require('only')
local mysql_api = require('mysql_pool_api')

local sql_fmt = {
	disk_list = "SELECT * FROM disk_list WHERE in_pool = 1",
	disk_remove = "UPDATE disk_list SET in_pool = 0 WHERE uuid = '%s'",
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

	local body = ngx.req.get_body_data()
	local res = cjson.decode(body)
	if not res then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end
	local uuid = res["uuid"]
	if not uuid then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end

	local sql = string.format(sql_fmt["disk_remove"], uuid)
	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'UPDATE', sql)
	if not ok then
		only.log('E','insert mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'SELECT', sql_fmt["disk_list"])
	if not ok then
		only.log('E','select mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	SM_utils.data_pool_apply(res)

	gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
	return
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
