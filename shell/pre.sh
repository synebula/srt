git checkout .
cd src/$1/src/main/resources  
sed -i 's/active: dev/active: pro/' application.yml 
sed -i 's/host: .\{1,3\}\..\{1,3\}\..\{1,3\}\..\{1,3\}/host: 127.0.0.1/' application.yml
sed -i 's/defaultZone: .*/defaultZone: http:\/\/127.0.0.1:9001\/eureka\//' application.yml 
sed -i 's/url: jdbc:mysql:.*:3306/url: jdbc:mysql:\/\/127.0.0.1:3306/' application-pro.yml
sed -i 's/username: .*/username: root/' application-pro.yml
sed -i 's/password: .*/password: Xzdc000)/' application-pro.yml
