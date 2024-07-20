TOKEN='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MjAzMjYwNTJ9.Mdw8pDPLRnSezYUcVL_Gf7D6hvAY3M86tCdvW0yaw9Y'
curl -v -0 -X POST -d '{"nas_uuid":"03000200-0400-0500-0006-000700080009","identity":"13917951002"}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8090/manageCenter/v1/getVerificationCode"
