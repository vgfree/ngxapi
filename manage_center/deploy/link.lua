module(..., package.seeall)

OWN_POOL = {
    redis = {
    },
    mysql = {

        ownstor___ownstor_db = {
            host = '127.0.0.1',
            port = 3306,
            database = 'ownstor_db',
            user = 'ownstor',
            password ='123456',
        },

    },
}


OWN_DIED = {
    redis = {
    },
    mysql = {
    },

}


setmetatable(_M, { __index = _M })
