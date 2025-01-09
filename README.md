***
#先决条件(requirements)
无(None)

***
#使用说明(using manual)
-  当前自动安装脚本适用于红帽家族 7.9 系统，其它版本未做测试，请根据环境自己测试
-  The current auto-install scripts are compatible with Red Hat family OS version 7.9. Other versions have not been verified, so please test it when using on those.

####配置文件(configuration files)
-  配置文件包括两个，一个日志配置文件，一个环境配置文件，日志配置文件不用做任何改动，环境配置文件需要手动配置。
There are two files in the conf folder: one for log configuration and one for environment settings. You do not need to change the log configuration file, but you need to modify the parameter values in the environment file.
***

#使用步骤(using steps)
1. 使用 root 用户上传文件到任意目录
Upload  files to any directory using root user
```bash
#example directory is /opt/software
[root@server software]# pwd
/opt/software
[root@server software]# ls oracleautoinstall
bin  conf  exec  lib  log  README.md  response  rpm  tools
```
2. 编辑 conf/env.cnf 文件
```
[root@server software]# cat oracleautoinstall/conf/env.cnf 
#Define Install Name 
INSTALL_NAME="Oracle Database"  #specifying any string

PACKAGE_FILE=/opt/software/LINUX.X64_193000_db_home.zip #specifying location of software package

ORACLE_BASE=/u01/app/oracle #setting oracle base directory

ORACLE_HOME=${ORACLE_BASE}/product/19.0.0.0/dbhome_1 #setting oracle product install directory

LD_LIBRARY_PATH=${ORACLE_HOME}/lib:${LD_LIBRARY_PATH} #setting lib library will be called by sqlplus etc

ORACLE_SID=oradb #setting system identifier

PATH=${ORACLE_HOME}/bin:${PATH} #setting execute file path

NIC_NAME=ens33 #specify network interface card name,must be options

HOSTNAME=server  #setting host name

ORACLEUSERPASSWORD=oracle #specify oracle user password

INSTALL_OPTIONS=  #if have no value,will be used defaults

GLOBAL_NAME= #if have no value,will be used ORACLE_SID

IS_USE_PDB=true #if have no value,will be used false

PDB_NAME=ora19cpdb #if IS_USE_PDB is ture ,the parameter must bee configured

CHARACTER_SET=AL32UTF8 #must be specified which can be supported by oracle

IS_AUTO_MEMORY=false #if have no value,will be used auto memory ,recommend setting false

MEMORY_LIMIT=2048 #if IS_AUTO_MEMORY is false which value must be specified

IS_USE_TEMPLATE=false #whether install template or not

ALL_ACCOUNT_PASS=Bigdata_123 #specifying all administrator account password

FILE_STORAGE_MODE= #if have no value,will be used default value:FILE_SYSTEM_STORAGE. option value:FILE_SYSTEM_STORAGE |ASM_STORAGE

```

3. 切换到bin目录执行 sh install.sh 

