创建目录或文件
=================================

### API编号

### 功能简介
* 创建目录

### 参数格式

* 所有 API 都以 **GET/PUT/POST/DELETE** 方式请求，且传送方式为 **key-value键值对**.

### 输入参数


 参数           |参数说明                 |  类型       |   示例         |是否允许为空|  限制条件
----------------|-------------------------|-------------|----------------|------------|---------------------
path            |目录名称                 |string       |  test/subpath  |否          |不能跨级创建目录,不能以/或./或../开头
isDir           |是否是目录               |bool         |  true          |否          |


### 示例代码

    PUT /fsystemManager/v1/optCreate HTTP/1.0
    Host:127.0.0.1:8090
    Content-Length:22
    Content-Type:application/json
    Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6IjEzOTE3OTUxMDAyIiwiZXhwIjoxNzM3MzY3MzkzLCJwYXNzd29yZCI6ImxvdmVAMTIzNDU2In0.kD_xVbRlqFx6FzwVUOdDLld72ISUfTmIbYSh9RpiO1E

    {"path":"test/subpath", "isDir":true}

### 返回body示例

* 失败: `{"ERRORCODE":20008, "RESULT":"path is exists!"}`
* 成功: `{"ERRORCODE":0,"RESULT":"ok!"}`


### 返回结果参数

参数            | 参数说明
----------------|-------------------------------


### 错误编码

错误编码    | 错误描述                  | 解决办法
------------|---------------------------|------------------
0           | Request OK                |
10000       | 参数错误                  | 请检查输入参数
10001       | 系统内部错误              | 请与公司客服联系
20007       | path路径无效              | 请检查输入参数
20008       | path路径已存在            | 请检查输入参数

### 测试地址: 127.0.0.1

