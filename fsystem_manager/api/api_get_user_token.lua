local mysql_api = require('mysql_pool_api')
local gosay = require('gosay')
local MSG = require('MSG')
local cjson = require("cjson")
local sys = require("sys")
local only = require('only')
local basexx = require("basexx")  
local FM_utils = require('FM_utils')

local sql_fmt = {
	user_info = "SELECT password FROM user_list WHERE username='%s' AND accepted=1",
}

local function handle()
	local args = ngx.req.get_uri_args()
	local headers = ngx.req.get_headers() 

	local authorization_header = headers["Authorization"] 
	if not authorization_header then 
		gosay.out_status(401)
		return
	end

	local bstr = string.match(authorization_header, "Basic +([^ ]+)")
	if not bstr then
		gosay.out_status(401)
		return
	end
	local auth = basexx.from_base64(bstr)
	local username, password = string.match(auth, "([^:]*):(.*)")
	if not username or not password then
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
	if password ~= res[1]["password"] then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PASSWORD"))
		return
	end

	local token = FM_utils.user_sign(username, password)

	local info = {}
	info["token"] = token
	local msg = cjson.encode(info)
	gosay.out_message(MSG.fmt_api_message(msg))
end

FM_utils.main_call(handle)
