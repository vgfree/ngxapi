package.path = "/opt/ownstor/ownstor-api/account_manager/api/?.lua;" .. package.path
package.path = "/opt/ownstor/ownstor-api/account_manager/conf/?.lua;" .. package.path

local shared_dict = ngx.shared.storehouse
local key = "am-secret"
local val = "omstar" .. os.time()

shared_dict:set(key, val, 0)
