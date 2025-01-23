local gosay = require('gosay')
local cjson = require('cjson')
local MSG = require('MSG')
local FM_utils = require('FM_utils')
local only = require('only')
local lfs = require('lfs')
local sys = require('sys')

local function handle()
	local result = FM_utils.token_check()

	local username = result["username"]
	local body = ngx.req.get_body_data()
	local res = cjson.decode(body)
	if not res then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end

	local path = res["path"]
	local ok = FM_utils.is_normalize_path(path)
	if not ok then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_INVALID"))
		return
	end
	local full_path = string.format("/nfs/guest_%s/%s", username, path)

	local attr, err = lfs.attributes(full_path)
	if not attr then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_PATH_NOT_EXISTS"))
		return
	end

	local list = {}
	local empty = false
	if attr["mode"] == "directory" then
		for file in lfs.dir(full_path) do
			-- 跳过.和..目录
			if file ~= "." and file ~= ".." then
				local attr, err = lfs.attributes(full_path .. "/" .. file)
				if attr then
					local info = {}
					if path == "" then
						info["path"] = file
					else
						info["path"] = path .. "/" .. file
					end
					info["type"] = attr.mode
					info["size"] = attr.size
					info["birth"] = attr.change
					info["modify"] = attr.modification
					info["access"] = attr.permissions
					table.insert(list, info)
				end
			end
		end
		if #list == 0 then
			empty = true
		end
	else
		list["path"] = path
		list["type"] = attr.mode
		list["size"] = attr.size
		list["birth"] = attr.change
		list["modify"] = attr.modification
		list["access"] = attr.permissions
	end

	local msg = cjson.encode(list)
	if empty then
		msg = "[]"
	end
	gosay.out_message(MSG.fmt_api_message(msg))
	return
end

FM_utils.main_call(handle)
