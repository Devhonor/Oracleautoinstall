#!/bin/bash
function create_os_user(){ 
    is_exists_user=$(grep oracle /etc/passwd|wc -l)
    if [ ${is_exists_user} -eq 1 ];then
        print_sub_log "User oracle exists"
        is_exists_oins_group=$(grep oinstall /etc/group | wc -l)
        if [ ${is_exists_oins_group} -eq 1 ];then
            print_sub_log "Group oinstall exists !"
        else
            print_error_log "Group oinstall doesn't exists !"
        fi
    else
        print_error_log "User oracle doesn't exists"
    fi

    print_sub_log "Create user oracle and group "
    groupadd -g 3001 oinstall >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
    groupadd -g 3002 dba >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
    groupadd -g 3003 oper >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
    groupadd -g 3004 racdba >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
    groupadd -g 3005 backupdba >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
    groupadd -g 3006 kmdba >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
    groupadd -g 3007 dgdba >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
    groupadd -g 3008 asmoper >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
    groupadd -g 3009 asmdba >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}

    useradd -u 3000 -g oinstall -G dba,oper,racdba,backupdba,kmdba,dgdba,asmoper,asmdba oracle >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
    print_sub_log "Setting oracle user password"

    count=0
    max_attempts=3

    while [[ $count -lt $max_attempts ]]; do
        ((count++))
        read -p "Please input oracle os user's password: " passwd1
        read -p "Please confirm oracle os user's password: " passwd2

        if [[ "${passwd1}" == "${passwd2}" ]]; then
            echo ${passwd2} | passwd --stdin oracle &>/dev/null && {
                print_sub_log "Setting oracle user password successfully !"
                break
            }
        else
            if [[ $count -eq $max_attempts ]]; then
                print_error_log "Exceeded maximum attempts,exit."
                exit 99
            else
                print_error_log "The password doesn't match, please try again."
            fi
        fi
    done
}

function create_user_dir(){
    print_log "8. Creating user and install directory begin"
    create_os_user
    if [ -d ${ORACLE_BASE} ];then
        print_success_log "The base directory ${ORACLE_BASE} already exists !"
    else
        print_error_log "Warning: The directory ${ORACLE_BASEE} doesn't exists and will be created"
        mkdir -p ${ORACLE_HOME}
        print_success_log "The base directory ${ORACLE_BASE} has been created !"
    fi
    if [ -d ${ORACLE_HOME} ];then
        print_success_log "The home directory ${ORACLE_HOME} already exists !"
    else
        print_error_log "Warning: The home directory ${ORACLE_HOME} doesn't exists and will be created"
        mkdir -p ${ORACLE_HOME}
        print_success_log "The home directory ${ORACLE_HOME} has been created !"
    fi
    print_log "   Creating user and install directory end"
}
function move_dbsoft(){
    print_log "9. Moving database software to $ORACLE_HOME begin"
    if [ ! -f ${PACKAGE_FILE} ];then
        print_success_log "The ${PACKAGE_FILE} doesn't exists,pelase confirm it !"
        exit 99
    fi 
    file_count=$(ls ${ORACLE_HOME} | wc -l)
    if [ ${file_count} -eq 1 ];then
        print_sub_log "The database product file already exists in ${ORACLE_HOME},skip"
    else
        print_sub_log "Copying begin"
        cp -fnr ${PACKAGE_FILE} ${ORACLE_HOME}
        print_sub_log "Copying end"
    fi
    print_sub_log "Please grant user privilege to $ORACLE_BASE"
    PARENT_DIR=$(echo "${ORACLE_BASE}" | grep -oP '^/\K[^/]+') 
    chown oracle.oinstall -R /${PARENT_DIR}
    print_sub_log "Privilege has been changed ,current /${PARENT_DIR} owner as following "
    print_sub_log "$(ls -l /u01/ | awk '{print "owner:" $3,"primary group:" $4}'|tail -1) "
    print_log "   Moving database software end"
}

function config_env(){
    print_log "10. Configuring oracle user env begin"
    su - oracle&>/dev/null<<EOF
        delete_flag=$(basename `echo ${ORACLE_BASE} | awk -F'=' '{print $2}'`)
        sed -i '/${delete_flag}/d' ~/.bashrc
EOF
    su - oracle&>/dev/null<<EOF
        echo "export ORACLE_BASE=${ORACLE_BASE}" >>~/.bashrc
        echo "export ORACLE_HOME=${ORACLE_HOME}" >>~/.bashrc
        echo "export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}" >>~/.bashrc
        echo "export ORACLE_SID=${ORACLE_SID}" >>~/.bashrc
        echo "export PATH=${PATH}" >>~/.bashrc
EOF
    print_log "    Configuring oracle user end"
}

