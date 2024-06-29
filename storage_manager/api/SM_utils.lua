local sys = require("sys")
local cjson = require('cjson')
local only = require('only')

local function get_all_disk()
	local list = {}
	local ok, info = sys.execute("/usr/bin/lsblk -J")
	if not ok then
		only.log('E', 'lsblk failed:%s!', info)
		return list
	end
	local top = cjson.decode(info)
	for _, sub in ipairs(top["blockdevices"]) do
		local name = sub["name"]
		local size = sub["size"]
		local is_sys_block = false
		for _, one in ipairs(sub["children"] or {}) do
			for _, mnt in ipairs(one["mountpoints"] or {}) do
				if mnt == "/boot" then
					is_sys_block = true
				end
			end
		end
		if not is_sys_block then
			table.insert(list, {name = name, size = size})
		end
	end
	return list
end

return {
	get_all_disk = get_all_disk,
}
