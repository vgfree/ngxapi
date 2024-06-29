local mysql_api = require('mysql_pool_api')
local gosay = require('gosay')
local MSG = require('MSG')
local cjson = require("cjson")
local jwt = require("resty.jwt")
local sys = require("sys")
local os = require("os")
local only = require('only')

local sql_fmt = {
	one_info = "SELECT * FROM sys_info WHERE id=1",
	one_init = "INSERT INTO sys_info (secret, scale_token, nas_uuid) VALUES ('123456', '%s', '%s')",
}

local function admin_sign()
	local secret = "ownstor"
	local expiration_time = os.time() + 1800	--秒

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

local function handle()
	local args = ngx.req.get_uri_args()
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

	local token = admin_sign()

	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'SELECT', sql_fmt["one_info"])
	if not ok then
		only.log('E','select mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	if #res == 0 then
		only.log('E','secret %s!', secret)
		if secret == "123456" then
			local cmd = "/usr/sbin/dmidecode -s system-uuid 2>&1"
			local ok, nas_uuid = sys.execute(cmd)
			if not ok then
				nas_uuid = "00000000-0000-0000-0000-000000000000"
			else
				nas_uuid = string.gsub(nas_uuid, "\n", "")
			end

			local sql = string.format(sql_fmt["one_init"], "", nas_uuid)
			local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'INSERT', sql)
			if not ok then
				only.log('E','select mysql failed!')
				gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
				return
			end

			local info = {}
			info["scale_token"] = ""
			info["nas_uuid"] = nas_uuid
			info["token"] = token
			local msg = cjson.encode(info)
			gosay.out_message(MSG.fmt_api_message(msg))
		else
			gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SECRET"))
		end
	else
		if res[1]["secret"] == secret then
			local info = {}
			info["scale_token"] = res[1]["scale_token"]
			info["nas_uuid"] = res[1]["nas_uuid"]
			info["token"] = token
			local msg = cjson.encode(info)
			gosay.out_message(MSG.fmt_api_message(msg))
		else
			gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SECRET"))
		end
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
