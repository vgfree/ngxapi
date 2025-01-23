TOKEN='eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6IjEzOTE3OTUxMDAyIiwicGFzc3dvcmQiOiJsb3ZlQDEyMzQ1NiIsImV4cCI6MTczNzM4NDExNX0.Py-QzuL3doh0pEkYYaqw86qVHXTKrADOIWeF8NpWzcI'
curl -v -0 -X DELETE -d '{"path":"test"}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8090/fsystemManager/v1/optDelete"
