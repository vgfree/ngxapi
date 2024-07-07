local gosay = require('gosay')
local cjson = require('cjson')
local MSG = require('MSG')
local jwt = require("resty.jwt")
local SM_utils = require('SM_utils')
local only = require('only')
local mysql_api = require('mysql_pool_api')

local sql_fmt = {
	disk_list = "SELECT * FROM disk_list",
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

	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'SELECT', sql_fmt["disk_list"])
	if not ok then
		only.log('E','select mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	if #res ~= 0 then
		local list = {}
		for _, one in ipairs(res) do
			if one["in_pool"] == "1" then
				table.insert(list, {dev = one["dev"], uuid = one["uuid"], type = one["type"]})
			end
		end
		local msg = cjson.encode(list)
		gosay.out_message(MSG.fmt_api_message(msg))
	else
		gosay.out_message(MSG.fmt_api_message("[]"))
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
