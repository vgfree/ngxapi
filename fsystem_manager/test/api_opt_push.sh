TOKEN='eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6IjEzOTE3OTUxMDAyIiwiZXhwIjoxNzM3NTM1NTQwLCJwYXNzd29yZCI6ImxvdmVAMTIzNDU2In0.egNiUYs1VGY7jSqKDwEenoHNG4J-fi12SrG8UmnClFE'
curl -v -0 -X PUT -F 'path=xxxx.jpeg' -F "file=@./example.jpeg" -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8090/fsystemManager/v1/optPush"

