#!/bin/bash


function f_hn_dns(){
    print_log "1. Configuring hostname and dns begin"
    if [[ "${NIC_NAME}" == "" ]];then
        print_error_log "NIC_NAME must be specified"
        exit 99
    else
        check_nic_name=$(ip addr show ${NIC_NAME})
        status=$?
        if [ ${status} -eq 0 ];then
            get_ipaddr=$(ip addr show ${NIC_NAME} | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)
            sed -i "/${get_ipaddr}/d" /etc/hosts
            echo -e "${get_ipaddr}\t ${HOSTNAME}.com\t server" >>/etc/hosts
        else
            print_error_log "Please check network interface card name"
            exit 99
        fi
    fi
    hostnamectl set-hostname ${HOSTNAME}
    if [[ $? -eq 0 ]];then
            print_success_log "hostname configuration successfully!"
    else
            print_error_log "hostname configuration failure !"
    fi
    print_log "   Configuring hostname end"
}

function f_firewalld(){
    print_log "2. Checking firwalld begin"
    fire_status=$(systemctl status firewalld | grep running | awk -F'(' '{print $2}'| awk -F')' '{print $1}')
    if [[ "${fire_status}" == "running" ]];then 
        print_error_log "ERROR: firewall is running,please stopped it !"
        print_sub_log "Stoping firewalld begin"
        systemctl stop firewalld
        print_sub_log "Stoping firewalld end"

        print_sub_log "Stoping boot start active begin"
        systemctl disable firewalld
        print_sub_log "Stoping boot start active end"
    else
        print_sub_log "Firewall has been forbiden !"
    fi
    print_log "   Checking firwalld end"
}
function f_selinux(){
    print_log "3. Checking selinux begin"
    sf_status=$(getenforce)
    if [[ "${sf_status}" == "Disabled" ]];then 
        print_success_log "Selinux has been disabled"
    else
        sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
        print_error_log "Warning: Selinux is active,please disabled it using setenforce 0"
        setenforce 0
    fi
    print_log "   Checking selinux end"
}

function f_user(){
    u_oracle=$(egrep "oracle" /etc/passwd | awk -F':' '{print $1}')
    print_log "4. Checking user group begin "
    is_user=$(id oracle &>/dev/null)
    if [[ "${is_user}" == "1" ]];then 
        print_error_log "ERROR: oracle user doesn't exists and will be added !"
        group_array=("dba" "oper" "backupdba" "dgdba" "kmdba" "asmdba" "racdba")
        group_list=${group_list%,}
        useradd -g oinstall -G ${group_list}
        is_user=$(id oracle &>/dev/null)
        if [[ "${is_user}" == "0" ]];then
            print_success_log "Oralce user has been added !"
        fi
    else 
        print_success_log "Oracle user already exists !"      
    fi
    print_sub_log "Addming sudo privileges"
    sed -i "/oracle/d" /etc/sudoers
    echo "oracle  ALL=(ALL)       NOPASSWD: ALL" >>/etc/sudoers
    print_log "   Checking user group end "
}


function f_deps(){
    print_log "5. Installing dependences packages begin"
    cd ${TOPLEVEL_DIR}/rpm
    rpm -ivh deltarpm-* &>/dev/null
    rpm -ivh libxml2-python-* &>/dev/null
    rpm -ivh rpm -ivh python-deltarpm-* &>/dev/null
    rpm -ivh createrepo-* &>/dev/null
    cd ${TOPLEVEL_DIR} && createrepo rpm &>/dev/null
    cd /etc/yum.repos.d/ && mkdir -p repobak && mv *.repo repobak
cat >/etc/yum.repos.d/oradeps.repo<<EOF
[oradeps]
name=oradeps
baseurl=file://${TOPLEVEL_DIR}/rpm
enabled=1
gpgcheck=0
EOF
    print_sub_log "installing ......."
    for pkg in `cat ${TOPLEVEL_DIR}/lib/pkglist`;do
        yum install -y  ${pkg} >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
    done
    print_sub_log "installing complete"

    print_log "   Installing dependences packages begin end"
}

function f_kernel(){
    >/etc/sysctl.d/97-oracle-database-sysctl.conf
    print_log "6. Configuring kernel parameters begin"
    while read line;do
        echo ${line}>>/etc/sysctl.d/97-oracle-database-sysctl.conf
    done<${TOPLEVEL_DIR}/lib/kernelpara
    sysctl --system &>/dev/null
    print_success_log "Kernel parameter configuration completed !"
    print_log "   Configuring kernel parameters end"
}

function f_limit(){
    print_log "7. Configuring resource limits begin"
    while read line;do
        sed -i '/oracle/d' /etc/security/limits.conf 
        echo ${line}>>/etc/security/limits.conf 
    done<${TOPLEVEL_DIR}/lib/limits
    print_success_log "Resource limits configuration completed !"
    print_log "   Configuring resource limits end"
}
