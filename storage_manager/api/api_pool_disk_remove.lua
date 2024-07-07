local gosay = require('gosay')
local cjson = require('cjson')
local MSG = require('MSG')
local SM_utils = require('SM_utils')
local only = require('only')
local mysql_api = require('mysql_pool_api')

local sql_fmt = {
	disk_list = "SELECT * FROM disk_list WHERE in_pool = 1",
	disk_remove = "UPDATE disk_list SET in_pool = 0 WHERE uuid = '%s'",
}

local function handle()
	SM_utils.token_check()

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

SM_utils.main_call(handle)
