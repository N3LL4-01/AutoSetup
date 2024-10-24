#!/bin/bash

APP_TITLE='System Tool'
VERSION=0.1

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

php_ppa="ondrej/php"
if ! grep -q "^deb .*$php_ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    add-apt-repository -y ppa:ondrej/php
    apt-get update
fi

APACHE_PACKAGES='apache2 libapache2-mod-fcgid'
COMMON_PACKAGES='bzip2 dialog less mc ntpdate openssh-client openssh-server openssl ssh subversion webalizer whois unzip'
PHP_PACKAGES='php7.4-fpm php7.4-common php7.4-mysql php7.4-xml php7.4-xmlrpc php7.4-curl php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring php7.4-opcache php7.4-soap php7.4-zip php7.4-intl'
MYSQL_PACKAGES='mysql-client mysql-server'

ROOTDIR="$(cd "$(dirname "$0")"; pwd)"
CONF_DIR="${ROOTDIR}/conf"

if ! command -v dialog &> /dev/null; then
    apt-get install -y dialog
fi

_TEMP="/tmp/system-tool.$$"

clear_and_exit () {
    clear
    exit
}

configure () {
    clear
    configure_system
    configure_apache
    configure_php
    configure_mysql
}

configure_apache () {
    rm -f /etc/apache2/conf.d/*
    rm -f /etc/apache2/sites-available/*
    rm -f /etc/apache2/sites-enabled/*
    cp -r ${CONF_DIR}/etc/apache2/* /etc/apache2/
    ln -s /etc/apache2/sites-available/*conf /etc/apache2/sites-enabled/
    HOSTNAME=$(hostname)
    cat > /etc/apache2/conf-available/100-servername.conf << EOF
ServerName ${HOSTNAME}
EOF
    a2enconf 100-servername
    a2enmod rewrite
    systemctl restart apache2
}

configure_mysql () {
    cp -r ${CONF_DIR}/etc/mysql/* /etc/mysql/
    systemctl restart mysql
}

configure_php () {
    cp -r ${CONF_DIR}/etc/php/7.4/* /etc/php/7.4/
}

configure_system () {
    cp ${CONF_DIR}/root/.bashrc /root/
    cp -r ${CONF_DIR}/etc/cron.d/* /etc/cron.d/
    chmod 700 /etc/cron.d/*
    cp -r ${CONF_DIR}/etc/cron.hourly/* /etc/cron.hourly/
    chmod 700 /etc/cron.hourly/*
    /etc/cron.hourly/ntpdate
    cp -r ${CONF_DIR}/usr/local/* /usr/local/
    chown -R root: /usr/local/system-tool/
    chmod -R 700 /usr/local/system-tool/
}

set_screen_height_width () {
    let "SCREEN_HEIGHT_HI=$(tput lines)-5"
    SCREEN_HEIGHT_LO=15
    if [ ${SCREEN_HEIGHT_HI} -lt ${SCREEN_HEIGHT_LO} ] ; then
        SCREEN_HEIGHT_HI=${SCREEN_HEIGHT_LO}
    fi
    let "SCREEN_WIDTH_HI=$(tput cols)"
    SCREEN_WIDTH_LO=90
    if [ ${SCREEN_WIDTH_HI} -lt ${SCREEN_WIDTH_LO} ] ; then
        SCREEN_WIDTH_HI=${SCREEN_WIDTH_LO}
    fi
}

gui_choose_main_action () {
    if [ -f /usr/local/system-tool/webserver.version ] ; then
        dialog --backtitle "${APP_TITLE}" \
               --title 'Start' \
               --cancel-label 'Quit' \
               --menu 'Choose your action:' ${SCREEN_HEIGHT_LO} ${SCREEN_WIDTH_LO} 2 \
               0 'Update system' \
               1 'Reconfigure system' 2> ${_TEMP}
        case ${?} in
            0) 
                MAIN_ACTION=$(cat ${_TEMP})
                rm -f ${_TEMP}
                case ${MAIN_ACTION} in
                    0) gui_helper_update_system;;
                    1) gui_configure_system;;
                esac
                ;;
            1) clear_and_exit;;
        esac
    else
        dialog --backtitle "${APP_TITLE}" \
               --title 'Start' \
               --cancel-label 'Quit' \
               --menu 'Choose your action:' ${SCREEN_HEIGHT_LO} ${SCREEN_WIDTH_LO} 2 \
               0 'Install system' 2> ${_TEMP}
        case ${?} in
            0) 
                MAIN_ACTION=$(cat ${_TEMP})
                rm -f ${_TEMP}
                case ${MAIN_ACTION} in
                    0) gui_install_system;;
                esac
                ;;
            1) clear_and_exit;;
        esac
    fi
}

gui_configure_system () {
    configure
    dialog --backtitle "${APP_TITLE}" \
           --title "System / Configure" \
           --ok-label 'Back' \
           --msgbox 'System successfully configured.' ${SCREEN_HEIGHT_LO} ${SCREEN_WIDTH_LO}
    gui_choose_main_action
}

gui_install_system () {
    helper_update_system
    helper_install_or_update_packages
    helper_make_dirs
    a2enmod fcgid
    a2enmod suexec
    systemctl restart apache2
    mkdir -p /usr/local/system-tool
    cat > /usr/local/system-tool/webserver.version << EOF
${VERSION}
EOF
    dialog --backtitle "${APP_TITLE}" \
           --title "System / Installation" \
           --ok-label 'Ok' \
           --msgbox 'System successfully installed, starting configuration.' ${SCREEN_HEIGHT_LO} ${SCREEN_WIDTH_LO}
    gui_configure_system
}

gui_helper_update_system () {
    helper_update_system
    helper_install_or_update_packages
    dialog --backtitle "${APP_TITLE}" \
           --title "System / Update" \
           --ok-label 'Back' \
           --msgbox 'System successfully updated.' ${SCREEN_HEIGHT_LO} ${SCREEN_WIDTH_LO}
    gui_choose_main_action
}

helper_install_or_update_packages () {
    apt-get install -y ${COMMON_PACKAGES} ${APACHE_PACKAGES} ${PHP_PACKAGES} ${MYSQL_PACKAGES}
}

helper_make_dirs () {
    mkdir -p /var/www/default
    mkdir -p /var/www/production/vhosts
    mkdir -p /var/www/testing/vhosts
}

helper_update_system () {
    cp -r ${CONF_DIR}/etc/apt/* /etc/apt/
    apt-get update
    apt-get -y upgrade
}

main_menu () {
    set_screen_height_width
    gui_choose_main_action
}

while true; do
    main_menu
done