function remove_ora_files(){
    print_log "11. Checking oraInst.loc and oratab whether exists or not begin"
    if [ -f /etc/oraInst.loc ];then
        print_error_log "ERROR:The file /etc/oraInst.loc already exists,please remove it !"
        exit 99
    else
        print_success_log "/etc/oraInst.loc file doesn't exist,passed !" 
    fi
    if [ -f /etc/oratab ];then
        print_error_log "ERROR:The file /etc/oratab already exists,please remove it !"
        exit 99
    else
        print_success_log "/etc/oratab file doesn't exist,passed !" 
    fi
   
    print_log "    Checking oraInst.loc and oratab whether exists or not end"
}

function unzip_file(){
    print_log "12. Unzip database product file begin"
    cd ${ORACLE_HOME}
    dir_count=$(ls ${ORACLE_HOME} | wc -l)
    if [ ${dir_count} -lt 1 ];then
        print_error_log "The directory exists other files or directories,pelase cleaning it"
    else
        cd ${ORACLE_HOME}
        file_name=$(ls ${ORACLE_HOME})
        unzip -q ${ORACLE_HOME}/${file_name}
        chown oracle.oinstall -R /${PARENT_DIR}        
    fi
    print_log "    Unzip database product file end"
}

function config_copy_rsp(){
    print_sub_log "copy response file to ${TOPLEVEL_DIR}/response directory"
    rm -f ${TOPLEVEL_DIR}/response/db_install.rsp
    cp ${ORACLE_HOME}/install/response/db_install.rsp ${TOPLEVEL_DIR}/response/
}

function install_opts(){

        print_sub_log "Setting database type"
        sed -i "s/oracle.install.db.config.starterdb.type=/oracle.install.db.config.starterdb.type=GENERAL_PURPOSE/" ${TOPLEVEL_DIR}/response/db_install.rsp

        print_sub_log "Setting database global name"
        if [[ "${GLOBAL_NAME}" == "" ]];then
            print_warning_log "Global name doesn't been specified by user,default using ${ORACLE_SID}"
            sed -i "s/oracle.install.db.config.starterdb.globalDBName=/oracle.install.db.config.starterdb.globalDBName=${ORACLE_SID}/" ${TOPLEVEL_DIR}/response/db_install.rsp
        else
            sed -i "s/oracle.install.db.config.starterdb.globalDBName=/oracle.install.db.config.starterdb.globalDBName=${GLOBAL_NAME}/" ${TOPLEVEL_DIR}/response/db_install.rsp
        fi
        print_sub_log "Setting database sid name"
        sed -i "s/oracle.install.db.config.starterdb.SID=/oracle.install.db.config.starterdb.SID=${ORACLE_SID}/" ${TOPLEVEL_DIR}/response/db_install.rsp
}

function is_use_pdb(){
    if [[ "${IS_USE_PDB}" == "" ]];then
        print_sub_log "Setting pdb,defaults false"
        sed -i "s/oracle.install.db.ConfigureAsContainerDB=/oracle.install.db.ConfigureAsContainerDB=false/" ${TOPLEVEL_DIR}/response/db_install.rsp
    else 
        print_sub_log "There will be used pdb"
        sed -i "s/oracle.install.db.ConfigureAsContainerDB=/oracle.install.db.ConfigureAsContainerDB=true/" ${TOPLEVEL_DIR}/response/db_install.rsp
        
        print_sub_log "Setting pdb name"
        sed -i "s/oracle.install.db.config.PDBName=/oracle.install.db.config.PDBName=${PDB_NAME}/" ${TOPLEVEL_DIR}/response/db_install.rsp
    fi
}

function config_charset(){
    print_sub_log "Setting character set"
    sed -i "s/oracle.install.db.config.starterdb.characterSet=/oracle.install.db.config.starterdb.characterSet=${CHARACTER_SET}/" ${TOPLEVEL_DIR}/response/db_install.rsp
}

function is_auto_memory(){
    if [[ "${IS_AUTO_MEMORY}" == "false" ]];then
        print_sub_log "Setting memory management method"
        sed -i "s/oracle.install.db.config.starterdb.memoryOption=/oracle.install.db.config.starterdb.memoryOption=${IS_AUTO_MEMORY}/" ${TOPLEVEL_DIR}/response/db_install.rsp

        print_sub_log "Setting memory size limit"
        sed -i "s/oracle.install.db.config.starterdb.memoryLimit=/oracle.install.db.config.starterdb.memoryLimit=${MEMORY_LIMIT}/" ${TOPLEVEL_DIR}/response/db_install.rsp
    else
        print_sub_log "Memory management method is auto management"
        sed -i "s/oracle.install.db.config.starterdb.memoryOption=/oracle.install.db.config.starterdb.memoryOption=${IS_AUTO_MEMORY}/" ${TOPLEVEL_DIR}/response/db_install.rsp
    fi
}

