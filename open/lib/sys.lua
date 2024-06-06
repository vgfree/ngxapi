
--module("sys", package.seeall)

local function execute(cmd)
	local handle = io.popen(cmd)
	local output = handle:read("*all")
	local status = handle:close()

	if status then
		return true, output
	else
		return false, output
	end
end

return {
	execute = execute
}
