
--module('MSG', package.seeall)

local MSG = {
	-- 返回成功
	MSG_SUCCESS				                ={0, "ok!"},
	--> 参数错误
	MSG_ERROR_REQ_ARGS			                ={10000, "args is error!"},
	--> 系统错误
	MSG_ERROR_SYSTEM                                        ={10001, "internal error!"},
	MSG_ERROR_NETWORK                                       ={10002, "network error!"},

	MSG_ERROR_USER_EXIST		                        ={20000, "user is already exist!"},
	MSG_ERROR_USER_NOT_EXIST                                ={20001, "User does not exist!"},
	MSG_ERROR_SECRET                                        ={20002, "secret is wrong!"},
	MSG_ERROR_SECRET_SAME                                   ={20003, "secret is same!"},
	MSG_ERROR_VERIFICATION_CODE_EXPIRED                     ={20004, "the verification code has expired!"},
	MSG_ERROR_VERIFICATION_CODE_WRONG                       ={20005, "the verification code is wrong!"},
	MSG_ERROR_PASSWORD                                      ={20006, "password is wrong!"},
	MSG_ERROR_PATH_INVALID                                  ={20007, "path is invalid!"},
	MSG_ERROR_PATH_EXISTS                                   ={20008, "path is exists!"},
	MSG_ERROR_PATH_NOT_EXISTS                               ={20009, "path is not exists!"},
	MSG_ERROR_DISK_POOL_EMPTY                               ={20010, "store disk pool is empty!"},
	MSG_ERROR_DISK_POOL_INACTIVE                            ={20011, "store disk pool have inactive!"},
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