function is_use_template(){
    if [[ "${IS_USE_TEMPLATE}" == "" ]];then
        print_sub_log "Installing template false"
        sed -i "s/oracle.install.db.config.starterdb.installExampleSchemas=/oracle.install.db.config.starterdb.installExampleSchemas=${IS_USE_TEMPLATE}/" ${TOPLEVEL_DIR}/response/db_install.rsp
    else
        print_sub_log "Installing template true"
        sed -i "s/oracle.install.db.config.starterdb.installExampleSchemas=/oracle.install.db.config.starterdb.installExampleSchemas=${IS_USE_TEMPLATE}/" ${TOPLEVEL_DIR}/response/db_install.rsp
    fi
}

function setting_account_pass(){
    print_sub_log "Setting all account password"
    sed -i "s/oracle.install.db.config.starterdb.password.ALL=/oracle.install.db.config.starterdb.password.ALL=${ALL_ACCOUNT_PASS}/" ${TOPLEVEL_DIR}/response/db_install.rsp
    print_sub_log "Setting storage mode"
}


function file_storage_mode(){
    sed -i "s/oracle.install.db.config.starterdb.storageType=/oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE/" ${TOPLEVEL_DIR}/response/db_install.rsp
    print_sub_log "Specifying data file location,default: ${ORACLE_BASE}/oradata"
    top_ora_data=${ORACLE_BASE}/oradata
    ora_data=$(echo ${top_ora_data}/ | sed 's#/#\\/#g')
    sed -i "s/oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=/oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=${ora_data}/" ${TOPLEVEL_DIR}/response/db_install.rsp

    print_sub_log "Specifying recovery localtion,default: ${ORACLE_BASE}/fast_recovery_area"
    top_ora_fast_reco=${ORACLE_BASE}/fast_recovery_area
    ora_fast_reco=$(echo ${top_ora_fast_reco}/ | sed 's#/#\\/#g')
    sed -i "s/oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=/oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=${ora_fast_reco}/" ${TOPLEVEL_DIR}/response/db_install.rsp
}

function config_user_group(){
    print_sub_log "Unix group will be setting oinstall"
    sed -i "s/UNIX_GROUP_NAME=/UNIX_GROUP_NAME=oinstall/" ${TOPLEVEL_DIR}/response/db_install.rsp  
    print_sub_log "Setting dba group"
    sed -i "s/oracle.install.db.OSDBA_GROUP=/oracle.install.db.OSDBA_GROUP=dba/" ${TOPLEVEL_DIR}/response/db_install.rsp

    print_sub_log "Setting oper group"
    sed -i "s/oracle.install.db.OSOPER_GROUP=/oracle.install.db.OSOPER_GROUP=oper/" ${TOPLEVEL_DIR}/response/db_install.rsp

    print_sub_log "Setting dgdba group"
    sed -i "s/oracle.install.db.OSDGDBA_GROUP=/oracle.install.db.OSDGDBA_GROUP=dgdba/" ${TOPLEVEL_DIR}/response/db_install.rsp

    print_sub_log "Setting backupdba group"
    sed -i "s/oracle.install.db.OSBACKUPDBA_GROUP=/oracle.install.db.OSBACKUPDBA_GROUP=backupdba/" ${TOPLEVEL_DIR}/response/db_install.rsp

    print_sub_log "Setting kmdba group"
    sed -i "s/oracle.install.db.OSKMDBA_GROUP=/oracle.install.db.OSKMDBA_GROUP=kmdba/" ${TOPLEVEL_DIR}/response/db_install.rsp

    print_sub_log "Setting racdba group"
    sed -i "s/oracle.install.db.OSRACDBA_GROUP=/oracle.install.db.OSRACDBA_GROUP=racdba/" ${TOPLEVEL_DIR}/response/db_install.rsp
}

function config_ora_oraInv(){
    print_sub_log "Setting inventory directory"
    top_ora_base=$(dirname ${ORACLE_BASE})
    oraInst=$(echo ${top_ora_base}/oraInventory | sed 's#/#\\/#g')
    sed -i "s/INVENTORY_LOCATION=/INVENTORY_LOCATION=${oraInst}/" ${TOPLEVEL_DIR}/response/db_install.rsp
}

