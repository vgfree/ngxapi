TOKEN='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTg2NDMyNjh9.DBTkohGMx4FyzAY4QW0eACBmvA3np0xqC2Gdt5zJBfY'
curl -v -0 -X POST -d '{"secret":"88888888"}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8090/accountManager/v1/adminModify"
