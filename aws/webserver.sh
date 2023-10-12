#!/bin/bash
# Provision EC2 instance with NGINX webserver

apt-get -y update
apt-get -y install nginx
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx on server ${HOSTNAME} !</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx on server ${HOSTNAME} !</h1>
<p>If you see this page, the nginx web server is successfully installed and
working.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
EOF
