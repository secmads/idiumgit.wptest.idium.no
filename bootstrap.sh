#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y python-software-properties
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:git-core/ppa
sudo apt-get install -y zip unzip
sudo apt-get update
sudo LC_ALL=C.UTF-8 apt-get install -y php7.2 php-memcached php7.2-gd php7.2-mysql php7.2-curl php7.2-cli php7.2-cgi php7.2-dev php7.2-simplexml php7.2-soap php7.2-mbstring php7.2-fpm php-gettext
sudo LC_ALL=C.UTF-8 apt-get install -y apache2 libapache2-mod-php7.2
ln -fs /wp-site /var/www/wp-site

upload_max_filesize=2G
post_max_size=2G
for key in upload_max_filesize post_max_size 
do
 sudo sed -i "s/^\($key\).*/\1 = $(eval echo \${$key})/" /etc/php/7.2/apache2/php.ini
done

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get install -y mysql-client-5.7 mysql-client-core-5.7 mysql-server-5.7

mysql -u root -proot -e "DROP USER ''@'localhost';"
mysql -u root -proot -e "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'root'"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart

sudo apt-get install -y git-core

WPPlatformGitURL=gitlab.idium.no/wp-platform/
WPManagerURL=wpmanager.idium.no/
login=vagrant
password=0GP31Xx7kRvo2wzI
devDomain=wp.localhost

cd /usr/local/share
sudo mkdir wordpress
cd wordpress

sudo git clone https://$login:$password@${WPPlatformGitURL}idium-wp-libraries.git ./libs
sudo git clone https://$login:$password@${WPPlatformGitURL}wordpress.git ./core

cd libs
sudo php -r "readfile('https://getcomposer.org/installer');" | sudo php
sudo mv composer.phar /usr/local/bin/composer
sudo composer update --no-dev
sudo composer install --no-dev
cd ..

sudo ln -s /usr/local/share/wordpress/libs/configs/wordpress.php core/wp-config.php

sudo cat > /etc/apache2/sites-available/wp-site.conf << EOF

<Directory /var/www>
    AllowOverride All
</Directory>

<Directory /usr/local/share/wordpress>
    Require all granted
</Directory>

Include /usr/local/share/wordpress/libs/configs/apache.conf

<VirtualHost *:80>
    ServerAdmin webmaster@localhost

    DocumentRoot /var/www/wp-site

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    #shared core code
    Alias /wp-admin /usr/local/share/wordpress/core/wp-admin
    Alias /wp-includes /usr/local/share/wordpress/core/wp-includes
    Alias /wp-links-opml.php /usr/local/share/wordpress/core/wp-links-opml.php
    Alias /wp-mail.php /usr/local/share/wordpress/core/wp-mail.php
    Alias /wp-trackback.php /usr/local/share/wordpress/core/wp-trackback.php
    Alias /wp-cron.php /usr/local/share/wordpress/core/wp-cron.php
    Alias /wp-load.php /usr/local/share/wordpress/core/wp-load.php
    Alias /xmlrpc.php /usr/local/share/wordpress/core/xmlrpc.php
    Alias /wp-activate.php /usr/local/share/wordpress/core/wp-activate.php
    Alias /wp-comments-post.php /usr/local/share/wordpress/core/wp-comments-post.php
    Alias /wp-login.php /usr/local/share/wordpress/core/wp-login.php
    Alias /wp-signup.php /usr/local/share/wordpress/core/wp-signup.php
    Alias /index.php /usr/local/share/wordpress/core/index.php
    Alias /wp-blog-header.php /usr/local/share/wordpress/core/wp-blog-header.php
    #shared core code end
</VirtualHost>
EOF

sudo a2ensite wp-site
sudo a2dissite 000-default

sudo a2enmod rewrite

sudo service apache2 reload

cd /wp-site

