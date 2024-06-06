local ngx = require('ngx')
local perf = require('perf')

--module('gosay', package.seeall)

local function out_status(status)
	if status ~= ngx.HTTP_OK then
		perf.cost("WHOLE FAILURE", false)
	else
		perf.cost("WHOLE SUCCESS", false)
	end
	ngx.status = status
	ngx.flush()
	ngx.exit(ngx.status)
end

local function out_message(message)
	perf.cost("WHOLE SUCCESS", false)
	ngx.say(message)
	ngx.flush()
	ngx.exit(ngx.HTTP_OK)
end

return {
	out_status = out_status,
	out_message = out_message
}
