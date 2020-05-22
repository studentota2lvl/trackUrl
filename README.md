# trackUrl
This application can give you some data about website client

To use just download `TrackUrl.sh` and set executable rights using command 
```bash
wget -q https://raw.githubusercontent.com/studentota2lvl/trackUrl/master/TrackUrl.sh -O ./TrackUrl.sh && chmod 755 $_
```
Than enter command to setup and run application
```bash
sudo ./TrackUrl.sh -s # or sudo ./TrackUrl.sh --setup
```

if you ran application before, just restart application via command:
```bash
sudo ./TrackUrl.sh -u
```

Also you can combine setup/start/restart application and change image, but pay notice, key for change image must be on the first position:
```bash
sudo ./TrackUrl.sh -i "https://someportal.com/path/to/image.*" -u 
```
file extension doesn't matter.

For get help just put command to your terminal in script folder:
```bash
sudo ./TrackUrl.sh -h # or sudo ./TrackUrl.sh --help
```

#### todo
1. change page template, to most popular, or much beauty
2. try to run application in background via command like that `ngrok -log=stdout http 80 > ./logfile &` and get server sequests from application ang put them to access file;
3. if will use foregroung ngrok start, try to put more information to ligs