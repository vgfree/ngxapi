LIB_DIR=$(shell pwd)
BASE_OBJ = lualog.so \
      cutils.so \
      socket.so \
      luasql.so \
      conhash.so \
      lfs.so
OBJ += $(BASE_OBJ)
#OBJ +=  \
	zlib.so \
	bit32.so \
	libcjson.so \
	cjson.so \
	conv.so \
	libhttps.so \
	libluadecoder.so \
	lualog.so \
	zklua.so \
	lrucache.so \
	zmq.so \
	http_message.so

all:$(OBJ)
	-@echo "Done LIB!"

cutils.so:
	$(MAKE) -C $(LIB_DIR)/cutils
	mv $(LIB_DIR)/cutils/$@ $(LIB_DIR)

socket.so:
	$(MAKE) -C $(LIB_DIR)/luasocket
	mv $(LIB_DIR)/luasocket/src/socket-3.1.0.so $(LIB_DIR)/$@
	cp $(LIB_DIR)/luasocket/src/socket.lua $(LIB_DIR)/

zlib.so:
	$(MAKE) -C $(LIB_DIR)/lua-zlib linux
	mv $(LIB_DIR)/lua-zlib/$@ $(LIB_DIR)

bit32.so:
	$(MAKE) -C $(LIB_DIR)/Lua-bit32
	mv $(LIB_DIR)/Lua-bit32/$@ $(LIB_DIR)

libcjson.so:
	$(MAKE) -C $(LIB_DIR)/cJSON
	mv $(LIB_DIR)/cJSON/$@ $(LIB_DIR)

lrucache.so:
	$(MAKE) -C $(LIB_DIR)/liblrucache
	mv $(LIB_DIR)/liblrucache/$@ $(LIB_DIR)
cjson.so:
	$(MAKE) -C $(LIB_DIR)/lua-cjson-2.1.0
	mv $(LIB_DIR)/lua-cjson-2.1.0/$@ $(LIB_DIR)

conhash.so:
	$(MAKE) -C $(LIB_DIR)/libconhash
	mv $(LIB_DIR)/libconhash/bin/$@ $(LIB_DIR)

lfs.so:
	cp luafilesystem.config luafilesystem/config
	$(MAKE) -C $(LIB_DIR)/luafilesystem
	mv $(LIB_DIR)/luafilesystem/src/$@ $(LIB_DIR)

luasql.so:
	# git clone https://github.com/lunarmodules/luasql.git
	$(MAKE) -C $(LIB_DIR)/luasql mysql
	mv $(LIB_DIR)/luasql/src/mysql.so $(LIB_DIR)/luasql/

conv.so:
	$(MAKE) -C $(LIB_DIR)/conv
	mv $(LIB_DIR)/conv/$@ $(LIB_DIR)

libtcp.so:
	$(MAKE) -C $(LIB_DIR)/dkldb
	mv $(LIB_DIR)/dkldb/$@ $(LIB_DIR)

libluadecoder.so:
	$(MAKE) -C $(LIB_DIR)/decoder
	mv $(LIB_DIR)/decoder/$@ $(LIB_DIR)

zmq.so:
	$(MAKE) -C $(LIB_DIR)/lua-zmq
	mv $(LIB_DIR)/lua-zmq/$@ $(LIB_DIR)

http_message.so:
	$(MAKE) -C $(LIB_DIR)/lua-http-message
	mv $(LIB_DIR)/lua-http-message/$@ $(LIB_DIR)

lualog.so:
	$(MAKE) -C $(LIB_DIR)/lua-log CFLAGS="-g"
	mv $(LIB_DIR)/lua-log/$@ $(LIB_DIR)


libhttps.so:
	tar -xzvf polarssl-1.2.8.tar.gz && mkdir build && cd build && ccmake ../polarssl-1.2.8/ && make && cp programs/ssl/libhttps.so ../

zklua.so:
	$(MAKE) -C $(LIB_DIR)/zklua
	mv $(LIB_DIR)/zklua/$@ $(LIB_DIR)


clean:
	rm -rf ./*.so
	$(MAKE) -C $(LIB_DIR)/lua-cjson-2.1.0 clean
	$(MAKE) -C $(LIB_DIR)/luasql-master clean
	$(MAKE) -C $(LIB_DIR)/libconhash clean
	$(MAKE) -C $(LIB_DIR)/luasocket clean
	$(MAKE) -C $(LIB_DIR)/lua-zmq clean
	$(MAKE) -C $(LIB_DIR)/lua-http-message clean
	$(MAKE) -C $(LIB_DIR)/lua-log clean
	$(MAKE) -C $(LIB_DIR)/zklua clean
	$(MAKE) -C $(LIB_DIR)/luafilesystem clean
	cd ./lua-zlib && make clean
	cd ./Lua-bit32 && make clean
	-if [ -d ./build ];then rm -rf ./build; fi
	-if [ -d ./polarssl-1.2.8 ];then rm -rf ./polarssl-1.2.8; fi

