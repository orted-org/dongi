NGINX_CONFIG_FILE=/etc/nginx/sites-available/default

# Install Docker
installDocker() {
    sudo apt update
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    sudo apt update
    sudo apt install docker-ce
    sudo usermod -aG docker ${USER}
    su - ${USER}
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

# Install and set UFW
firewallInit() {
    sudo ufw enable
    sudo ufw allow ssh
    sudo ufw allow http
    sudo ufw allow https
}

# Install Nginx
installNginx() {
    sudo apt install nginx
}

# Install Certbot
certbotInit() {
    sudo add-apt-repository ppa:certbot/certbot
    sudo apt-get update
    sudo apt-get install python3-certbot-nginx
}
# Set Nginx Configuration
setNginxConfiguration() {
    read -p "Enter The Application Port " PORT
    read -p "Enter The Servers " SERVERS
    STR="$(cat ./defNginxConfig.txt)"
    FINAL="$(printf "${STR}" "${SERVERS}" "${PORT}")"
    echo "${FINAL}" >"${NGINX_CONFIG_FILE}"
    sudo nginx -t
    sudo service nginx restart
}
setCertbot() {
    read -p "Enter The Locations for SSL Separated By Spaces " LOC
    FINAL=$(echo "${LOC}" | sed 's/ / -d /g')
    certbot --nginx -d "${FINAL}"
}
installDocker
firewallInit
installNginx
setNginxConfiguration
certbotInit
setCertbot
