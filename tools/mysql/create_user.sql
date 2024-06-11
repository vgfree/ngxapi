DROP USER IF EXISTS 'ownstor'@'localhost';

-- 创建新用户并设置密码  
CREATE USER 'ownstor'@'localhost' IDENTIFIED BY '123456';  
 
USE ownstor_db; 
-- 赋予新用户所有数据库的所有权限  
GRANT ALL PRIVILEGES ON ownstor_db.sys_info TO 'ownstor'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ownstor_db.user_list TO 'ownstor'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ownstor_db.activity_list TO 'ownstor'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ownstor_db.oc_filecache TO 'ownstor'@'localhost' WITH GRANT OPTION;
  
-- 刷新权限，使新设置立即生效  
FLUSH PRIVILEGES;
