#!/bin/bash
#
# author Johnny
set -Eeuo pipefail
#
# centos 7 install nginx manager suite
#

function cleanup() {
        trap - SIGINT SIGTERM ERR EXIT
        if [ -n "${tmp_script}" ]; then
#                log_info "Deleted temporary working script ${tmp_script}"
                rm -rf "${tmp_script}"
        fi
}

#trap SIGINT SIGTERM ERR EXIT

# set variable value
DATE_N=`date "+%Y-%m-%d %H:%M:%S"`
USER_N=`whoami`
HOST_NAME=`hostname`
LOGFILE="/var/log/nms_install.log"
# Gets the current location of the script
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

mkdir -p "${script_dir}"/pkgs/{clickhouse-server,nginx,nginxplus,nim,acm,cert} || true

# clickhouse server parameters
clickhouse_server="clickhouse-server"
clickhouse_dir="${script_dir}"/pkgs/clickhouse-server

# nginx parameters
nginx="nginx"
nginx_dir="${script_dir}"/pkgs/nginx

# nginx plus parameters
nginxplus_service_name="nginx"
nginxplus_pkg_name="nginx-plus"
nginxplus_dir="${script_dir}"/pkgs/nginxplus
nginxplus_cert_dir="${script_dir}"/pkgs/cert
nginxplus_ssl_dir="/etc/ssl/nginx"

# nim parameters
nim_dir="${script_dir}"/pkgs/nim
nim_pkg_name="nms-instance-manager"
nms_names=(nms nms-core nms-dpm nms-ingestion nms-integrations)

# acm parameters
acm_service_name="nms-acm"
acm_pkg_name="nms-api-connectivity-manager"
acm_dir="${script_dir}"/pkgs/acm

function help() {
    cat <<EOF
Usage:
  $(basename "$0") help | -h | --help
  $(basename "$0") clickhouse (start|stop|restart|status|install|uninstall|download)
  $(basename "$0") nginx (start|stop|restart|status|install|uninstall|download)
  $(basename "$0") nginxplus (start|stop|restart|status|install|uninstall)
  $(basename "$0") nim (start|stop|restart|status|install|uninstall)
  $(basename "$0") acm (start|stop|restart|status|install|uninstall)
  $(basename "$0") version

Options:
  help            Show this screen.
  clickhouse      Stop, start, or check the current status of clickhouse server.
  nginx           Stop, start, or check the current status of NGINX.
  nginxplus       Stop, start, or check the current status of NGINX Plus.
  nim             Stop, start, or check the current status of NGINX Instance Manager.
  acm             Stop, start, or check the current status of NGINX Management Suite API Connectivity Manager.
  version         Show the nms-automatic-deployment version
EOF
}

function nginx_help() {
    cat <<EOF
Stop, start, or check current status of NGINX.

Usage:
  $(basename "$0") nginx (start|stop|restart|status|install|uninstall|download)


Options:
  start     Start NGINX.
  stop      Stop NGINX.
  restart   Restart NGINX.
  status    Show status of NGINX.
  install   deploy NGINX.
  uninstall uninstall NGINX.
  download  download NGINX.
EOF
}


function nginxplus_help() {
    cat <<EOF
Stop, start, or check current status of NGINX PLUS.

Usage:
  $(basename "$0") nginx plus (start|stop|restart|status|install|uninstall)


Options:
  start     Start NGINX Plus.
  stop      Stop NGINX Plus.
  restart   Restart NGINX Plus.
  status    Show status of NGINX Plus.
  install   deploy NGINX Plus.
  uninstall uninstall NGINX Plus.
EOF
}


function clickhouse_help() {
    cat <<EOF
Stop, start, or check current status of Clickhouse Server.

Usage:
  $(basename "$0") clickhouse (start|stop|restart|status|install|uninstall|download)


Options:
  start     Start clickhouse server.
  stop      Stop clickhouse server.
  restart   Restart clickhouse server.
  status    Show status of clickhouse server.
  install   deploy clickhouse server.
  uninstall uninstall clickhouse server.
  download  download clickhouse server.
EOF
}


