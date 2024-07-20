TOKEN='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MjE0NzA4MzB9.NBtxwcTkucKT4XDtZnhD-O5wvnEsro2MoHUISbqTTq0'
curl -v -0 -X POST -d '{"nas_uuid":"03000200-0400-0500-0006-000700080009","identity":"13917951002","verification_code":"666666"}' -H "Authorization: Bearer $TOKEN" "http://127.0.0.1:8090/accountManager/v1/deviceActive"
