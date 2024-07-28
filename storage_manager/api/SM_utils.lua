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
	local secret = "ownstor"

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

local function str_split(s, c)
	if not s then return nil end

	local m = string.format("([^%s]+)", c)
	local t = {}
	local k = 1
	for v in string.gmatch(s, m) do
		t[k] = v
		k = k + 1
	end
	return t
end

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
		local last_mnt = nil
		for _, mnt in ipairs(sub["mountpoints"] or {}) do
			last_mnt = mnt
		end
		for _, one in ipairs(sub["children"] or {}) do
			for _, mnt in ipairs(one["mountpoints"] or {}) do
				if mnt == "/boot" then
					is_sys_block = true
				end
			end
		end
		if not is_sys_block then
			local detail = {}
			if last_mnt then
				local ok, line = sys.execute(string.format("/usr/bin/df %s -Th|awk 'NR==2'", last_mnt))
				if not ok then
					only.log('E', 'df failed:%s!', line)
					return {}
				end
				detail = str_split(line, ' ')
			end
			if #detail == 0 then
				table.insert(list, {name = name, size = size})
			else
				table.insert(list, {name = name, size = size, fs_type = detail[2], used = detail[4], available = detail[5], usage_rate = detail[6]})
			end
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
	main_call = main_call,
	token_check = token_check,
	get_all_disk = get_all_disk,
	get_disk_uuid = get_disk_uuid,
	get_disk_fstype = get_disk_fstype,
	data_pool_apply = data_pool_apply,
}
