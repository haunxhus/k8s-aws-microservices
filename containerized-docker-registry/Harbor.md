# **Harbor - Private Repository**
# **I.Mở đầu**
Toàn bộ quá trình làm gần như mình tham khảo chỉ và làm theo [link hướng dẫn](https://blog.vietnamlab.vn/habor/#:~:text=Gi%E1%BB%9Bi%20thi%E1%BB%87u%20Harbor,-B%E1%BA%A1n%20c%C3%B3%20%C4%91ang&text=Harbor%20l%C3%A0%20m%E1%BB%99t%20open%20source,v%C3%A0%20kh%E1%BA%A3%20n%C4%83ng%20t%C6%B0%C6%A1nng%20t%C3%A1c.)  
Phần bên dưới là phần:
- Tổng hợp (chủ yếu là copy lại bài tại link trên vs một số bài viết khác - sợ lúc nào web down lại k xem được :))))
- Lưu ý (fix lỗi nếu nó không chạy được hay chạy không đúng)

# **II. Tổng quan**
```
Harbor là một open source cloud native registry giúp xây dựng private docker-registry dùng để pull, push images một cách bảo mật, tính năng tạo project, tạo user, add user vào project.
```
``Đoạn dưới mình copy từ bài khác vì thấy nó rất dễ hiểu ``  
> &nbsp;&nbsp;Thông thường khi bạn có máy client đã cài docker, thì có thể thực hiện các thao tác trên đó với docker như docker pull để download docker image.  

> &nbsp;&nbsp;Khi thực hiện câu lệnh **docker pull** --> **docker client** sẽ thực hiện kết nối tới **docker hub** mặc định để tìm kiếm và pull docker image đó về máy client.  

> &nbsp;&nbsp;**Docker Hub** là dịch vụ của Docker cho việc tìm kiếm và chia sẻ các Docker Image dành cho mọi người. 

> Tuy nhiên khi bạn triển khai một dự án và yêu cầu phải có **Docker Registry** cho riêng mình, hoặc do điều kiện không cho phép có kết nối ra ngoài Internet để download từ **Docker Hub**.  
=> Lúc đó bạn sẽ nghĩ đến việc cần xây dựng một **Docker Registry** riêng. **Private Docker Registry** sẽ giúp bạn quản lý các Docker Image và chia sẻ với mọi người trong team. Nó cũng giúp việc chia sẻ/tải về các Docker Image chỉ dùng kết nối nội bộ mà không yêu cầu phải có kết nối internet.  

> Và **Harbor** là một open source giúp xây dựng **Private Docker Registry**.

# **III. Setup**
## **1. Chuẩn bị môi trường**
&nbsp;&nbsp;Phần này là cài đặt trên ***Ubuntu***. Đối với windows có thể chạy ***Vmware*** hoặc sử dụng ***Ubuntu LTS on Windows***.  
&nbsp;&nbsp;Cá nhân mình sử dụng ***Ubuntu LTS on Windows***.
- python > 2.7
- docker, docker-compose
- openssl

## **2. Cài đặt** 
### **2.1 Tạo ssl certificate cho registry**
1. Tạo thư mục chứa certificate file
```
sudo mkdir certs/
cd certs/
```

2. Tạo CA (Certificate Authority)
```
sudo openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout ca.key \
    -x509 -days 365 -out ca.crt
```

3. Yêu cầu Certificate Signing Request  
&nbsp;&nbsp;&nbsp;Nếu dùng domain cho registry thì có lưu ý là mục Common Name (CN) trong khi nhập phải là domain muốn dùng. Còn nếu dùng ip cho registry thì nhập bất kì tùy thích.
```
sudo openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout yourdomain.com.key \
    -out yourdomain.com.csr
```

4. Tạo certificate cho registry host  
&nbsp;&nbsp;&nbsp;Nếu dùng domain
```
sudo openssl x509 -req -days 365 -in yourdomain.com.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out yourdomain.com.crt
```

