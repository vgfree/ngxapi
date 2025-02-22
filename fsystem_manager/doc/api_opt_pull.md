下载文件
=================================

### API编号

### 功能简介
* 下载文件,8M以上文件建议分段下载

### 参数格式

* 所有 API 都以 **GET/PUT/POST/DELETE** 方式请求，且传送方式为 **key-value键值对**.

### 输入参数


 参数           |参数说明                 |  类型       |   示例         |是否允许为空|  限制条件
----------------|-------------------------|-------------|----------------|------------|---------------------
path            |文件路径                 |string       |  example.jepg  |否          |不能以/或./或../开头


### 示例代码

    GET /fsystemManager/v1/optPull HTTP/1.0
    Host: 127.0.0.1:8090
    User-Agent: curl/7.76.1
    Accept: */*
    Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6IjEzOTE3OTUxMDAyIiwiZXhwIjoxNzM3NTEzNDMwLCJwYXNzd29yZCI6ImxvdmVAMTIzNDU2In0.5uGXZeluzZINWPsAt3nD0TOvGjOUudTJVnOKT7qDfxQ
    Content-Length: 27
    Range: bytes=0-5
    Content-Type: application/x-www-form-urlencoded

    {"path":"xxxx.jpeg"}

### 返回body示例

* 失败: `404`
* 成功: `206`


### 返回结果参数

参数            | 参数说明
----------------|-------------------------------


### 错误编码

错误编码    | 错误描述                  | 解决办法
------------|---------------------------|------------------

### 测试地址: 127.0.0.1

