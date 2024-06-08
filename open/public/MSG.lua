
--module('MSG', package.seeall)

local MSG = {
	-- 返回成功
	MSG_SUCCESS				                ={0, "ok!"},
	--> 参数错误
	MSG_ERROR_REQ_ARGS			                ={10000, "args is error!"},
	--> 系统错误
	MSG_ERROR_SYSTEM                                        ={10001, "internal error!"},

	MSG_ERROR_USER_EXIST		                        ={20000, "user is already exist!"},
	MSG_ERROR_USER_NOT_EXIST                                ={20001, "User does not exist!"},
	MSG_ERROR_SECRET                                        ={20002, "secret is wrong!"},
}

local function fmt_err_message(err)
    return string.format('{"ERRORCODE":%d, "RESULT":"%s"}', MSG[err][1], MSG[err][2])
end

local function fmt_api_message(msg)
    local start = string.sub(msg, 1, 1)
    if start == '[' or start == '{' then
	return string.format('{"ERRORCODE":0, "RESULT":%s}', msg)
    else
	return string.format('{"ERRORCODE":0, "RESULT":"%s"}', msg)
    end
end

return {
	fmt_err_message = fmt_err_message,
	fmt_api_message = fmt_api_message
}
