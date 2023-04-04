# 1. Generate certs
```
sudo ./generateCerts.sh -d private-registry.com
```
> Lưu ý: Có thể thay đổi domain name trong file ***harbor.yml***. Nhưng option **-d** câu lệnh trên cũng cần thay đổi.

# 2. Prepare
```
sudo ./prepare.sh
```

# 3. Run
```
sudo ./install.sh
```

Truy cập domain **private-registry.com** hoặc domain đã config để vào trang quản trị của Harbor.