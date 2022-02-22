FROM ich777/novnc-baseimage

LABEL maintainer="admin@minenet.at"

RUN export TZ=Europe/Rome && \
	apt-get update && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	rm -rf /var/lib/apt/lists/*

RUN sed -i '/    document.title =/c\    document.title = "DebianBullseye - noVNC";' /usr/share/novnc/app/ui.js && \
	rm /usr/share/novnc/app/images/icons/*

ENV DATA_DIR=/debian
ENV FORCE_UPDATE=""
ENV CUSTOM_RES_W=1280
ENV CUSTOM_RES_H=720
ENV CUSTOM_DEPTH=16
ENV NOVNC_PORT=8080
ENV RFB_PORT=5900
ENV TURBOVNC_PARAMS="-securitytypes none"
ENV NOVNC_RESIZE=""
ENV NOVNC_QUALITY=""
ENV NOVNC_COMPRESSION=""
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="Debian"
ENV ROOT_PWD="Docker!"
ENV DEV=""
ENV USER_LOCALES="en_US.UTF-8 UTF-8"

RUN mkdir $DATA_DIR	&& \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
#COPY /icons/* /usr/share/novnc/app/images/icons/
#COPY /debianbullseye.png /usr/share/backgrounds/xfce/debian.png
COPY /config/ /tmp/config/
RUN chmod -R 770 /opt/scripts/

EXPOSE 8080

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]