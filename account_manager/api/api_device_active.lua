local mysql_api = require('mysql_pool_api')
local gosay = require('gosay')
local cjson = require('cjson')
local MSG = require('MSG')
local AM_utils = require('AM_utils')
local only = require('only')
local sys = require('sys')
local http = require('resty.http')

local sql_fmt = {
	one_update = "UPDATE sys_info SET identity='%s', scale_token='%s' WHERE id=1",
}

local function handle()
	AM_utils.token_check()

	local body = ngx.req.get_body_data()
	local res = cjson.decode(body)
	if not res then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end
	local nas_uuid = res["nas_uuid"]
	if not nas_uuid then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end
	local identity = res["identity"]
	if not identity then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end
	local verification_code = res["verification_code"]
	if not verification_code then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end

	local httpc = http.new()
	local headers = ngx.req.get_headers() 
        local url = string.format("http://%s/manageCenter/v1/deviceActive", ngx.var.manage_center)
        local res, errmsg = httpc:request_uri(url, {method = "POST", headers = {["Accept"] = "application/json", ["Authorization"] = headers["Authorization"],}, body = body, ssl_verify = false,})
        httpc:close()
        if not res then
		only.log('E', '%s', errmsg)
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_NETWORK"))
		return
        end
        if res.status ~= 200 then
		gosay.out_status(res.status)
		return
        end

        local obj, errmsg = cjson.decode(res.body)
        if not obj then
		only.log('E', '%s', errmsg)
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
        end

	if obj["ERRORCODE"] ~= 0 then
		gosay.out_message(res.body)
		return
	end

	local host = ngx.var.manage_center
	local pos = host:find(":")
	if pos then
		host = host:sub(1, pos - 1)
	end
	local cmd = string.format("csdo /usr/bin/tailscale up --login-server=http://%s:7899 --accept-routes=true --accept-dns=false --force-reauth --authkey '%s'", host, obj["RESULT"]["scale_token"])
	local ok, errmsg = sys.execute(cmd)
	if not ok then
		only.log('E', '%s', errmsg)
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end

	local sql = string.format(sql_fmt["one_update"], obj["RESULT"]["identity"], obj["RESULT"]["scale_token"])
	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'UPDATE', sql)
	if not ok then
		only.log('E','select mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end

	gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
end

AM_utils.main_call(handle)