function config_ora_dir(){
    print_sub_log "Setting ORACLE_HOME"
    ora_home=$(echo ${ORACLE_HOME} | sed 's#/#\\/#g')
    sed -i "s/ORACLE_HOME=/ORACLE_HOME=${ora_home}/" ${TOPLEVEL_DIR}/response/db_install.rsp

    print_sub_log "Setting ORACLE_BASE"
    ora_base=$(echo ${ORACLE_BASE} | sed 's#/#\\/#g')
    sed -i "s/ORACLE_BASE=/ORACLE_BASE=${ora_base}/" ${TOPLEVEL_DIR}/response/db_install.rsp
}

function config_db_version(){
    print_sub_log "Setting install version"
    sed -i "s/oracle.install.db.InstallEdition=/oracle.install.db.InstallEdition=EE/" ${TOPLEVEL_DIR}/response/db_install.rsp

}

function config_exec_root(){
    print_sub_log "Setting root scripts mode"
    sed -i "s/oracle.install.db.rootconfig.executeRootScript=/oracle.install.db.rootconfig.executeRootScript=true/" ${TOPLEVEL_DIR}/response/db_install.rsp

    print_sub_log "Setting root scripts methods"
    sed -i "s/oracle.install.db.rootconfig.configMethod=/oracle.install.db.rootconfig.configMethod=ROOT/" ${TOPLEVEL_DIR}/response/db_install.rsp
}

function last_modify_priv(){
    chown oracle.oinstall ${TOPLEVEL_DIR}/response/db_install.rsp
    mv ${TOPLEVEL_DIR}/response/db_install.rsp ${ORACLE_HOME}
    su - oracle -c "cp ${ORACLE_HOME}/db_install.rsp ${ORACLE_HOME}/inventory/Scripts/"  
}
function config_rsp_file(){
    print_log "13. Configuring response file begin"
    config_copy_rsp

    if [[ "${INSTALL_OPTIONS}" == "" ]];then
        print_sub_log "Installing option mode,default: INSTALL_DB_AND_CONFIG"
        sed -i "s/oracle.install.option=/oracle.install.option=INSTALL_DB_AND_CONFIG/" ${TOPLEVEL_DIR}/response/db_install.rsp
        install_opts
        is_use_pdb
        config_charset
        is_auto_memory
        is_use_template
        setting_account_pass

    elif [[ "${INSTALL_OPTIONS}" == "INSTALL_DB_AND_CONFIG" ]]; then
        print_sub_log "Installing option mode:INSTALL_DB_AND_CONFIG"
        sed -i "s/oracle.install.option=/oracle.install.option=INSTALL_DB_AND_CONFIG/" ${TOPLEVEL_DIR}/response/db_install.rsp
        install_opts
        is_use_pdb
        config_charset
        is_auto_memory
        is_use_template
        setting_account_pass
    else 
        print_sub_log "install option mode: ${INSTALL_OPTIONS}"
        sed -i "s/oracle.install.option=/oracle.install.option=INSTALL_DB_SWONLY/" ${TOPLEVEL_DIR}/response/db_install.rsp
    fi


    if [[ "${FILE_STRAGE_MODE}" == "" ]];then
        print_sub_log "Setting storage mode,defaults:[FILE_SYSTEM_STORAGE]"
        file_storage_mode
    else 
        print_sub_log "Setting storage mode: ${FILE_STORAGE_MODE}" 
        file_storage_mode
        
    fi
    
    config_exec_root
    config_user_group

    config_ora_oraInv

    config_ora_dir

    config_db_version

    last_modify_priv

    print_log "    Configuring response file end"
}


function install_database(){
    print_log "14. Installing software begin"
    print_sub_log "Please check ${TOPLEVEL_DIR}/log/success.log and input root password and press enter key"

    su - oracle -c "cd $ORACLE_HOME; ./runInstaller -silent -responseFile ${ORACLE_HOME}/db_install.rsp" >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
    check_install_status=$(egrep -i "error|fatal|no such" ${ERROR_LOG}| wc -l)
    if [ ${check_install_status} -ge 1 ];then
        print_error_log "Installing found error,Please check error ${ERROR_LOG}"
        exit 99
    fi
    print_log "    Installing software successfully"

    print_log "15. Create database begin"
    su - oracle -c "cd $ORACLE_HOME; /u01/app/oracle/product/19.0.0.0/dbhome_1/runInstaller -executeConfigTools -responseFile db_install.rsp -silent" >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
    print_log "    Create database successfully"
}
