local gosay = require('gosay')
local cjson = require('cjson')
local MSG = require('MSG')
local jwt = require("resty.jwt")
local SM_utils = require('SM_utils')
local only = require('only')
local mysql_api = require('mysql_pool_api')

local sql_fmt = {
	disk_list = "SELECT * FROM disk_list WHERE in_pool = 1",
	disk_append = "INSERT INTO disk_list (dev, uuid, type, in_pool) VALUES ('%s', '%s', '%s', 1) ON DUPLICATE KEY UPDATE dev = '%s', type = VALUES(type), in_pool = 1;",
}

local function admin_verify(jwt_token)
	local secret = "ownstor"

	local jwt_obj = jwt:verify(secret, jwt_token)
	if not jwt_obj["verified"] then
		only.log('E','token:%s!', jwt_obj["reason"])
		return false
	end
	return true
end

local function handle()
	local headers = ngx.req.get_headers() 
	local authorization_header = headers["Authorization"] 
	if not authorization_header then 
		gosay.out_status(401)
	end
	local token = string.match(authorization_header, "Bearer (.+)$")
	if not admin_verify(token) then
		gosay.out_status(401)
	end

	local body = ngx.req.get_body_data()
	local res = cjson.decode(body)
	if not res then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end
	local dev = res["dev"]
	if not dev then
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_REQ_ARGS"))
		return
	end
	os.execute("/usr/bin/csdo /usr/bin/umount /dev/" .. dev)
	local uuid = SM_utils.get_disk_uuid(dev)
	local fstype = SM_utils.get_disk_fstype(dev)
	if not uuid or not fstype then
		local cmd = string.format([[/usr/bin/csdo /usr/sbin/parted -s /dev/%s unit s print |/usr/bin/grep -E '^ ?[1-9]+' |/usr/bin/awk '{print $1}' | while read PART; do /usr/bin/echo "Removing partition $PART on %s"; /usr/sbin/parted -s %s rm $PART; done]], dev, dev, dev)
		os.execute(cmd)
		os.execute("/usr/bin/csdo /usr/sbin/mkfs.xfs -f /dev/" .. dev)
		uuid = SM_utils.get_disk_uuid(dev)
	end

	local sql = string.format(sql_fmt["disk_append"], dev, uuid, "data", dev)
	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'INSERT', sql)
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
	if #res ~= 0 then
		SM_utils.data_pool_apply(res)
	end

	gosay.out_message(MSG.fmt_err_message("MSG_SUCCESS"))
	return
end

ngx.header["Content-Type"] = "application/json"
------> only use for handle
local function main_call(F, ...)
	local info = { pcall(F, ...) }
	if not info[1] then
		only.log("E", info[2])
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
	end
end

main_call(handle)
