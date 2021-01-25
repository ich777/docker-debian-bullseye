FROM ich777/novnc-baseimage:bullseye

LABEL maintainer="admin@minenet.at"

RUN export TZ=Europe/Rome && \
	sed -i '/deb http:\/\/deb.debian.org\/debian buster main/c\deb http:\/\/deb.debian.org\/debian buster main non-free contrib' /etc/apt/sources.list && \
	apt-get update && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends man-db hdparm udev whiptail reportbug init vim-common iproute2 nano gdbm-l10n less iputils-ping netcat-traditional perl bzip2 gettext-base manpages file liblockfile-bin python3-reportbug libnss-systemd isc-dhcp-common systemd-sysv xz-utils perl-modules debian-faq wamerican bsdmainutils systemd cpio logrotate traceroute dbus kmod isc-dhcp-client telnet krb5-locales lsof debconf-i18n cron ncurses-term iptables ifupdown procps rsyslog apt-utils netbase pciutils bash-completion vim-tiny groff-base apt-listchanges bind9-host doc-debian libpam-systemd openssh-client xfce4 xorg dbus-x11 sudo gvfs-backends gvfs-common gvfs-fuse gvfs firefox-esr at-spi2-core gpg-agent mousepad xarchiver sylpheed unzip gtk2-engines-pixbuf gnome-themes-standard lxtask xfce4-terminal p7zip unrar curl msttcorefonts xfce4-screenshooter binutils gedit && \
	apt-get remove xterm && \
	chmod -R 755 /usr/share/locale/ && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i '/    document.title =/c\    document.title = "DebianBullseye - noVNC";' /usr/share/novnc/app/ui.js && \
	rm /usr/share/novnc/app/images/icons/*

ENV DATA_DIR=/debian
ENV FORCE_UPDATE=""
ENV CUSTOM_RES_W=1280
ENV CUSTOM_RES_H=720
ENV NOVNC_PORT=8080
ENV RFB_PORT=5900
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
COPY /debian.png /usr/share/backgrounds/xfce/
RUN chmod -R 770 /opt/scripts/

EXPOSE 8080

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]