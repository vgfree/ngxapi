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

-->>设置带过期时间的值
local function set_with_expire(key, value, expire_seconds)
	-->>获取当前时间戳
	local now = ngx.now()
	local expire_at = now + expire_seconds
	local cache = ngx.shared.cache
	cache:set(key, cjson.encode({value = value, expire_at = expire_at}))
end

-->>获取值并检查是否过期
local function get_with_expire(key)
	-->>获取当前时间戳
	local now = ngx.now()
	local cache = ngx.shared.cache
	local val, flags = cache:get(key)
	if not val then
		return nil
	end
	local info = cjson.decode(val)
	cache:delete(key)
	if now > info.expire_at then
		return nil
	end
	return info.value
end

return {
	main_call = main_call,
	token_check = token_check,
	set_with_expire = set_with_expire,
	get_with_expire = get_with_expire,
}