5. Nếu dùng IP, thay IP muốn dùng sau dòng IP
```
echo subjectAltName = IP:35.xxx.xxx.xxx > extfile.cnf

sudo openssl x509 -req -days 365 -in yourdomain.com.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extfile extfile.cnf -out yourdomain.com.crt
```

6. Ở mỗi docker host muốn sử dụng registry này, copy file ca.crt vào đường dẫn sau /etc/docker/certs.d/[domain_OR_ip]/ca.crt  
``Ở đây mình đang dùng IP và thự hiện test trên máy hiện tại luôn (Các docker host khác muốn pull image từ docker-registry này thì cũng tạo đường dẫn và file như bên dưới)``
```
cp /path/to/certs/ca.crt /etc/docker/certs.d/35.xxx.xxx.xxx/ca.crt
```
&nbsp;&nbsp;&nbsp; Bước này giúp các docker host trust certificate mà chúng ta sẽ dùng cho registry.

### **2.2 Cấu hình và khởi động Harbor**
> ``- Đối với version mới sau này config có chút khác biệt so với version cũ.``  
> ``Thành thực trong quá trình tìm hiểu mình toàn config theo link hướng dẫn trên nên sử dụng version v1.6 lúc sau vào doc mới thấy h có tới tận v2.7. Hên là sau khi setup version 1.6 xong cũng hiểu qua chút nên cũng không có vấn đề.``  
> ``- Cá nhân mình không rõ phần config mới này băt đầu từ version nào. Mình đã check thử với v2.0.5 nó đã theo thay đổi cách config mới rồi nên mình sẽ tạm gọi phần config mới là cho >v2.0.5``  
> ``(Thực ra đoạn config không thay đổi mấy đâu - có tí tí khác chú thôi)``

### **2.2.1 Setup cho version cũ**
### 1. Quay lại máy muốn chạy Harbor, tải bộ cài tại https://github.com/goharbor/harbor/releases rồi giải nén
```
sudo wget https://storage.googleapis.com/harbor-releases/release-1.6.0/harbor-online-installer-v1.6.0.tgz

tar xvf harbor-online-installer-v1.6.0.tgz

cd harbor/
```

