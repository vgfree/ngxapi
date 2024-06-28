[root@ownstor ownstor-api]# mount -t cifs -o username=13917951002,password=love@123456 //127.0.0.1/13917951002 /tmp/
[root@ownstor ownstor-api]# ftp 127.0.0.1
Connected to 127.0.0.1 (127.0.0.1).
220 Welcome to ownstor FTP service.
Name (127.0.0.1:root): 13917951002
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
227 Entering Passive Mode (127,0,0,1,60,198).
150 Here comes the directory listing.
-rwxr--r--    1 1001     1001            0 Jun 28 10:31 abc
226 Directory send OK.
ftp>

