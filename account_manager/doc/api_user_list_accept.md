授权的用户列表
=================================

### API编号

### 功能简介
* 显示授权的用户列表

### 参数格式

* 所有 API 都以 **GET/POST** 方式请求，且传送方式为 **key-value键值对**.

### 输入参数


 参数           |参数说明                 |  类型       |   示例         |是否允许为空|  限制条件
----------------|-------------------------|-------------|----------------|------------|---------------------

### 示例代码

    GET /accountManager/v1/userListAccept HTTP/1.0
    Host:127.0.0.1:8090
    Content-Length:0
    Content-Type:application/json
    Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTc4MTc2MzJ9.SxT8X-7Xg0-ei17G1HtKzbB2ADR-TaVwOX7I0-PLCw4


### 返回body示例

* 失败: `{"ERRORCODE":10001, "RESULT":"internal error!"}`
* 成功: `{"ERRORCODE":0,"RESULT":[]}`


### 返回结果参数

参数            | 参数说明
----------------|-------------------------------
username        |用户名,如：459032139@qq.com
save_time       |申请时间,如：2025-02-13 02:09:44


### 错误编码

错误编码    | 错误描述                  | 解决办法
------------|---------------------------|------------------
0           | Request OK                |
10000       | 参数错误                  | 请检查输入参数
10001       | 系统内部错误              | 请与公司客服联系

### 测试地址: 127.0.0.1

