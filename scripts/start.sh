#!/bin/bash
echo "---Checking if UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Checking if GID: ${GID} matches user---"
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "root:${ROOT_PWD}" | chpasswd
export ROOT_PWD="secret"

echo "---Checking for optional scripts---"
if [ -f /opt/scripts/user.sh ]; then
	echo "---Found optional script, executing---"
    chmod +x /opt/scripts/user.sh
    /opt/scripts/user.sh
else
	echo "---No optional script found, continuing---"
fi

if [ ! -d /tmp/xdg ]; then
	mkdir /tmp/xdg
fi

sed -i "/  <user>/c\  <user>${USER}</user>" /usr/share/dbus-1/system.conf

echo "---Configuring Locales to: ${USER_LOCALES}---"
LOCALE_GEN=$(head -n 1 /etc/locale.gen)
export LOCALE_USR=$(echo ${USER_LOCALES} | cut -d ' ' -f 1)

if [ "$LOCALE_GEN" != "${USER_LOCALES}" ]; then
	rm /etc/locale.gen
	echo -e "${USER_LOCALES}\nen_US.UTF-8 UTF-8" > "/etc/locale.gen"
	export LANGUAGE="$LOCALE_USR"
	export LANG="$LOCALE_USR"
	export LC_ALL="$LOCALE_USR" 2> /dev/null
	sleep 2
	locale-gen
	update-locale LC_ALL="$LOCALE_USR"
else
	echo "---Locales set correctly, continuing---"
fi

echo "---Checking configuration for noVNC---"
if [ -z "${NOVNC_RESIZE}" ]; then
	sed -i "/        UI.initSetting('resize',/c\        UI.initSetting('resize', 'off');" /usr/share/novnc/app/ui.js
else
	echo "---Setting noVNC resizing to: ${NOVNC_RESIZE}"
	sed -i "/        UI.initSetting('resize',/c\        UI.initSetting('resize', '${NOVNC_RESIZE}');" /usr/share/novnc/app/ui.js
fi
if [ -z "${NOVNC_QUALITY}" ]; then
	sed -i "/        UI.initSetting('quality',/c\        UI.initSetting('quality', 6);" /usr/share/novnc/app/ui.js
else
	echo "---Setting noVNC quality to: ${NOVNC_QUALITY}"
	sed -i "/        UI.initSetting('quality',/c\        UI.initSetting('quality', ${NOVNC_QUALITY});" /usr/share/novnc/app/ui.js
fi
if [ -z "${NOVNC_COMPRESSION}" ]; then
	sed -i "/        UI.initSetting('compression',/c\        UI.initSetting('compression', 2);" /usr/share/novnc/app/ui.js
else
	echo "---Setting noVNC compression to: ${NOVNC_COMPRESSION}"
	sed -i "/        UI.initSetting('compression',/c\        UI.initSetting('compression', ${NOVNC_COMPRESSION});" /usr/share/novnc/app/ui.js
fi

echo "---Starting...---"
rm -R ${DATA_DIR}/.dbus/session-bus/* 2> /dev/null
if [ ! -d /var/run/dbus ]; then
	mkdir -p /var/run/dbus
fi
chown -R ${UID}:${GID} /var/run/dbus/
chmod -R 770 /var/run/dbus/
chown -R ${UID}:${GID} /opt/scripts
chown -R ${UID}:${GID} /tmp/xdg
chmod -R 0700 /tmp/xdg
dbus-uuidgen > /var/lib/dbus/machine-id
rm -R /tmp/.* 2> /dev/null
mkdir -p /tmp/.ICE-unix
chown root:root /tmp/.ICE-unix/
chmod 1777 /tmp/.ICE-unix/
chown -R ${UID}:${GID} ${DATA_DIR}
chown -R ${UID}:${GID} /tmp/config
chown -R ${UID}:${GID} /mnt/

term_handler() {
	export DISPLAY=:99 && su ${USER} -c "xfce4-session-logout --halt"
	tail --pid="$(pidof xfce4-session)" -f 2>/dev/null
	exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM
su ${USER} -c "/opt/scripts/start-server.sh" &
killpid="$!"
while true
do
	wait $killpid
	exit 0;
done