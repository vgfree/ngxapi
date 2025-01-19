用户拒绝
=================================

### API编号

### 功能简介
* 用户拒绝

### 参数格式

* 所有 API 都以 **GET/POST/DELETE** 方式请求，且传送方式为 **key-value键值对**.

### 输入参数


 参数           |参数说明                 |  类型       |   示例         |是否允许为空|  限制条件
----------------|-------------------------|-------------|----------------|------------|---------------------
username        |用户名                   |string       |13917951002     |否          |手机号

### 示例代码

    DELETE /accountManager/v1/userReject HTTP/1.0
    Host:127.0.0.1:8090
    Content-Length:0
    Content-Type:application/json
    Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTc4MTc2MzJ9.SxT8X-7Xg0-ei17G1HtKzbB2ADR-TaVwOX7I0-PLCw4

    {"username":"13917951002"}

### 返回body示例

* 失败: `{"ERRORCODE":10001, "RESULT":"internal error!"}`
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

### 测试地址: 127.0.0.1

