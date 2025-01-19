TOKEN='eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE3MzcxNzAyODl9.tNrNvJkwvUrd7-zyAC_EsNDe3-mlB_t3oz4zcTXeTtA'
curl -v -0 -X POST -d '{"username":"13917951002"}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8090/accountManager/v1/userAccept"
