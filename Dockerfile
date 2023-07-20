FROM ich777/novnc-baseimage

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-debian-bullseye"

RUN export TZ=Europe/Rome && \
	apt-get update && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends man-db hdparm udev whiptail reportbug init vim-common iproute2 nano gdbm-l10n less iputils-ping netcat-traditional perl bzip2 gettext-base manpages file liblockfile-bin python3-reportbug libnss-systemd isc-dhcp-common systemd-sysv xz-utils perl-modules debian-faq wamerican bsdmainutils systemd cpio logrotate traceroute dbus kmod isc-dhcp-client telnet krb5-locales lsof debconf-i18n cron ncurses-term iptables ifupdown procps rsyslog apt-utils netbase pciutils bash-completion vim-tiny groff-base apt-listchanges bind9-host doc-debian libpam-systemd openssh-client xfce4 xorg dbus-x11 sudo gvfs-backends gvfs-common gvfs-fuse gvfs firefox-esr at-spi2-core gpg-agent mousepad xarchiver sylpheed unzip gtk2-engines-pixbuf gnome-themes-standard lxtask xfce4-terminal p7zip unrar curl msttcorefonts xfce4-screenshooter binutils gedit zip xfce4-taskmanager fonts-vlgothic ffmpeg flameshot jq fonts-liberation libu2f-udev libgstreamer-plugins-base1.0-0 libxdo3 && \
	apt-get -y remove xterm mousepad zstd && \
	apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
	wget -O /tmp/axiom.tar.gz https://github.com/ich777/docker-debian-bullseye/raw/master/90145-axiom.tar.gz && \
	tar -xvf /tmp/axiom.tar.gz && \
	mv /tmp/axiomd /usr/share/themes/ && \
	rm -R /tmp/axiom* && \
	cd /usr/share/locale && \
	wget -O /usr/share/locale/locale.7z https://github.com/ich777/docker-debian-bullseye/raw/master/locale.7z && \
	p7zip -d -f /usr/share/locale/locale.7z && \
	chmod -R 755 /usr/share/locale/ && \
	sed -i '/    document.title =/c\    document.title = "DebianBullseye - noVNC";' /usr/share/novnc/app/ui.js && \
	mkdir /tmp/config && \
	rm /usr/share/novnc/app/images/icons/*

RUN wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | tee /etc/apt/sources.list.d/element-io.list && \
	apt-get update && \
	apt-get -y install element-desktop && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i "s/Exec=\/opt\/Element\/element-desktop.*/Exec=\/opt\/Element\/element-desktop --no-sandbox --disable-accelerated-video --disable-gpu --disable-seccomp-filter-sandbox --dbus-stub %U/g" /usr/share/applications/element-desktop.desktop

RUN mkdir -p /tmp/rustdesk && \
	RUSTDESK_V="$(wget -qO- https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep tag_name | cut -d '"' -f4)" && \
	wget -O /tmp/rustdesk/rustdesk.tar.zst https://github.com/rustdesk/rustdesk/releases/download/${RUSTDESK_V}/rustdesk-${RUSTDESK_V}-0-x86_64.pkg.tar.zst && \
	tar -C /tmp/rustdesk -xvf /tmp/rustdesk/rustdesk.tar.zst && \
	mv /tmp/rustdesk/usr/lib/rustdesk /opt/ && mv /tmp/rustdesk/usr/share/rustdesk/files/rustdesk.png /opt/rustdesk && \
	mv /tmp/rustdesk/usr/share/rustdesk/files/rustdesk.desktop /usr/share/applications/ && \
	sed -i "/^Icon=/c\Icon=\/opt\/rustdesk\/rustdesk.png" /usr/share/applications/rustdesk.desktop && \
	sed -i "/^Exec=/c\Exec=env LD_PRELOAD=\/opt\/rustdesk\/lib \/opt\/rustdesk\/rustdesk" /usr/share/applications/rustdesk.desktop && \
	rm -rf /tmp/rustdesk

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
COPY /icons/* /usr/share/novnc/app/images/icons/
COPY /debianbullseye.png /usr/share/backgrounds/xfce/debian.png
COPY /config/ /tmp/config/
RUN chmod -R 770 /opt/scripts/

EXPOSE 8080

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]