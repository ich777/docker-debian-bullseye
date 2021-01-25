# Debian Bullseye in Docker optimized for Unraid
This Container is a full Debian Bullseye Xfce4 Desktop environment with a noVNC webGUI and all the basic tools pre-installed.

If you want to install some other application you can do that by creating a user.sh and mounting it to the container to /opt/scripts/user.sh (a standard bash script should do the trick).

You also can reverse proxy this container with nginx or apache (for an example look at the end of the page).

**ROOT ACCESS:** 1. Open up your WebGUI 2. Open up a terminal 3. Type in 'su' 4. Type in your password that you've set (no screenoutput is shown if you type in passwords in Linux) 5. Press Enter 6. You should now be root.

**Storage Note:** All things that are saved in the container should be in the home or a subdirectory in your homefolder, all files that are store outside your homefolder are not persistant and will be wiped if there is an update of the container or you change something in the template.

### **BETA Warning:** Debian Bullseye is currently in the "testin" branch.

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Home folder | /debian |
| ROOT_PWD | Please choose a strong root password | superstrongpassword |
| CUSTOM_RES_W | Your preferred screen width | 1280 |
| CUSTOM_RES_H | Your preferred screen height | 1024 |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| UMASK | User file permission mask for newly created files | 000 |
| DATA_PERM | Data permissions for main storage folder | 770 |

## Run example
```
docker run --name Debian-Bullseye -d \
    -p 8080:8080 \
    --env 'ROOT_PWD=superstrongpassword' \
    --env 'CUSTOM_RES_W=1280' \
    --env 'CUSTOM_RES_H=1024' \
	--env 'UID=99' \
	--env 'GID=100' \
    --env 'UMASK=000' \
    --env 'DATA_PERM=770' \
	--volume /mnt/user/appdata/debian-bullseye:/debian \
    --restart=unless-stopped \
    --shm-size=2G \
	ich777/debian-bullseye
```

### Webgui address: http://[SERVERIP]:[PORT]/vnc.html?autoconnect=true


#### Reverse Proxy with nginx example:

```
server {
	listen 443 ssl;

	include /config/nginx/ssl.conf;
	include /config/nginx/error.conf;

	server_name debianbullseye.example.com;

	location /websockify {
		auth_basic           example.com;
		auth_basic_user_file /config/nginx/.htpasswd;
		proxy_http_version 1.1;
		proxy_pass http://192.168.1.1:8080/;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "upgrade";

		# VNC connection timeout
		proxy_read_timeout 61s;

		# Disable cache
		proxy_buffering off;
	}
		location / {
		rewrite ^/$ https://debianbullseye.example.com/vnc.html?autoconnect=true redirect;
		auth_basic           example.com;
		auth_basic_user_file /config/nginx/.htpasswd;
		proxy_redirect     off;
		proxy_set_header Range $http_range;
		proxy_set_header If-Range $http_if_range;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header Host $host;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "upgrade";
		proxy_pass http://192.168.1.1:8080/;
	}
}
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/