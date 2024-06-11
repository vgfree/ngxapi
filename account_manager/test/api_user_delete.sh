TOKEN='eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE3MTgwMjU1MDB9.Luw4keD8_RYyPArqz_Jk-n91x5pm0EoRVvu2IM3TPjE'
curl -v -0 -X DELETE -d '{"username":"13917951002"}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8080/accountManager/v1/userDelete"