instanceName=`git config --get remote.origin.url`
instanceName=${instanceName##*/}
instanceName=${instanceName%%.git}

sudo -u www-data wget --http-user=$login --http-password=$password -O $instanceName https://${WPManagerURL}api.php?module=instance\&method=downloadDb\&dbName=$instanceName
mysql -u root -proot -e "CREATE DATABASE \`wp_unit\`;"
mysql -u root -proot -e "CREATE DATABASE \`$instanceName\`;"
mysql -u root -proot -h localhost $instanceName < $instanceName
sudo -u www-data rm $instanceName
mysql -u root -proot -e "USE $instanceName;UPDATE wp_options SET option_value='http://${devDomain}:8080' WHERE option_name IN ('siteurl', 'home');"

sed -i "s/\(define[(]'DB_USER',[ ]*'\?\)[^')]*\('\?[)]\)/\1root\2/i" wp-config.php
sed -i "s/\(define[(]'DB_PASSWORD',[ ]*'\?\)[^')]*\('\?[)]\)/\1root\2/i" wp-config.php
sed -i "s/\(define[(]'DB_HOST',[ ]*'\?\)[^')]*\('\?[)]\)/\1localhost\2/i" wp-config.php

isMultisiteInstance=`sed -n "s/\(define[(]'MULTISITE',[ ]*'\?\)\([a-zA-Z0-9_-]*\)\('\?);\)/\2/p" wp-config.php | tr -d "\r"`
if [ "$isMultisiteInstance" = "true" ]
then
    isSubdomainInstall=`sed -n "s/\(define[(]'SUBDOMAIN_INSTALL',[ ]*'\?\)\([a-zA-Z0-9_-]*\)\('\?);\)/\2/p" wp-config.php | tr -d "\r"`
    currentBlogID=`sed -n "s/\(define[(]'BLOG_ID_CURRENT_SITE',[ ]*'\?\)\([a-zA-Z0-9_-]*\)\('\?);\)/\2/p" wp-config.php | tr -d "\r"`

    sed -i "s/\(define[(]'DOMAIN_CURRENT_SITE',[ ]*'\?\)[^')]*\('\?[)]\)/\1${devDomain}:8080\2/i" wp-config.php

    mysql -u root -proot $instanceName -e "UPDATE wp_site SET domain='${devDomain}:8080' WHERE id=1;"
    mysql -u root -proot $instanceName -e "UPDATE wp_sitemeta SET meta_value='http://${devDomain}:8080' WHERE meta_key='siteurl';"

    blogs=(`mysql -ss -u root -proot $instanceName -e "SELECT blog_id FROM wp_blogs WHERE site_id = 1 ORDER BY blog_id ASC;"`)

    if [ "$isSubdomainInstall" == "true" ]
    then
        # generate subdomain for each subsite
        for blogIndex in ${!blogs[*]}
        do
            if [ "$currentBlogID" = "${blogs[$blogIndex]}" ]
            then
                mysql -u root -proot $instanceName -e "UPDATE wp_blogs SET domain='${devDomain}:8080' WHERE blog_id = ${blogs[$blogIndex]};"
            else
                mysql -u root -proot $instanceName -e "UPDATE wp_blogs SET domain='site${blogIndex}.${devDomain}:8080' WHERE blog_id = ${blogs[$blogIndex]};"
                mysql -u root -proot $instanceName -e "UPDATE wp_${blogs[$blogIndex]}_options SET option_value='http://site$(($blogIndex)).${devDomain}:8080' WHERE option_name IN ('siteurl', 'home');"
            fi
        done

        cookieDomain=`sed -n "s/\(define[(]'COOKIE_DOMAIN',[ ]*'\?\)\([a-zA-Z0-9_-$.:]*\?\)\('\?);\)/\2/p" wp-config.php | tr -d "\r"`
        if [ "$cookieDomain" != "" ]
        then
            sed -i "s/\(define[(]'COOKIE_DOMAIN',\)\([^)]*\)/\1''/i" wp-config.php
        else
            sed -i "s/\(define[(]'WP_ALLOW_MULTISITE',[ ]*\)/define('COOKIE_DOMAIN', '');\n\n\1/i" wp-config.php
        fi
    else
        # all subsites have the same domain
        mysql -u root -proot $instanceName -e "UPDATE wp_blogs SET domain='${devDomain}:8080' WHERE site_id = 1;"

        blogsPaths=(`mysql -ss -u root -proot $instanceName -e "SELECT path FROM wp_blogs WHERE site_id = 1 ORDER BY blog_id ASC;"`)

        for blogIndex in ${!blogs[*]}
        do
            if [ "$currentBlogID" != "${blogs[$blogIndex]}" ]
            then
                mysql -u root -proot $instanceName -e "UPDATE wp_${blogs[$blogIndex]}_options SET option_value='http://${devDomain}:8080${blogsPaths[$blogIndex]}' WHERE option_name IN ('siteurl', 'home');"
            fi
        done
    fi
fi

# make sure that nobody accidentaly commit wp-config.php
git update-index --assume-unchanged wp-config.php

# install git-lfs
wget -O git-lfs.deb http://staging.wordpress.idium.no/artifacts/git-lfs.deb
sudo dpkg -i git-lfs.deb
rm git-lfs.deb
git lfs install
echo "https://${login}:${password}@gitlab.idium.no" > ~/.git-credentials
git config credential.helper store

sudo iptables -t nat -A OUTPUT -o lo -p tcp --dport 8080 -j REDIRECT --to-port 80

#cleanup box
apt-get -y autoremove