function nim_help() {
    cat <<EOF
Stop, start, or check current status of NGINX Instance Manager.

Usage:
  $(basename "$0") nim (start|stop|restart|status|install|uninstall)


Options:
  start     Start NGINX Instance Manager.
  stop      Stop NGINX Instance Manager.
  restart   Restart NGINX Instance Manager
  status    Show status of NGINX Instance Manager.
  install   deploy NGINX Instance Manager.
  uninstall uninstall NGINX Instance Manager.
EOF
}

function acm_help() {
    cat <<EOF
Stop, start, or check current status of NGINX Management Suite API Connectivity Manager.

Usage:
  $(basename "$0") acm (start|stop|restart|status|install|uninstall)


Options:
  start     Start NGINX Management Suite API Connectivity Manager.
  stop      Stop NGINX Management Suite API Connectivity Manager.
  restart   Restart NGINX Management Suite API Connectivity Manager.
  status    Show status of NGINX Management Suite API Connectivity Manager.
  install   deploy NGINX Management Suite API Connectivity Manager.
  uninstall uninstall NGINX Management Suite API Connectivity Manager.
EOF
}


IP=$(ip addr list |  grep -o -e 'inet [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'|grep -v "127.0.0.2"|awk '{print $2}')

# Execution successful log printing path
function log_info () {
    echo "${DATE_N} ${HOST_NAME} ${USER_N} execute $0 [INFO] $@ sucessed." >> ${LOGFILE}
    echo -e "\033[32m $@ sucessed. \033[0m"
}


# Execution successful warning log print path
function log_warn () {
    echo "${DATE_N} ${HOST_NAME} ${USER_N} execute $0 [WARN] $@" >> ${LOGFILE}
    echo -e "\033[33m Warnning: $@  \033[0m"
}

# Execution failure log print path
function log_error () {
    echo -e "\033[41;37m ${DATE_N} ${HOST_NAME} ${USER_N} execute $0 [ERROR] $@ failed. \033[0m"  >> ${LOGFILE}
    echo -e "\033[41;37m $@ failed. \033[0m"
    exit 1
}

function fn_log ()  {
    if [  $? -eq 0  ]
    then
            log_info "$@"
    else
            log_error "$@"
    fi
}

function log_trap() {
    # Disconnect the connection by sending a signal
    trap 'fn_log "DO NOT SEND CTR + C WHEN EXECUTE SCRIPT !!!! "' 2
}


function os_preinstall() {
    # check whether it is root user login
    if [[ $(id -u) != "0" ]]; then
        echo  -e "\033[32m not root user \033[0m"
        log_error "You must be root to run this install script."
        exit 1
    fi

    # Check whether it is CentOS/RedHat 7.4 or above version
    if [[ $(grep "release 7." /etc/redhat-release 2>/dev/null | wc -l) -eq 0 ]]; then
        echo  -e "\033[32m Your OS is NOT CentOS 7.4 or above RHEL 7.4 \033[0m"
        log_error "Your OS is NOT CentOS 7.4 or above RHEL 7.4"
        exit 1
    fi

    # disable selinux
    setenforce 0 >/dev/null 2>&1 || true
    sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/selinux/config
    # disable firewall
    systemctl stop firewalld
    systemctl disable firewalld
    # disable swap parttion
    swapoff -a

    #configure ssh
    cat /etc/ssh/sshd_config | grep "UseDNS no" >/dev/null 2>&1 || {
        sed -i '/#VersionAddendum none/a\UseDNS no' /etc/ssh/sshd_config
        log_info "disabled ssh reverse domain name resolution"
    }
    sed -i "s/GSSAPIAuthentication yes/GSSAPIAuthentication no/g" /etc/ssh/sshd_config
    systemctl restart sshd

    log_info "Checking for required utilities..."
    if [[ ! -x "$(command -v expect)" ]];then
            yum -y install expect
            log_info "expect has been installed on Centos/Redhat 7"
    fi

#    [[ -x "$(command -v expect)" ]] && log_error " expect is not installed. On Centos/Redhat 7, install the 'expect' package."
}

os_preinstall

