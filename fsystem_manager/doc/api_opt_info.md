查询文件或目录详细信息
=================================

### API编号

### 功能简介
* 查询文件或目录详细信息(查询目录返回数组，查询文件返回map表)

### 参数格式

* 所有 API 都以 **GET/PUT/POST/DELETE** 方式请求，且传送方式为 **key-value键值对**.

### 输入参数


 参数           |参数说明                 |  类型       |   示例         |是否允许为空|  限制条件
----------------|-------------------------|-------------|----------------|------------|---------------------
path            |路径                     |string       |  test/subpath  |否          |  不能以/或./或../开头


### 示例代码

    GET /fsystemManager/v1/optInfo HTTP/1.0
    Host:127.0.0.1:8090
    Content-Length:23
    Content-Type:application/json
    Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6IjEzOTE3OTUxMDAyIiwiZXhwIjoxNzM3MzY3MzkzLCJwYXNzd29yZCI6ImxvdmVAMTIzNDU2In0.kD_xVbRlqFx6FzwVUOdDLld72ISUfTmIbYSh9RpiO1E

    {"path":"test/subpath"}

### 返回body示例

* 失败: `{"ERRORCODE":20009, "RESULT":"path is not exists!"}`
* 成功: `{"ERRORCODE":0,"RESULT":[]}`


### 返回结果参数

参数            | 参数说明
----------------|-------------------------------
path            | 文件/目录路径
type            | 文件/目录类型
size            | 文件/目录大小
birth           | 文件/目录创建时间
modify          | 文件/目录修改时间
access          | 文件/目录访问权限


### 错误编码

错误编码    | 错误描述                  | 解决办法
------------|---------------------------|------------------
0           | Request OK                |
10000       | 参数错误                  | 请检查输入参数
10001       | 系统内部错误              | 请与公司客服联系
20007       | path路径无效              | 请检查输入参数
20009       | path路径不存在            | 请检查输入参数

### 测试地址: 127.0.0.1

