local lua_pam = require('lua_pam')

print(lua_pam.auth_check("baoxue", 'mmmmmmmmmmmmmm'))
print(lua_pam.auth_check("baoxue", 'Kx!@#890vgfree'))
print(lua_pam.auth_check("guest13917951002", 'Kx123890vgfree'))


print(os.execute("./pam_check guest13917951002  'Kx123890vgfreea'"))
