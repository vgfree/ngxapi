local gosay = require('gosay')
local cjson = require('cjson')
local MSG = require('MSG')
local SM_utils = require('SM_utils')
local only = require('only')
local mysql_api = require('mysql_pool_api')

local sql_fmt = {
	disk_list = "SELECT * FROM disk_list",
	disk_append = "INSERT INTO disk_list (uuid, model, vendor, serial, wwn, size, fstype, type) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s') ON DUPLICATE KEY UPDATE type = VALUES(type);",
}

local function handle()
	SM_utils.token_check()

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

	local res = SM_utils.get_one_disk(dev)
	if not res then
		only.log('E','get disk info failed!')
		gosay.out_message(MSG.fmt_err_message("MSG_ERROR_SYSTEM"))
		return
	end
	local sql = string.format(sql_fmt["disk_append"], uuid, res["model"] or "", res["vendor"] or "", res["serial"] or "", res["wwn"] or "", res["size"] or "", res["fstype"] or "", "data")
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

SM_utils.main_call(handle)
