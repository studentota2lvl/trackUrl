#!/bin/bash

#~~~~~~~~~~~~~~~~~~ variables ~~~~~~~~~~~~~~~~~~
htmlLink="https://raw.githubusercontent.com/studentota2lvl/trackUrl/master/index.html"
nginxConfLink="https://raw.githubusercontent.com/studentota2lvl/trackUrl/master/nginx.conf"
ngrokLink="https://github.com/studentota2lvl/trackUrl/blob/master/ngrok?raw=true"
ngrok_64Link="https://github.com/studentota2lvl/trackUrl/blob/master/ngrok_64?raw=true"
imageLink="https://raw.githubusercontent.com/studentota2lvl/trackUrl/master/image"
iconLink="https://raw.githubusercontent.com/studentota2lvl/trackUrl/master/favicon.ico"

#~~~~~~~~~~~~~~~~~~ functions ~~~~~~~~~~~~~~~~~~
function installApp() {
    apt-get -y update;
    apt-get -y install nginx;
    service nginx enable;
    service nginx start;
}

function downloadFiles() {
    wget $htmlLink -O ./index.html;
    wget $nginxConfLink -O ./nginx.conf;
    wget $ngrokLink -O ./ngrok;
    wget $ngrok_64Link -O ./ngrok_64;
    wget $imageLink -O ./image;
    wget $iconLink -O ./favicon.ico;

function prepareService() {
    cp ./index.html /var/www/html/index.html;
    cp -f ./nginx.conf /etc/nginx/sites-available/default;
    cp -f ./image /var/www/html/image;
    cp -f ./favicon.ico /var/www/html/favicon.ico;
    exit
}

function updateService() {
    service nginx restart;
    sleep 10;
    ./ngrok http 80;
    exit 
}

function createWorkdir() {
    mkdir -p ~/trackUrl && sd $_;
    exit
}

function usage() {
    message="$(basename "$0") [-sh] [-i value] -- program to install and setup solution for get current position of someone

    where:
        -h, --help      show help
        -s, --setup     full setup
        -i, --image     set custom image to page, like -i http://link/to/image

    if you don't specify any parameter, the solution will be restart."

    echo $message;
    exit
}

#~~~~~~~~~~~~~~~~~~~~ logic ~~~~~~~~~~~~~~~~~~~~
if [[ $EUID -ne 0 ]]; then
    printf "%s %s\n" "This script must be run as root, like: " "sudo ./script.sh";
    exit 1;
else
    while [ "$1" != "" ]; do
        case $1 in
            -s | --setup )  createWorkdir
                            installApp
                            downloadFiles
                            prepareService
                            updateService
                            ;;
            -i | --image )  shift
                            imageLink=$1
                            ;;
            -h | --help )   usage
                            exit
                            ;;
            * )             updateService
                            exit
        esac
        shift
    done
fi;