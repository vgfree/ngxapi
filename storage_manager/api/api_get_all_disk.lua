local gosay = require('gosay')
local cjson = require('cjson')
local MSG = require('MSG')
local SM_utils = require('SM_utils')
local only = require('only')

local function handle()
	SM_utils.token_check()

	local res = SM_utils.get_all_disk()
	local msg = cjson.encode(res)
	gosay.out_message(MSG.fmt_api_message(msg))
end

SM_utils.main_call(handle)
