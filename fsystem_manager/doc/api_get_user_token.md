获取用户token
=================================

### API编号

### 功能简介
* 获取用户token

### 参数格式

* 所有 API 都以 **GET/POST/DELETE** 方式请求，且传送方式为 **key-value键值对**.

### 输入参数


 参数           |参数说明                 |  类型       |   示例         |是否允许为空|  限制条件
----------------|-------------------------|-------------|----------------|------------|---------------------
username        |用户名称                 |string       |  13917951002   |否          |无
password        |用户密码                 |string       |  love@123456   |否          |无


### 示例代码

    GET /fsystemManager/v1/getUserToken HTTP/1.0
    Host:127.0.0.1:8090
    Authorization: Basic MTM5MTc5NTEwMDI6bG92ZUAxMjM0NTY=
    Content-Length:0
    Content-Type:application/json

### 返回body示例

* 失败: `{"ERRORCODE":20006, "RESULT":"password is wrong!"}`
* 成功: `{"ERRORCODE":0, "RESULT":{"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6IjEzOTE3OTUxMDAyIiwiZXhwIjoxNzM3MzY3MzkzLCJwYXNzd29yZCI6ImxvdmVAMTIzNDU2In0.kD_xVbRlqFx6FzwVUOdDLld72ISUfTmIbYSh9RpiO1E"}}`


### 返回结果参数

参数            | 参数说明
----------------|-------------------------------
token           | 授权码


### 错误编码

错误编码    | 错误描述                  | 解决办法
------------|---------------------------|------------------
0           | Request OK                |
10000       | 参数错误                  | 请检查输入参数
10001       | 系统内部错误              | 请与公司客服联系
20006       | 用户密码错误              | 请检查输入参数

### 测试地址: 127.0.0.1

