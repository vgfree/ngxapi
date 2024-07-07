TOKEN='eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE3MTk5MjgwODF9.fhwa9ckVyr2nwPxWmF54XKJwYHW60BBm24UoVap9yUw'
curl -v -0 -X POST -d '{"dev":"nvme0n1"}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8090/storageManager/v1/poolDiskAppend"
