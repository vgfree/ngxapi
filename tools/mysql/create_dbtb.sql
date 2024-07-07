DROP DATABASE IF EXISTS ownstor_db;

-- 创建一个数据库（如果它不存在的话）
CREATE DATABASE IF NOT EXISTS ownstor_db;

-- 使用刚刚创建的数据库或已存在的数据库
USE ownstor_db;

CREATE TABLE sys_info (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    secret VARCHAR(64) NOT NULL,
    scale_token VARCHAR(64) NOT NULL,
    nas_uuid VARCHAR(64) NOT NULL
);

CREATE TABLE disk_list (
    dev VARCHAR(64) NOT NULL,
    uuid VARCHAR(64) NOT NULL UNIQUE,
    type VARCHAR(32) NOT NULL,
    in_pool TINYINT(1) NOT NULL
);

CREATE TABLE user_list (
    username VARCHAR(32) NOT NULL,
    password VARCHAR(64) NOT NULL,
    scale_token VARCHAR(64) NOT NULL,
    save_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- 在该数据库中创建activity_list表
CREATE TABLE activity_list (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user VARCHAR(32) NOT NULL,
    machineID VARCHAR(64) NOT NULL,
    save_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activity_time TIMESTAMP NOT NULL,
    status INT NOT NULL,
    type INT NOT NULL,
    activity_type INT NOT NULL,
    direction INT NOT NULL,
    file TEXT NOT NULL
);

CREATE TABLE oc_filecache (  
  fileid BIGINT(20) NOT NULL,  
  storage BIGINT(20) NOT NULL,  
  path VARCHAR(4000) DEFAULT NULL,  
  path_hash VARCHAR(32) NOT NULL,  
  parent BIGINT(20) NOT NULL,  
  name VARCHAR(250) DEFAULT NULL,  
  mimetype BIGINT(20) NOT NULL,  
  mimepart BIGINT(20) NOT NULL,  
  size BIGINT(20) NOT NULL,  
  mtime BIGINT(20) NOT NULL,  
  storage_mtime BIGINT(20) NOT NULL,  
  encrypted INT(11) NOT NULL,  
  unencrypted_size BIGINT(20) NOT NULL,  
  etag VARCHAR(40) DEFAULT NULL,  
  permissions INT(11) DEFAULT 0,  
  checksum VARCHAR(255) DEFAULT NULL,  
  PRIMARY KEY (fileid),  
  KEY idx_storage (storage),  
  KEY idx_parent (parent),  
  KEY idx_size (size),  
  KEY idx_mtime (mtime)  
);