# install clickhouse-server service
function clickhouse_install() {
    # check if nms packages is already installing
    clickhouse_pkg_status=$(rpm -qa | grep ${clickhouse_server} >/dev/null &&  echo yes || echo no)
    if [ ${clickhouse_pkg_status} == "yes" ]; then
        log_info "${clickhouse_server} is already installed"
    else
        yum -y localinstall ${clickhouse_dir}/* >/dev/null
        log_info "${clickhouse_server} is installing"
    fi

    # start clickhouse_server app
    systemctl start clickhouse-server.service && systemctl enable clickhouse-server.service
    process_number=$(ps -ef | grep clickhouse-server | grep -v grep | wc -l)
    if [ $process_number -eq 0 ]; then
        log_error "clickhouse-server startup error"
    else
        log_info "clickhouse-server is running"
    fi
}
# uninstall clickhouse-server service
function clickhouse_uninstall() {
    clickhouse_stop
    # check if nms packages is already installing
    clickhouse_pkg_status=$(rpm -qa | grep ${clickhouse_server} >/dev/null &&  echo yes || echo no)
    if [ ${clickhouse_pkg_status} == "no" ]; then
        log_info "${clickhouse_server} is already uninstalled"
    else
        yum -y remove clickhouse-client clickhouse-server clickhouse-common-static >/dev/null
        log_info "${clickhouse_server} is uninstalling"
    fi

}

# start clickhouse_server service
function clickhouse_start() {
    systemctl daemon-reload
    clickhouse_server_status=$(ps -ef | grep clickhouse-server | grep -v grep >/dev/null &&  echo yes || echo no)
    if [ ${clickhouse_server_status} == "no" ]; then
            systemctl start ${clickhouse_server}; systemctl enable ${clickhouse_server} >/dev/null 2>&1
            if [ $? -eq 0 ];then
                log_info "${clickhouse_server} is running"
            else
                log_error "${clickhouse_server} is stopping"
            fi
        else
            log_info "${clickhouse_server} is already running"
    fi
}

# restart clickhouse_server service
function clickhouse_restart() {
    systemctl daemon-reload
    systemctl restart ${clickhouse_server}
    if [ $? -eq 0 ];then
        log_info "${clickhouse_server} is restart"
    else
        log_error "${clickhouse_server} is stopping"
    fi
}
# stop clickhouse-server service
function clickhouse_stop() {
    clickhouse_server_status=$(ps -ef | grep clickhouse-server  | grep -v grep >/dev/null &&  echo yes || echo no)
    if [ ${clickhouse_server_status} == "yes" ]; then
        systemctl stop ${clickhouse_server}
        if [ $? -eq 0 ];then
            log_info "${clickhouse_server} is stopping"
        else
            log_error "${clickhouse_server} is running"
        fi
    else
        log_info "${clickhouse_server} is already stopping"
    fi
}
# show clickhouse-server service status
function clickhouse_status() {
    clickhouse_server_status=$(systemctl status ${clickhouse_server} >/dev/null &&  echo yes || echo no)
    if [ "${clickhouse_server_status}" == "yes" ]; then
        log_info "${clickhouse_server} is running"
    else
        log_info "${clickhouse_server} is stopping"
    fi
}
# download clickhouse-server service
function clickhouse_download() {
    log_info "${clickhouse_server} is downloading"
	  yum-config-manager --add-repo https://packages.clickhouse.com/rpm/clickhouse.repo >/dev/null
	  yum install --downloadonly --downloaddir=${clickhouse_dir}/ clickhouse-server clickhouse-client >/dev/null 2>&1
		if [ $? -eq 0 ];then
        log_info "${clickhouse_server} is downloading"
    else
        log_error "${clickhouse_server} is downloading"
    fi

}

# set web login password for admin username
function set_password() {
        random_number=$(date +%s%N|md5sum|head -c 5)
        # set default password is admin
        username="admin"
        password=${password:-admin}
        tmp_script=tmp_${random_number}.sh
        echo  "#!/usr/bin/expect">"${tmp_script}"
        echo  "spawn htpasswd  ${password_file} ${username}">>"${tmp_script}"
        echo  "expect *.password:">>"${tmp_script}"
        echo  "send ${password}\r">>"${tmp_script}"
        echo  "expect *.password:">>"${tmp_script}"
        echo  "send ${password}\r">>"${tmp_script}"
        echo  "expect eof">>"${tmp_script}"

        chmod +x "${tmp_script}"

        /usr/bin/expect "${tmp_script}"
}

# install nim  service
function nim_install() {
    # check if clickhouse is installed
    clickhouse_install

    # check if clickhouse server is running, otherwise, startup clickhouse server
    clickhouse_start

    # check if nginx packages is already installed, otherwise, install nginx service
    nginxplus_install

    # check if nms packages is already installing
    nim_pkg_names_status=$(rpm -qa | grep ${nim_pkg_name} >/dev/null &&  echo yes || echo no)
    if [ ${nim_pkg_names_status} == "yes" ]; then
        log_info "${nim_pkg_name} is already installed"
    else
        yum -y localinstall ${nim_dir}/*  >/dev/null
        log_info "${nim_pkg_name} is installing"
    fi

    # starting nginx instanc manager service
    nim_start

    password_file=$(find /etc/nms/nginx/ -type f -iname .htpasswd)
    if [ -z ${password_file} ]; then
        log_error "${password_file} is not exist"
    else
        log_info "change default password for web ui login"
        set_password >/dev/null
        if [  $? -eq 0  ]; then
            log_info "nim password is changed"
        else
            log_error "nim password is changed"
        fi

    fi
    # delete tmp script
    cleanup

    if [[ ${cmd} == "nim" ]]; then
        # restarting nginxplus service
        nginxplus_restart
        # print web login prompt
        print_login_prompt
    fi
}

# uninstall nim  service
function nim_uninstall() {
    # stop nim service
    nim_stop
    # uninstall nim service
    nim_pkg_names_status=$(rpm -qa | grep ${nim_pkg_name} >/dev/null &&  echo yes || echo no)
    if [ ${nim_pkg_names_status} == "yes" ]; then
        yum -y remove ${nim_pkg_name}  >/dev/null
        log_info "${nim_pkg_name} is uninstalling"
    else
        log_info "${nim_pkg_name} is already uninstalled"
    fi
    # uninstall nginxplus service
    nginxplus_uninstall
    # uninstall clickhouse service
    clickhouse_uninstall
}

# start nim  service
function nim_start() {
    for name in ${nms_names[*]}; do
            systemctl start ${name}; systemctl enable ${name} >/dev/null 2>&1
            if [ $? -eq 0 ];then
                log_info "${name} is running"
            else
                log_error "${name} is stopping"
            fi
    done
}

# restart nim  service
function nim_restart() {
    for name in ${nms_names[*]}; do
        systemctl restart ${name}
        if [ $? -eq 0 ];then
            log_info "${name} is running"
        else
            log_error "${name} is stopping"
        fi
    done
}

# stop nim  service
function nim_stop() {
    # stop nginx manager service
    for name in ${nms_names[*]}; do
    # stop clickhouse-server service
        nim_status=$(ps -ef | grep ${name} | grep -v grep >/dev/null &&  echo yes || echo no)
        if [ ${nim_status} == "yes" ]; then
            systemctl stop ${name}
            if [ $? -eq 0 ];then
                log_info "${name} is stopping"
            else
                log_error "${name} is running"
            fi
        else
            log_info  "${name} is already stopping"
            break
        fi
    done
}

# show nim service status
function nim_status() {
    for name in ${nms_names[*]}; do
        nim_status=$(systemctl status ${name} >/dev/null 2>&1 &&  echo yes || echo no)
        if [ ${nim_status} == "yes" ]; then
            if [ $? -eq 0 ];then
                log_info "${name} is running"
            else
                log_info "${name} is stopping or not install"
            fi
        else
            log_info "${name} is already stopping or not install"
            break
        fi
    done
}

# check if nginx package is install, otherwise, install nginx service
function nginx_install() {
    # check install packages is normal
    nginx_pkg_status=$(rpm -qa | grep nginx | grep -v grep >/dev/null &&  echo yes || echo no)
    if [ ${nginx_pkg_status} == "yes" ]; then
        log_info "${nginx} is already installed"
    else
        target=$(ls ${nginx_dir} | grep nginx)
        rpm -ivh ${nginx_dir}/${target}  >/dev/null
        log_info "${nginx} is installing"
    fi

    # check if nginx is running, otherwise, startup nginx
    nginx_start
}
# install nginx service
function nginx_uninstall() {
    nginx_stop
    nginx_pkg_names_status=$(rpm -qa | grep nginx >/dev/null &&  echo yes || echo no)
    if [ ${nginx_pkg_names_status} == "yes" ]; then
        rpm -e ${nginx}
        log_info "${nginx} is uninstalling"
    else
        log_info "${nginx} is already uninstalled"
    fi
}

# start nginx service
function nginx_start() {
    systemctl daemon-reload
    systemctl start ${nginx}; systemctl enable ${nginx} >/dev/null 2>&1
    if [ $? -eq 0 ];then
        log_info "${nginx} is running"
    else
        log_error "${nginx} is stopping"
    fi
}

# resstart nginx service
function nginx_restart() {
    systemctl daemon-reload
    systemctl restart ${nginx}
    if [ $? -eq 0 ];then
        log_info "${nginx} is restart"
    else
        log_error "${nginx} is stopping"
    fi
}

# stop nginx service
function nginx_stop() {
    # stop clickhouse-server service
    nginx_status=$(ps -ef | grep ${nginx} | grep -v grep >/dev/null &&  echo yes || echo no)
    if [ ${nginx_status} == "yes" ]; then
        systemctl stop ${nginx}
        if [ $? -eq 0 ];then
            log_info "${nginx} is stopping"
        else
            log_error "${nginx} is running"
        fi
    else
        log_info  "${nginx} is already stopping"
    fi
}

# show nginx service status
function nginx_status() {
        nginx_status=$(systemctl status ${nginxplus_service_name} >/dev/null &&  echo yes || echo no)
        if [ ${nginx_status} == "yes" ]; then
            log_info "${nginx} is running"
        else
            log_info "${nginx} is stopping"
        fi
}
# download nginx service
function nginx_download() {

	  cp /etc/yum.repos.d/nginx.repo /etc/yum.repos.d/nginx.repo.bak || true

	  cat << 'eof' >  /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
eof
	  yum install --downloadonly --downloaddir=${nginx_dir} nginx >/dev/null
	  if [ $? -eq 0 ];then
       log_info "${nginx} is downloading"
    else
       log_error "${nginx} is downloading"
    fi
}
# install nginxplus  service
function nginxplus_install() {
    #Installation instructions for RHEL 7.4+ / CentOS 7.4+
    #If you already have old NGINX packages in your system, back up your configs and logs:
    if [ ! -d /etc/nginx -o ! -d /var/log/nginx  ]; then
        log_info "the directory /etc/nginx is not exist"
    else
        cp -a /etc/nginx /etc/nginx-plus-backup
        cp -a /var/log/nginx /var/log/nginx-plus-backup
        log_info "backup nginx plus"
    fi

    #Create the /etc/ssl/nginx/ directory:
    mkdir -p ${nginxplus_ssl_dir} || true

    #Log in to NGINX Customer Portal and down    load the following two files:
    cp -f ${nginxplus_cert_dir}/*.key ${nginxplus_ssl_dir}/nginx-repo.key
    cp -f ${nginxplus_cert_dir}/*.crt ${nginxplus_ssl_dir}/nginx-repo.crt
    log_info  "cp nginx-repo.key nginx-repo.crt to /etc/ssl/nginx directory"

    # check install packages is normal
    nginxplus_pkg_status=$(rpm -qa | grep ${nginxplus_pkg_name} >/dev/null &&  echo yes || echo no)
    if [ ${nginxplus_pkg_status} == "yes" ]; then
        log_info "${nginxplus_pkg_name} is already installed"
    else
        yum -y localinstall ${nginxplus_dir}/*  >/dev/null
        log_info "${nginxplus_pkg_name} is installing"
    fi

    # start nginxplus service
    nginxplus_start
}
# uninstall nginxplus  service
function nginxplus_uninstall() {
    # stop nginx plus
    nginxplus_stop

    nginxplus_pkg_status=$(rpm -qa | grep ${nginxplus_pkg_name} >/dev/null &&  echo yes || echo no)
    if [ ${nginxplus_pkg_status} == "yes" ]; then
        yum -y remove nginx-plus nginx-ha-keepalived-selinux >/dev/null
        log_info "${nginxplus_pkg_name} is uninstalling"
    else
        log_info "${nginxplus_pkg_name} is already uninstalled"
    fi
}

# start nginxplus  service
function nginxplus_start() {
    systemctl daemon-reload
    systemctl start ${nginxplus_service_name}
    systemctl enable ${nginxplus_service_name} >/dev/null 2>&1
    if [ $? -eq 0 ];then
        log_info "${nginxplus_pkg_name} is running"
    else
        log_error "${nginxplus_pkg_name} is stopping"
    fi
}

# restart nginxplus  service
function nginxplus_restart() {
    systemctl daemon-reload
    systemctl restart ${nginxplus_service_name}
    if [ $? -eq 0 ];then
        log_info "${nginxplus_pkg_name} is restart"
    else
        log_error "${nginxplus_pkg_name} is stopping"
    fi
}
# stop nginxplus  service
function nginxplus_stop() {
    # stop clickhouse-server service
    nginxplus_status=$(ps -ef | grep ${nginxplus_service_name} | grep -v grep >/dev/null &&  echo yes || echo no)
    if [ ${nginxplus_status} == "yes" ]; then
        systemctl stop ${nginxplus_service_name}
        if [ $? -eq 0 ];then
            log_info "${nginxplus_pkg_name} is stopping"
        else
            log_error "${nginxplus_pkg_name} is running"
        fi
    else
        log_info  "${nginxplus_pkg_name} is already stopping"
    fi
}

# show nginxplus service status
function nginxplus_status() {
        nginxplus_status=$(systemctl status ${nginxplus_service_name} >/dev/null &&  echo yes || echo no)
        if [ ${nginxplus_status} == "yes" ]; then
            log_info "${nginxplus_pkg_name} is running"
        else
            log_info "${nginxplus_pkg_name} is stopping"
        fi
}

# show web login prompt
function print_login_prompt() {
echo "
******************** Web Login Prompt ********************************
    Login link: https://${IP}/ui/
    Admin username: admin
    Admin password: admin
******************** Web Login Prompt ********************************
"
}

# install acm  service
function acm_install() {
    # install and start nim service
    nim_install

    # check install packages is normal
    acm_pkg_status=$(rpm -qa | grep ${acm_pkg_name} >/dev/null &&  echo yes || echo no)
    if [ ${acm_pkg_status} == "yes" ]; then
        log_info "${acm_pkg_name} is already installed"
    else
        yum -y localinstall ${acm_dir}/*  >/dev/null
        log_info "${acm_pkg_name} is installing"
    fi

    # start acm service
    acm_start

    # restart nginxplus service
    nginxplus_restart

    # show web login prompt
    print_login_prompt
}

# uninstall acm  service
function acm_uninstall() {
    # uninstall nim service
    nim_uninstall

    # check install packages is normal
    acm_pkg_status=$(rpm -qa | grep nginx-devportal  >/dev/null &&  echo yes || echo no)
    if [ ${acm_pkg_status} == "yes" ]; then
        yum -y remove nginx-devportal  nginx-devportal-ui ${acm_pkg_name} >/dev/null
        log_info "${acm_pkg_name} is uninstalling"
    else
        log_info "${acm_pkg_name} is already uninstalled"
    fi
}
# start acm  service
function acm_start() {
    # start nim service
    nim_start
    # start acm service
    acm_status=$(ps -ef | grep ${acm_service_name} | grep -v grep >/dev/null &&  echo yes || echo no)
    if [ ${acm_status} == "no" ]; then
            systemctl start ${acm_service_name}; systemctl enable ${acm_service_name} >/dev/null 2>&1
            if [ $? -eq 0 ];then
                log_info "${acm_pkg_name} is running"
            else
                log_error "${acm_pkg_name} is stopping"
            fi
    else
            log_info "${acm_pkg_name} is already running"
    fi
}
# restart acm  service
function acm_restart() {
    # restart nim service
    nim_restart
    # restart acm service
    systemctl restart ${acm_service_name}
    if [ $? -eq 0 ];then
        log_info "${acm_pkg_name} is restart"
    else
        log_error "${acm_pkg_name} is stopping"
    fi
}

# stop acm  service
function acm_stop() {
    # stop nim service
    nim_stop
    # stop clickhouse-server service
    acm_status=$(ps -ef | grep ${acm_service_name} | grep -v grep >/dev/null &&  echo yes || echo no)
    if [ ${acm_status} == "yes" ]; then
        systemctl stop ${acm_service_name}
        if [ $? -eq 0 ];then
            log_info "${acm_pkg_name} is stopping"
        else
            log_error "${acm_pkg_name} is running"
        fi
    else
        log_info  "${acm_pkg_name} is already stopping"
    fi
}

# show acm service status
function acm_status() {
    acm_status=$(systemctl status ${acm_service_name} >/dev/null &&  echo yes || echo no)
    if [ ${acm_status} == "yes" ]; then
        log_info "${acm_pkg_name} is running"
    else
        log_info "${acm_pkg_name} is stopping"
    fi
}

# show nms-automatic-deployment version id
function version() {
    version_number="0.1"
    echo "nms-automatic-deployment version: ${version_number}"
}

function version_help() {
    cat <<EOF
Print the current nms-automatic-deployment version.

Usage:
  $(basename "$0") version
EOF
}


cmd=$1
shift || true
case $cmd in
    nim)
        case $1 in
            install)
                nim_install
                ;;
            uninstall)
                nim_uninstall
                ;;
            start)
                nim_start
                ;;
            stop)
                nim_stop
                ;;
            restart)
                nim_restart
                ;;
            status)
                nim_status
                ;;
            help | -h | --help)
                nim_help
                exit 0
                ;;
            *)
                printr "Missing argument. \n"
                nim_help
                exit 1
                ;;
        esac
        ;;
    clickhouse)
        case $1 in
            install)
                clickhouse_install
                ;;
            uninstall)
                clickhouse_uninstall
                ;;
            start)
                clickhouse_start
                ;;
            stop)
                clickhouse_stop
                ;;
            restart)
                clickhouse_restart
                ;;
            status)
                clickhouse_status
                ;;
            download)
                clickhouse_download
                ;;
            help | -h | --help)
                clickhouse_help
                exit 0
                ;;
            *)
                printr "Missing argument. \n"
                clickhouse_help
                exit 1
                ;;
        esac
        ;;
    nginxplus)
        case $1 in
            install)
                nginxplus_install
                ;;
            uninstall)
                nginxplus_uninstall
                ;;
            start)
                nginxplus_start
                ;;
            stop)
                nginxplus_stop
                ;;
            restart)
                nginxplus_restart
                ;;
            status)
                nginxplus_status
                ;;
            help | -h | --help)
                nginxplus_help
                exit 0
                ;;
            *)
                printr "Missing argument. \n"
                nginxplus_help
                exit 1
                ;;
        esac
        ;;

    nginx)
        case $1 in
            install)
                nginx_install
                ;;
            uninstall)
                nginx_uninstall
                ;;
            start)
                nginx_start
                ;;
            stop)
                nginx_stop
                ;;
            restart)
                nginx_restart
                ;;
            status)
                nginx_status
                ;;
            download)
                nginx_download
                ;;
            help | -h | --help)
                nginx_help
                exit 0
                ;;
            *)
                printr "Missing argument. \n"
                nginx_help
                exit 1
                ;;
        esac
        ;;
    acm)
        case $1 in
            install)
                acm_install
                ;;
            uninstall)
                acm_uninstall
                ;;
            start)
                acm_start
                ;;
            stop)
                acm_stop
                ;;
            restart)
                acm_restart
                ;;
            status)
                acm_status
                ;;
            help | -h | --help)
                acm_help
                exit 0
                ;;
            *)
                printr "Missing argument. \n"
                acm_help
                exit 1
                ;;
        esac
        ;;
    cleanup)
        case $1 in
            images)
                echo "cleanup"
                ;;
            help | -h | --help)
                exit 0
                ;;
            *)
                printr "Missing argument. \n"
                exit 1
                ;;
        esac
        ;;
    version)
        case "$*" in
            help | -h | --help)
                version_help
                exit 0
                ;;
            *)
                version "$@"
                ;;
        esac
        ;;
    help | -h | --help)
        help
        exit 0
        ;;
    *)
        help
        exit 1
        ;;
esac
