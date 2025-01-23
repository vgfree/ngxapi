TOKEN='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTkwNDkyMzN9.sb2fNlWSjAKhDmR1Ua3QGG5DieRbmJEQlu7d83pE2XU'
curl -v -0 -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8090/storageManager/v1/getUsableDisk"
