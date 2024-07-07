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

SM_utils.main_call(handle)
