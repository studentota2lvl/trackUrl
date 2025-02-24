#!/bin/bash
# Script for setup track location server 
# created by Andrii Rudyi, email: studentota2lvl@gmail.com

#~~~~~~~~~~~~~~~~~~ variables ~~~~~~~~~~~~~~~~~~
htmlLink="https://raw.githubusercontent.com/studentota2lvl/trackUrl/master/index.html"
nginxConfLink="https://raw.githubusercontent.com/studentota2lvl/trackUrl/master/nginx.conf"
ngrokLink="https://github.com/studentota2lvl/trackUrl/blob/master/ngrok?raw=true"
imageLink="https://raw.githubusercontent.com/studentota2lvl/trackUrl/master/image"
iconLink="https://raw.githubusercontent.com/studentota2lvl/trackUrl/master/favicon.ico"
logged_user=$(who | tr -d '\n'| cut -d' ' -f1);
workDir="/home/$logged_user/trackUrl"

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
    wget -q $htmlLink -O ./index.html;
    wget -q $nginxConfLink -O ./nginx.conf;
    wget -q $ngrokLink -O ./ngrok;
    chmod 755 ./ngrok*;
    wget -q $iconLink -O ./favicon.ico;
}

function prepareService() {
    cd $workDir;
    cp ./index.html /var/www/html/index.html;
    cp -f ./nginx.conf /etc/nginx/sites-available/default;
    cp -f ./favicon.ico /var/www/html/favicon.ico;
}

function updateImage() {
	cd $workDir;
	wget -q $imageLink -O ./image;
    cp -f ./image /var/www/html/image;
}

function changeOwner() {
	chown -R $logged_user:$logged_user $workDir;
	chown -R $logged_user:$logged_user /var/www/;
}

function updateNginxService() {
    service nginx restart;
}

function changeIndexFile() {
    # publickIP=$(curl https://api.ipify.org/); # get public ip of ec2
    sleep 10 # delay needs for run and initialize ngrok service
    redirectAddr=$(curl -s http://localhost:4040/api/tunnels | grep -Eo "https://[a-zA-Z0-9./?=_-]*" | sort -u);
    cp -f ./index.html /var/www/html/index.html;
    sed -i "s#localhost#_$redirectAddr#g" /var/www/html/index.html;
    sed -i "s#TITLE#InstaPost#g" /var/www/html/index.html;
}

function updateNgrokService() {
    cd $workDir;
    changeIndexFile &
    ./ngrok http 80
}

function usage() {
    message="\t$(basename "$0") [-sh] [-i value] -- program to install and setup solution for get current position of someone \n
    \n\twhere:
	\n\t\t    -i, --image     \t set custom image to page, like '-i http://link/to/image'.
    \n\t\t    -h, --help      \t\t show help
    \n\t\t    -s, --setup     \t full setup
    \n\t\t    -u, --update     \t update server (restart ngrok ang nginx)"

    echo -e $message;
}

#~~~~~~~~~~~~~~~~~~~~ logic ~~~~~~~~~~~~~~~~~~~~
if [[ $EUID -ne 0 ]]; then
    printf "%s %s\n" "This script must be run as root, like: " "sudo ./script.sh";
    exit 1;
else
	if [[ $# -ne 0 ]]; then
		for (( i=1; i<=$#; i++ )) #‾‾‾‾‾‾‾‾‾# part for update image
		do 									#
			if [[ ${!i} == "-i" ]];then 	#
				((i++)) 					#
				imageLink=${!i}; 			#
			    updateImage; 				#
				changeOwner; 				#
			fi; 							#
		done; #_____________________________#
	    while [ "$1" != "" ]; do
	        case $1 in
	            -s | --setup )  
	            	createWorkdir;
	            	installApp;
	            	downloadFiles;
	            	updateNgrokService;
	            	prepareService;
					updateImage;
					changeOwner;
	            	updateNginxService;
	            	;;
	            -h | --help )
	            	usage;
	            	exit 0;
	            	;;
	            -u | --update )
	            	updateNgrokService;
	            	updateNginxService;
	            	exit 0;
	            	;;
				-i | --image )
					shift
	            	;;
	            * )         
					echo "Wrong script parameter: $1";
					usage;
					exit 1;
	            	;;
	        esac;
	        shift;
	    done;
	else
		echo "You don't decide any parameter.";
		usage;
		exit 1;
	fi;
fi;