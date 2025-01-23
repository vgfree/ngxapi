TOKEN='eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE3Mzc0Njc2NjksInBhc3N3b3JkIjoibG92ZUAxMjM0NTYiLCJ1c2VybmFtZSI6IjEzOTE3OTUxMDAyIn0.nIa4wdlv2cQfacDSPKiy_r6YL75nXl38Rckym9I4_7g'
curl -v -0 -X PUT -d '{"path":"test1","isDir":false}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8090/fsystemManager/v1/optCreate"
