#!/bin/bash
# Script for setup track location server 

#~~~~~~~~~~~~~~~~~~ variables ~~~~~~~~~~~~~~~~~~
htmlLink="https://raw.githubusercontent.com/studentota2lvl/trackUrl/master/index.html"
nginxConfLink="https://raw.githubusercontent.com/studentota2lvl/trackUrl/master/nginx.conf"
ngrokLink="https://github.com/studentota2lvl/trackUrl/blob/master/ngrok?raw=true"
ngrok_64Link="https://github.com/studentota2lvl/trackUrl/blob/master/ngrok_64?raw=true"
imageLink="https://raw.githubusercontent.com/studentota2lvl/trackUrl/master/image"
iconLink="https://raw.githubusercontent.com/studentota2lvl/trackUrl/master/favicon.ico"
logged_user=$(who | tr -d '\n'| cut -d' ' -f1);
workDir="~/trackUrl"

#~~~~~~~~~~~~~~~~~~ functions ~~~~~~~~~~~~~~~~~~
function createWorkdir() {
    mkdir -p $workDir && cd $_;
}

function installApp() {
    apt-get -y update;
    apt-get -y install nginx;
    touch /var/log/nginx/getUrl.com_access.log;
    touch /var/log/nginx/getUrl.com_error.log;
    service nginx enable;
    service nginx start;
}

function downloadFiles() {
    cd $workDir;
    wget $htmlLink -O ./index.html;
    wget $nginxConfLink -O ./nginx.conf;
    wget $ngrokLink -O ./ngrok;
    wget $ngrok_64Link -O ./ngrok_64;
    chmod 755 ./ngrok*;
    wget $imageLink -O ./image;
    wget $iconLink -O ./favicon.ico;
    chown -R $logged_user:$logged_user $workDir;
}

function prepareService() {
    publickIP=$(curl https://api.ipify.org/);
    cd $workDir;
    sed -i "s#localhost#$publickIP#g" ./index.html;
    cp ./index.html /var/www/html/index.html;
    cp -f ./nginx.conf /etc/nginx/sites-available/default;
    cp -f ./image /var/www/html/image;
    cp -f ./favicon.ico /var/www/html/favicon.ico;
    chown -R $logged_user:$logged_user /var/www/;
}

function updateService() {
    service nginx restart;
    cd $workDir;
    sleep 10;
    ./ngrok http 80;
}

function usage() {
    message="\t$(basename "$0") [-sh] [-i value] -- program to install and setup solution for get current position of someone \n
    \n\twhere:
    \n\t\t    -h, --help      \t\t show help
    \n\t\t    -s, --setup     \t full setup
    \n\t\t    -i, --image     \t set custom image to page, like '-i http://link/to/image'
    \n\t\t    -u, --update     \t update server (restart nginx and ngrok)
    \n
    \n\tif you don't specify any parameter, the solution will be restart."

    echo -e $message;
}

#~~~~~~~~~~~~~~~~~~~~ logic ~~~~~~~~~~~~~~~~~~~~
if [[ $EUID -ne 0 ]]; then
    printf "%s %s\n" "This script must be run as root, like: " "sudo ./script.sh";
    exit 1;
else
    while [ "$1" != "" ]; do
        case $1 in
            -s | --setup )  
                        createWorkdir
                        installApp
                        downloadFiles
                        prepareService
                        updateService
                        ;;
            -i | --image )
                        shift
                        imageLink=$1
                        ;;
            -h | --help )
                        usage
                        exit
                        ;;
            -u | --update )
                        updateService
                        exit
                        ;;
            * )         
                        usage
                        exit
                        ;;
        esac
        shift
    done
fi;