```bash
[root@server bin]# sh install.sh install
[2025-01-09 PM 22:20:38]  ########################### [Oracle Database] Begin install ########################### 
[2025-01-09 PM 22:20:38]  1. Configuring hostname and dns begin 
[2025-01-09 PM 22:20:38]        hostname configuration successfully! 
[2025-01-09 PM 22:20:38]     Configuring hostname end 
[2025-01-09 PM 22:20:38]  2. Checking firwalld begin 
[2025-01-09 PM 22:20:38]        Firewall has been forbiden !
[2025-01-09 PM 22:20:38]     Checking firwalld end 
[2025-01-09 PM 22:20:38]  3. Checking selinux begin 
[2025-01-09 PM 22:20:38]        Selinux has been disabled 
[2025-01-09 PM 22:20:38]     Checking selinux end 
[2025-01-09 PM 22:20:38]  4. Checking user group begin  
[2025-01-09 PM 22:20:38]        Oracle user already exists ! 
[2025-01-09 PM 22:20:38]        Addming sudo privileges
[2025-01-09 PM 22:20:38]     Checking user group end  
[2025-01-09 PM 22:20:38]  5. Installing dependences packages begin 
[2025-01-09 PM 22:20:39]        installing .......
[2025-01-09 PM 22:20:41]        installing complete
[2025-01-09 PM 22:20:41]     Installing dependences packages begin end 
[2025-01-09 PM 22:20:41]  6. Configuring kernel parameters begin 
[2025-01-09 PM 22:20:41]        Kernel parameter configuration completed ! 
[2025-01-09 PM 22:20:41]     Configuring kernel parameters end 
[2025-01-09 PM 22:20:41]  7. Configuring resource limits begin 
[2025-01-09 PM 22:20:41]        Resource limits configuration completed ! 
[2025-01-09 PM 22:20:41]     Configuring resource limits end 
[2025-01-09 PM 22:20:41]  8. Creating user and install directory begin 
[2025-01-09 PM 22:20:41]        User oracle exists
[2025-01-09 PM 22:20:41]        Group oinstall exists !
[2025-01-09 PM 22:20:41]        Create user oracle and group 
[2025-01-09 PM 22:20:41]        Setting oracle user password
[2025-01-09 PM 22:20:41]        Warning: The directory  doesn't exists and will be created 
[2025-01-09 PM 22:20:41]        The base directory /u01/app/oracle has been created ! 
[2025-01-09 PM 22:20:41]        The home directory /u01/app/oracle/product/19.0.0.0/dbhome_1 already exists ! 
[2025-01-09 PM 22:20:41]     Creating user and install directory end 
[2025-01-09 PM 22:20:41]  9. Moving database software to /u01/app/oracle/product/19.0.0.0/dbhome_1 begin 
[2025-01-09 PM 22:20:41]        Copying begin
[2025-01-09 PM 22:20:50]        Copying end
[2025-01-09 PM 22:20:50]        Please grant user privilege to /u01/app/oracle
[2025-01-09 PM 22:20:50]        Privilege has been changed ,current /u01 owner as following 
[2025-01-09 PM 22:21:03]        owner:oracle primary group:oinstall 
[2025-01-09 PM 22:21:03]     Moving database software end 
[2025-01-09 PM 22:21:03]  10. Configuring oracle user env begin 
[2025-01-09 PM 22:21:03]      Configuring oracle user end 
[2025-01-09 PM 22:21:03]  11. Checking oraInst.loc and oratab whether exists or not begin 
[2025-01-09 PM 22:21:03]        /etc/oraInst.loc file doesn't exist,passed ! 
[2025-01-09 PM 22:21:03]        /etc/oratab file doesn't exist,passed ! 
[2025-01-09 PM 22:21:03]      Checking oraInst.loc and oratab whether exists or not end 
[2025-01-09 PM 22:21:03]  12. Unzip database product file begin 
[2025-01-09 PM 22:21:45]      Unzip database product file end 
[2025-01-09 PM 22:21:45]  13. Configuring response file begin 
[2025-01-09 PM 22:21:45]        copy response file to /opt/software/oracleautoinstall/response directory
[2025-01-09 PM 22:21:45]        Installing option mode,default: INSTALL_DB_AND_CONFIG
[2025-01-09 PM 22:21:45]        Setting database type
[2025-01-09 PM 22:21:45]        Setting database global name
[2025-01-09 PM 22:21:45]        Global name doesn't been specified by user,default using ora19c 
[2025-01-09 PM 22:21:45]        Setting database sid name
[2025-01-09 PM 22:21:45]        There will be used pdb
[2025-01-09 PM 22:21:45]        Setting pdb name
[2025-01-09 PM 22:21:45]        Setting character set
[2025-01-09 PM 22:21:45]        Setting memory management method
[2025-01-09 PM 22:21:45]        Setting memory size limit
[2025-01-09 PM 22:21:45]        Installing template true
[2025-01-09 PM 22:21:45]        Setting all account password
[2025-01-09 PM 22:21:45]        Setting storage mode
[2025-01-09 PM 22:21:45]        Setting storage mode,defaults:[FILE_SYSTEM_STORAGE]
[2025-01-09 PM 22:21:45]        Specifying data file location,default: /u01/app/oracle/oradata
[2025-01-09 PM 22:21:45]        Specifying recovery localtion,default: /u01/app/oracle/fast_recovery_area
[2025-01-09 PM 22:21:45]        Setting root scripts mode
[2025-01-09 PM 22:21:45]        Setting root scripts methods
[2025-01-09 PM 22:21:45]        Setting sudo path
[2025-01-09 PM 22:21:45]        Setting sudo user list
[2025-01-09 PM 22:21:45]        Unix group will be setting oinstall
[2025-01-09 PM 22:21:45]        Setting dba group
[2025-01-09 PM 22:21:45]        Setting oper group
[2025-01-09 PM 22:21:45]        Setting dgdba group
[2025-01-09 PM 22:21:45]        Setting backupdba group
[2025-01-09 PM 22:21:45]        Setting kmdba group
[2025-01-09 PM 22:21:45]        Setting racdba group
[2025-01-09 PM 22:21:45]        Setting inventory directory
[2025-01-09 PM 22:21:45]        Setting ORACLE_HOME
[2025-01-09 PM 22:21:45]        Setting ORACLE_BASE
[2025-01-09 PM 22:21:45]        Setting install version
[2025-01-09 PM 22:21:45]      Configuring response file end 
[2025-01-09 PM 22:21:45]  14. Installing software begin 
[2025-01-09 PM 22:21:45]        More info please check /opt/software/oracleautoinstall/log/success.log
[2025-01-09 PM 22:23:58]      Installing software successfully 
[2025-01-09 PM 22:23:58]  15. Create database begin 
[2025-01-09 PM 22:35:37]      Create database successfully 
[2025-01-09 PM 22:35:37]  16. Cancel sudo privilege for oracle 
[2025-01-09 PM 22:35:37]  ########################### [Oracle Database] End install   ########################### 
Running cost time: 898.84 seconds,Thu Jan  9 22:35:37 CST 2025 

```

4. 验证(Verifying)
```
[root@server software]# su - oracle
Last login: Thu Jan  9 22:46:58 CST 2025 on pts/0
[oracle@server ~]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Thu Jan 9 23:01:16 2025
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> select current_timestamp from dual;

CURRENT_TIMESTAMP
---------------------------------------------------------------------------
09-JAN-25 11.01.21.745145 PM +08:00


```


