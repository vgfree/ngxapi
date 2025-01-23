local gosay = require('gosay')
local cjson = require('cjson')
local MSG = require('MSG')
local SM_utils = require('SM_utils')
local only = require('only')
local mysql_api = require('mysql_pool_api')

local sql_fmt = {
	disk_list = "SELECT * FROM disk_list",
}

local function handle()
	SM_utils.token_check()

	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'SELECT', sql_fmt["disk_list"])
	if not ok then
		only.log('E','select mysql failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	local list = {}
	for _, one in ipairs(res or {}) do
		list[one["uuid"]] = true
	end

	local res = SM_utils.get_all_disk()
	local all = {}
	for _, one in ipairs(res or {}) do
		if not list[one["uuid"]] then
			table.insert(all, one)
		end
	end
	local msg = cjson.encode(all)
	gosay.out_message(MSG.fmt_api_message(msg))
end

SM_utils.main_call(handle)