### 2. Chỉnh sửa file ***harbor.cfg*** với các config cơ bản
```
sudo vi harbor.cfg
# domain hoặc ip muốn dùng cho registry
hostname = 35.xxx.xxx.xxx

# giao thức kết nối UI Harbor
ui_url_protocol = https
......
# Đường dẫn đến 2 file certificate .crt và .key đã tạo phía trên
ssl_cert = /path/to/certs/yourdomain.com.crt
ssl_cert_key = /path/to/certs/yourdomain.com.key

# Đường dẫn chứa secret của các container
secretkey_path = /data
```
> Config đường dẫn chứa secret của các container nên để default là ***/data*** vì có thể sẽ có phiên bản code harbor lỗi không tự động đọc được config này - theo [issue](https://github.com/goharbor/harbor/issues/2208#issuecomment-299098799)

### 3. Chạy script cài đặt và khởi động các container
```
sudo ./install.sh
```
&nbsp;&nbsp;&nbsp; Trường hợp lệnh trên không chạy được thì thực hiện theo [issue](https://github.com/goharbor/harbor/issues/2317) bên dưới.
```
sudo -E env "PATH=$PATH" ./install.sh
```
> Chú ý: Nếu bạn muốn cài đặt các dịch vụ Notary, Clair và chart bạn phải chỉ định các tham số tương ứng
```
sudo -E env "PATH=$PATH" ./install.sh --with-notary --with-clair --with-chartmuseum
```
&nbsp;&nbsp;&nbsp; Để hiểu về Notary và Docker Content Trust bạn tham khảo tài liệu [https://docs.docker.com/engine/security/trust/content_trust/](https://docs.docker.com/engine/security/trust/content_trust/)  
&nbsp;&nbsp;&nbsp; Để hiểu về Clair, bạn hãy tham khảo Clair's documentation [https://coreos.com/clair/docs/2.0.1/](https://coreos.com/clair/docs/2.0.1/)

### 4. Sau khi chạy thành công truy cập vào domain hoặc ip đã dùng cho registry trên trình duyệt để vào Harbor UI http://35.xxx.xxx.xxx/ || http://yourdomain.com/

> Nếu gặp lỗi **502 Bad Gateway** thì nên check lại config **secretkey_path** - config này nên để default là **/data** theo như lưu ý ở trên
> Sửa lỗi
```
# Stop container
docker-compose down

# Update lại config
secretkey_path = /data

# Run container
docker-compose up -d
```

### **2.2.2 Setup cho version mới**
### Mình sẽ sử dụng version v2.7.0
### 1. Tải bộ cài và giải nén
&nbsp;&nbsp;&nbsp; Có thể chọn và tải bộ cài tại link [https://github.com/goharbor/harbor/tags](https://github.com/goharbor/harbor/tags)  
```
sudo wget https://github.com/goharbor/harbor/releases/download/v2.7.0/harbor-offline-installer-v2.7.0.tgz

sudo tar xvf harbor-offline-installer-v2.7.0.tgz

cd harbor
```

### 2. Đổi tên file
```
sudo cp harbor.yml.tmpl harbor.yml
```

### 3. Cấu hình file **harbor.yml**
```
# Cấu hình hostname hoặc ip để truy cập admin-ui và registry service
hostname: yourdomain.com

# https related config
https:
  # https port for harbor, default is 443
  port: 443
  # The path of cert and key files for nginx
  certificate: /path/to/certs/yourdomain.com.crt
  # Ex: /home/ducbinh/certs/yourdomain.com.crt
  private_key: /path/to/certs/yourdomain.com.key
  # Ex: /home/ducbinh/certs/yourdomain.com.key
```
> Ngoài ra trong file còn có nhiều cấu hình khác - cái này m.n có thể tự tìm hiểu để cấu hình theo ý mình nhá.

### 3. Chạy script cài đặt và khởi động các container
```
sudo ./install.sh
```

### 4. Sau khi chạy thành công truy cập vào domain hoặc ip đã dùng cho registry trên trình duyệt để vào Harbor UI http://35.xxx.xxx.xxx/ || http://yourdomain.com/
> ``Nếu có lỗi 502 Bad Gateway bạn có thể tham khảo phần chạy script và fix lỗi của phần version cũ bên trên`` 

> ``Đoạn này hơi thừa: nhưng nếu m.n gặp lỗi truy cập hay lỗi nào đó đều có thể đọc log và trace từ các container harbor đang chạy hoặc trong thư mục **/var/log/harbor**``

> ``Cuối cùng dù setup config như nào thì khi chạy lên vẫn sẽ có một file **docker-compose.yml** được tạo ra. M.n có thể vọc về các container trong file này.``  

> ``Ak m.n cũng có thể vọc xem harbor lưu dũ liệu như nào ở folder (cái này ăn theo config) default là: **/data**`` 

# **IV. Truy cập, Thao tác và Cách setup dự án**
``Không biết nói sao nhưng sự thực là phần này mình thấy khá thừa mọi người có thể đọc document or có nhiều bài hướng dẫn rồi or . . . . . . . tự nghịch :))``

> Bình thường mình sẽ hay nói như trên, nhưng ở bài này mình sẽ tổng hợp một vài ý chính để thao tác setup project bình thường ``- đa phần cũng là đi copy ^_^``

## **1. Login**
- Truy cập vào Harbor UI http://35.xxx.xxx.xxx/ || http://yourdomain.com/  
Account admin: **admin/Harbor12345**  
(Nếu config ***harbor_admin_password:*** thì cần check lại config)

- Create user: Chọn **Administration/Users** - thanh navidation bên trái.  
  Create user: **demoUser/DemoUser@123**

- Create Project: Chọn **Projects** - thanh navidation bên trái.  
  Create Project: **DemoProject** - private

- Chọn **DemoProject** sau đó chọn **Members**  
  Add user: **demoUser** (ProjectAdmin) - Ở bước này cần chọn role trong project của User ([link document](https://goharbor.io/docs/2.7.0/administration/managing-users/))
  ```
  Có 5 roles chính
    - Limited Guest: được pull, không được push và không thấy được log project.
    - Guest: được pull và thay đổi tag nhưng không được push image.
    - Developer: được pull và push image.
    - Maintainer: được scan image, view replications jobs, and delete images and helm charts.
    - ProjectAdmin: có thêm quyền quản lý. Ex: quản lý member, . . .
  ```

- Sau khi add member vào project. Tùy theo role, member có thể pull/push image.  
Làm thử theo hướng dẫn
```
# pull image ở docker hub
$ docker pull ubuntu:16.04

# Làm theo hướng dẫn ở Harbor để thay đổi tên image
# 35.xxx.xxx.xxx là ip or domain name đã config tại các bước trên
$ docker tag ubuntu:16.04 35.xxx.xxx.xxx/kube-demo/my-ubuntu

# Kiểm tra tên đã đổi chưa
$ docker images

# Login vào docker-registry (harbor)
$ docker login -u demoUser -p DemoUser@123 35.xxx.xxx.xxx
Login Succeeded

# Push image to Harbor
$ docker push 35.xxx.xxx.xxx/kube-demo/my-ubuntu

# Pull image từ docker host khác/hoặc xoá image trên host hiện tại để test pull image từ Harbor
$ docker rmi 35.xxx.xxx.xxx/kube-demo/my-ubuntu

# confirm delete
$ docker images

# pull image from Harbor
$ docker pull 35.xxx.xxx.xxx/kube-demo/my-ubuntu
```

`` - Bên trên là phần setup cơ bản nhất để có được một project và sử dụng Harbor một cách bình thường.``  
`` - Đối với những case/yêu cầu đặc biệt thì tùy phần sẽ có cách xử lý riêng - và vì nó khá đặc thù trong từng case/yêu cầu nên sẽ không xuất hiện trong phần này.``  
`` => Tuy vậy một chút chia sẻ kinh nghiệm của mình nếu gặp các case/yêu cầu này (hi vọng sẽ có ích) sẽ là: ``  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; `` -> Xác định xem công nghệ mình - version sử dụng có feature đáp ứng được không``  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; `` -> Nếu có thì ok nghịch thử or tìm phần hướng dẫn để setup``  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; `` Nếu không thì hãy thử tận dụng những gì đang có của công nghệ đấy kết hợp/biến đổi nó sao cho làm ra được một cái có chức năng tương tự đáp ứng được cái mình cần - cái này cũng cần tính toán về độ phức tạp và tài nguyên cần có.``  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ``-> Còn nếu thực sự không thể, or nếu phần tận dụng tốn quá nhiều tài nguyên so với cái khác mà bắt buộc phải có chức năng đấy ^_^.  Thì . . . ^_^ ^_^ ^_^ . . . Đọc và làm theo cả đoạn trên rồi mà còn đọc được dòng này thì . . . ^_^. ``  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ``Nhưng đây cũng là kinh nghiệm khi lựa chọn một công nghệ nào đấy trước khi lựa chọn để build lên phần nào đấy ^_^.``
  
`` => Bên trên là một chút kinh nghiệm của bản thân mình đối với những case/yêu cầu không phải cơ bản, phải tìm hiểu nhiều hơn - hi vọng sẽ có ích. Nếu trong thời gian tới được xử lý những case/yêu cầu khác đối với Harbor thì mình sẽ update tiếp.``



