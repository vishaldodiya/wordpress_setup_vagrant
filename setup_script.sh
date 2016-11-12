#checking for PHP
echo "=====================================================================:php"

php=$(apt-cache policy php | grep "Installed" | awk -F' ' '{print $2}')

if test "$php" != "(none)";
then
    echo "Php is already installed"
else
    sudo apt install -y php
fi

#checking for mysql
echo "=====================================================================:mysql"

mysql=$(apt-cache policy mysql | grep "Installed" | awk -F' ' '{print $2}')

if test "$mysql" != "(none)";
then 
    echo "Mysql is already installed"
else
    sudo apt install -y mysql-server
fi

#checking for Nginx

echo "=====================================================================:nginx"

nginx=$(apt-cache policy nginx | grep "Installed" | awk -F' ' '{print $2}')

if test "$nginx" != "(none)";
then 
    echo "Nginx is already installed"
else
    sudo apt-get update
    sudo apt-get install -y nginx
  
fi

echo "============================================================================================"


echo "Please Enter Domain name:"
read domain

sudo mkdir -p /var/www/$domain
    
#sudo touch /var/www/$1/public_html/index.html
sudo touch /etc/nginx/sites-available/$domain

sudo chmod 775 /etc/nginx/sites-available/$domain
sudo chown -R www-data:www-data /etc/nginx/sites-available/$domain


sudo printf " server {
        listen   80; 
        listen   [::]:80;

	server_name example.com;        
	root /var/www/$domain;
        index index.html index.htm index.php;
	
	location / {
		try_files \$uri \$uri/ =404;
	}
        
}" > /etc/nginx/sites-available/$domain

#make symbolic link between sites-available and sites-enabled example.com file

sudo ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/$domain


sudo rm /etc/nginx/sites-enabled/default

#install wordpress on server

echo "===========================================================================:wordpress"

wget -c http://wordpress.org/latest.tar.gz

tar -xzvf latest.tar.gz

sudo rsync -av wordpress/* /var/www/$domain/

sudo touch /var/www/$domain/wp-config.php

echo "===========================================================================:wordpress done"

#granting permission
sudo chown -R www-data:www-data /var/www/$domain/
sudo chmod -R 775 /var/www/$domain/

#Adding Entry of /etc/hosts

sudo sed -i -e '1 i\127.0.0.1      '$domain /etc/hosts
#sudo sed -i -e 's/localhost/example.com/' /etc/hosts

#Setting up database configuration

sudo printf "<?php
	define('DB_NAME', '"$domain"'_db');
	define('DB_USER', 'root');
	define('DB_PASSWORD', '');
	define('DB_HOST', 'localhost');
	define('DB_CHARSET', 'utf8')
	define('DB_COLLATE', '');

	define('AUTH_KEY',         'put your unique phrase here');
	define('SECURE_AUTH_KEY',  'put your unique phrase here');
	define('LOGGED_IN_KEY',    'put your unique phrase here');
	define('NONCE_KEY',        'put your unique phrase here');
	define('AUTH_SALT',        'put your unique phrase here');
	define('SECURE_AUTH_SALT', 'put your unique phrase here');
	define('LOGGED_IN_SALT',   'put your unique phrase here');
	define('NONCE_SALT',       'put your unique phrase here');
		
	\$table_prefix  = 'wp_';

	define('WP_DEBUG', false);

	define('WP_HOME','http://$domain');
	define('WP_SITEURL','http://$domain');

	define( 'WP_AUTO_UPDATE_CORE', false );
	
	
?>" > /var/www/example.com/wp-config.php

#sudo cp /var/www/example.com/wp-config-sample.php /var/www/example.com/wp-config.php


#nginx service restart

sudo service nginx restart

#Removing temporary files

sudo rm /home/ubuntu/latest.tar.gz

sudo rm -r /home/ubuntu/wordpress

echo "+==================================================================+"
echo "||         Your Wordpress files are settled up                    ||"
echo "||you can now open your website to check server is working or not ||"
echo "+==================================================================+"
echo "||                           THANK YOU                            ||"
echo "+==================================================================+"


    
