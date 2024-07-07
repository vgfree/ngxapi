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
	local ok, info = sys.execute("/usr/bin/lsblk -d -o NAME,MODEL,VENDOR -J")
	if not ok then
		only.log('E', 'lsblk failed:%s!', info)
		return list
	end
	local top = cjson.decode(info)
	for _, sub in ipairs(top["blockdevices"]) do
		local name = sub["name"]
		local model = sub["model"]
		local vendor = sub["vendor"]
		for i, one in ipairs(list) do
			if one["name"] == name then
				list[i]["model"] = model
				list[i]["vendor"] = vendor
				break
			end
		end
	end

	return list
end

--遍历所有匹配的key="value"键值对
local function parse_k_v_(str)
    local list = {}
    local fmt = '(%w+)="([^"]*)"'
    for key, val in str:gmatch(fmt) do
	list[key] = val
    end
    return list
end

local function parse_blkid(str)
	local pos = string.find(str, ":")
	if pos then
		local sub_str = string.sub(str, pos + 1)
		return parse_k_v_(sub_str)
	end
	return {}
end

local function get_disk_uuid(dev)
	local ok, info = sys.execute("/usr/sbin/blkid /dev/" .. dev)
	if not ok then
		only.log('E', 'blkid failed:%s!', info)
		return nil
	end
	local list = parse_blkid(info)
	return list["UUID"]
end

local function get_disk_fstype(dev)
	local ok, info = sys.execute("/usr/sbin/blkid /dev/" .. dev)
	if not ok then
		only.log('E', 'blkid failed:%s!', info)
		return nil
	end
	local list = parse_blkid(info)
	return list["TYPE"]
end

local function data_pool_apply(list)
	local mounts = {}
	os.execute("/usr/bin/csdo /usr/bin/umount /nfs")
	if #list == 0 then return end
	for _, one in ipairs(list) do
		os.execute("/usr/bin/csdo /usr/bin/umount /dev/disk/by-uuid/" .. one["uuid"])
		os.execute("/usr/bin/csdo /usr/bin/mkdir -p /mnt/" .. one["uuid"])
		local cmd = string.format("/usr/bin/csdo /usr/bin/mount /dev/disk/by-uuid/%s /mnt/%s", one["uuid"], one["uuid"])
		local ok, info = sys.execute(cmd)
		if not ok then
			only.log('E', 'mount failed:%s!', info)
		end
		table.insert(mounts, "/mnt/" .. one["uuid"])
	end
	local disks = table.concat(mounts, ":")
	os.execute("/usr/bin/csdo /usr/bin/mkdir -p /nfs")
	local cmd = string.format("/usr/bin/csdo /usr/bin/mergerfs -o allow_other,use_ino,cache.files=partial,dropcacheonclose=true,category.create=mfs %s /nfs", disks)
	local ok, info = sys.execute(cmd)
	if not ok then
		only.log('E', 'mergerfs failed:%s!', info)
	end
end

return {
	get_all_disk = get_all_disk,
	get_disk_uuid = get_disk_uuid,
	get_disk_fstype = get_disk_fstype,
	data_pool_apply = data_pool_apply,
}
