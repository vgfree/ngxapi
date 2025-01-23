表单上传小文件
=================================

### API编号

### 功能简介
* 表单上传小文件(<= 8M)

### 参数格式

* 所有 API 都以 **GET/PUT/POST/DELETE** 方式请求，且传送方式为 **key-value键值对**.

### 输入参数


 参数           |参数说明                 |  类型       |   示例         |是否允许为空|  限制条件
----------------|-------------------------|-------------|----------------|------------|---------------------
path            |文件路径                 |string       |  example.jepg  |否          |不能跨级创建文件,不能以/或./或../开头


### 示例代码

    PUT /fsystemManager/v1/optPush HTTP/1.0
    Host: 127.0.0.1:8090
    User-Agent: curl/7.76.1
    Accept: */*
    Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6IjEzOTE3OTUxMDAyIiwiZXhwIjoxNzM3NTEzNDMwLCJwYXNzd29yZCI6ImxvdmVAMTIzNDU2In0.5uGXZeluzZINWPsAt3nD0TOvGjOUudTJVnOKT7qDfxQ
    Content-Length: 337
    Content-Type: multipart/form-data; boundary=------------------------000f9474eb6337f6

### 返回body示例

* 失败: `{"ERRORCODE":20007, "RESULT":"path is invalid!"}`
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

### 测试地址: 127.0.0.1

