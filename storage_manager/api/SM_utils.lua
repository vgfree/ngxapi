local sys = require("sys")
local cjson = require('cjson')
local only = require('only')
local jwt = require("resty.jwt")
local os = require("os")
local gosay = require('gosay')
local MSG = require('MSG')

------> only use for handle
local function main_call(F, ...)
	ngx.header["Content-Type"] = "application/json"
	local info = { pcall(F, ...) }
	if not info[1] then
		only.log("E", info[2])
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
	end
end

local function admin_verify(jwt_token)
	local shared_dict = ngx.shared.storehouse
	local secret = shared_dict:get("am-secret")

	local jwt_obj = jwt:verify(secret, jwt_token)
	if not jwt_obj["verified"] then
		only.log('E','token:%s!', jwt_obj["reason"])
		return false
	end
	return true
end

local function token_check()
	local headers = ngx.req.get_headers()
	local authorization_header = headers["Authorization"]
	if not authorization_header then
		gosay.out_status(401)
	end
	local token = string.match(authorization_header, "Bearer (.+)$")
	if not admin_verify(token) then
		gosay.out_status(401)
	end
end

local function get_one_disk(name)
	local ok, info = sys.execute("/usr/bin/lsblk -d -o NAME,MODEL,VENDOR,UUID,SERIAL,WWN,SIZE,FSTYPE,FSSIZE,FSUSED,FSAVAIL,FSUSE% -J /dev/" .. name)
	if not ok then
		only.log('E', 'lsblk failed:%s!', info)
		return nil
	end
	local top = cjson.decode(info)
	return top["blockdevices"][1]
end

local function get_all_disk()
	local ok, info = sys.execute("/usr/bin/lsblk -J")
	if not ok then
		only.log('E', 'lsblk failed:%s!', info)
		return {}
	end
	local list = {}
	local top = cjson.decode(info)
	for _, sub in ipairs(top["blockdevices"]) do
		local name = sub["name"]
		local is_sys_block = false
		for _, one in ipairs(sub["children"] or {}) do
			for _, mnt in ipairs(one["mountpoints"] or {}) do
				if mnt == "/boot" then
					is_sys_block = true
				end
			end
		end
		if not is_sys_block then
			table.insert(list, name)
		end
	end

	local all = {}
	for _, dev in ipairs(list) do
		local one = get_one_disk(dev)
		if one then
			table.insert(all, one)
		end
	end
	return all
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
	for _, one in ipairs(list) do
		local cmd = string.format([[/usr/sbin/blkid | grep -q 'UUID="%s"']], one["uuid"])
		local ok = sys.execute(cmd)
		if not ok then
			only.log('E', 'disk %s is inactive!', one["uuid"])
			return
		end
	end

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
		else
			table.insert(mounts, "/mnt/" .. one["uuid"])
		end
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
	main_call = main_call,
	token_check = token_check,
	get_all_disk = get_all_disk,
	get_one_disk = get_one_disk,
	get_disk_uuid = get_disk_uuid,
	get_disk_fstype = get_disk_fstype,
	data_pool_apply = data_pool_apply,
}
