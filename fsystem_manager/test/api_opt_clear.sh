TOKEN='eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE3Mzc0NTUxNTMsInBhc3N3b3JkIjoibG92ZUAxMjM0NTYiLCJ1c2VybmFtZSI6IjEzOTE3OTUxMDAyIn0.Sz04rrOpgOcbVghQ3jiiPpVyFr71w8sXDL2a4_sPJpg'
curl -v -0 -X DELETE -d '{"path":"tools"}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8090/fsystemManager/v1/optClear"
