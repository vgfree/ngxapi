TOKEN='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzc1NDg3MjgsInBhc3N3b3JkIjoibG92ZUAxMjM0NTYiLCJ1c2VybmFtZSI6IjEzOTE3OTUxMDAyIn0.puJf2_XpPu3yZy02eKbHNqYJr-Is9spDuGwDkLVudFI'
curl -v -0 -X PUT -F 'chunkIndex=1' -F 'totalChunks=2' -F 'UUID=a12345' -F "file=@./1.jpeg" -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8090/fsystemManager/v1/optSlicePush"
curl -v -0 -X PUT -F 'chunkIndex=2' -F 'totalChunks=2' -F 'UUID=a12345' -F "file=@./2.jpeg" -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8090/fsystemManager/v1/optSlicePush"
curl -v -0 -X POST -d '{"path":"open/abc", "UUID":"a12345", "totalChunks":2}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8090/fsystemManager/v1/optSliceComplete"

