all:
	gcc -g -shared -fPIC -o lua_pam.so lua_pam.c -I/usr/include/luajit-2.1/ -L/usr/lib/ -lluajit-5.1 -lpam
	gcc -g -o pam_check pam_check.c -lpam
	#gcc -g -shared -fPIC -o lua_pam.so lua_pam.c -lpam
