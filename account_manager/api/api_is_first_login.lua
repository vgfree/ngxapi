local mysql_api = require('mysql_pool_api')

local sql_fmt = {
	one_user = "SELECT * FROM user_list LIMIT 1",
}

local function handle()
	local ok, res = mysql_api.cmd('ownstor___ownstor_db', 'SELECT', sql_fmt["one_user"])
	if not ok then
		only.log('E','select mysql failed!')
		ngx.say([[{"ERRORCODE":10001, "RESULT":"internal error"}]])
		return
	end
	if #res ~= 0 then
		ngx.say([[{"ERRORCODE":0,"RESULT":"ok","isFirstLogin":false}]])
	else
		ngx.say([[{"ERRORCODE":0,"RESULT":"ok","isFirstLogin":true}]])
	end
end

ngx.header["Content-Type"] = "application/json"
handle()
