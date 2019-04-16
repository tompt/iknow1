apt update && apt upgrade -y;
apt install openssh -y mariadb-server mariadb-client -y;
mysql_secure_installation;
echo "abrir o mysql ao mundo";
sed -i 's/^bind-address/#bind-address/' /etc/mysql/mariadb.conf.d/50-server.cnf;
systemctl restart mariadb.service;

read -s -p "Passe para o MySQL do admin:" mysqlPass;
read -s -p "Passe para o user CRIPTO:" mysqlCRIPTO;
mysql --user="root" --password -e "CREATE USER 'cripto'@'%' IDENTIFIED BY '$mysqlCRIPTO';";
mysql --user="root" --password -e "CREATE USER 'cripto'@'localhost' IDENTIFIED BY '$mysqlCRIPTO';";
mysql --user="root" --password --database="mysql" --execute="GRANT ALL PRIVILEGES ON *.* TO 'cripto'@'%' IDENTIFIED BY '$mysqlCRIPTO'; FLUSH PRIVILEGES;"
mysql --user="root" --password --database="mysql" --execute="GRANT ALL PRIVILEGES ON *.* TO 'cripto'@'%' IDENTIFIED BY '$mysqlCRIPTO'; FLUSH PRIVILEGES;"



echo "--nginx --";
apt install nginx -y;
apt install php-fpm php-cgi php-common php-pear php-mbstring -y;

su -c 'echo "" |tee /var/www/html/info.php';
chown www-data:www-data /var/www/html/info.php;
echo "--//nginx -- ";




echo "# — certificados — #";
mkdir /etc/nginx/ssl;
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt;
echo “chaves listadas em baixo? estao em /etc/nginx/ssl”;

ls /etc/nginx/ssl/;
echo “gerar certificados – parte 2”;
openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048;
echo "# -//certificados - #";

echo "escrever ficheiro de configuracao. Porto 80 não oferece nada demais. Ideia é futuramente fechar para 443 apenas";
cat > /etc/nginx/sites-enabled/default << "EOF"
server {
        listen 80;
        listen [::]:80;
        root /var/www/html;

        error_log /var/www/error.log error;
        access_log /var/www/access.log;
        index index.php index.htm index.html;

        server_name example.com www.example.com;

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        }

        #optimize static file serving
        location ~* \.(jpg|jpeg|gif|png|css|js|ico|xml)$ {
        access_log off;
        log_not_found off;
        expires 30d;
        }
}

server {
 listen 443 ssl http2 default_server;
 listen [::]:443 ssl http2 default_server;
 #ssl on;
 server_name _; #$domain_name

 ssl_certificate /etc/nginx/ssl/nginx.crt;
 ssl_certificate_key /etc/nginx/ssl/nginx.key;

 ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
 ssl_prefer_server_ciphers on;
 ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
 ssl_dhparam /etc/nginx/ssl/dhparam.pem;
 ssl_session_cache shared:SSL:20m;
 ssl_session_timeout 180m;

 resolver 8.8.8.8 8.8.4.4;
 add_header Strict-Transport-Security "max-age=31536000";

 root /var/www/html;
 index index.php index.html index.htm;

 error_page 404 /404.html;
 error_page 500 502 503 504 /50x.html;

 location / {
 try_files $uri $uri/ =404;
 }

 location = /50x.html {
 root /var/www/html;
 }
 # Error & Access logs
 error_log /var/www/error.log error;
 access_log /var/www/access.log;

location ~ \.php(?:$|/) {
 include snippets/fastcgi-php.conf;
 fastcgi_split_path_info ^(.+\.php)(/.+)$;
 #include fastcgi_params;
 fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
 fastcgi_param PATH_INFO $fastcgi_path_info;
 fastcgi_param HTTPS on;
 fastcgi_pass unix:/run/php/php7.2-fpm.sock;
 }

# optimize static file serving
 location ~* \.(jpg|jpeg|gif|png|css|js|ico|xml)$ {
 access_log off;
 log_not_found off;
 expires 30d;
 }
}
EOF
echo "# --------------- fim de escrita de ficheiro ---------------------#";

systemctl restart nginx.service;


echo "# ---------------------- phpmyadmin -----------------------------#";
apt install phpmyadmin php-gettext -y;

# link simpolico
ln -s /usr/share/phpmyadmin /var/www/html;

curl localhost/info.php;

systemctl restart php7.2-fpm;
systemctl restart nginx;
echo "# ---------------------- // phpmyadmin -----------------------------#";

echo "Ultimos comandos para phpmyadmin poder correr sem apresentar erros";
mysql --user="root" --password -e "use mysql;update user set plugin='' where User='root';flush privileges;exit";
systemctl restart mariadb.service;
service --status-all;


echo "outros:";
dhclient -r enp0s8;
dhclient enp0s8;
