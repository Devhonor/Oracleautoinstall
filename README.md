***
#先决条件(requirements)
配置好yum仓库
Completing configuration of yum repository

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
[root@server ~]# mkdir -p /opt/software/
[root@server oracleautoinstall]# pwd
/opt/software/oracleautoinstall
[root@server oracleautoinstall]# ls
bin  conf  exec  lib  log  response  tools
```
2. 编辑 conf/env.cnf 文件
```
#Define Install Name 
#指定安装名称
INSTALL_NAME="Oracle Database"  #specifying any string

#指定数据库软件的路径
PACKAGE_FILE=/opt/software/LINUX.X64_193000_db_home.zip #specifying location of software package

#指定 Oracle 的基础路径
ORACLE_BASE=/u01/app/oracle #setting oracle base directory

#指定 Oracle 产品的安装路径
ORACLE_HOME=${ORACLE_BASE}/product/19.0.0.0/dbhome_1 #setting oracle product install directory

#指定Oracle客户端命令使用的lib库路径
LD_LIBRARY_PATH=${ORACLE_HOME}/lib:${LD_LIBRARY_PATH} #setting lib library will be called by sqlplus etc

#指定 Oracle 的实例名称
ORACLE_SID=ora19c #setting system identifier

#指定 Oracle 的可执行路径
PATH=${ORACLE_HOME}/bin:${PATH} #setting execute file path

#指定网卡名称
NIC_NAME=ens33 #specify network interface card name,must be options

#指定主机名称
HOSTNAME=server  #setting host name

#指定安装选项,不指定则使用默认安装方式
INSTALL_OPTIONS=  #if have no value,will be used defaults

#指定Oracle 全局名称，不指定则默认使用 Oracle 实例名称
GLOBAL_NAME= #if have no value,will be used ORACLE_SID

#指定是否使用 PDB，不指定则默认不使用 CDB
IS_USE_PDB=true #if have no value,will be used false

#指定 PDB 的名称，依赖于上一个参数
PDB_NAME=ora19cpdb #if IS_USE_PDB is ture ,the parameter must be configured

#指定字符集
CHARACTER_SET=AL32UTF8 #must be specified which can be supported by oracle

#使用自动内存管理,不指定则使用自动内存管理
IS_AUTO_MEMORY=false #if have no value,will be used auto memory ,recommend setting false

#指定内存大小
MEMORY_LIMIT=2048 #if IS_AUTO_MEMORY is false which value must be specified

#是否安装模版
IS_USE_TEMPLATE=false #whether install template or not

#指定账户密码
ALL_ACCOUNT_PASS=Bigdata_123 #specifying all administrator account password

#指定文件存储模式，不指定默认使用文件系统存储
FILE_STORAGE_MODE= #if have no value,will be used default value:FILE_SYSTEM_STORAGE. option value:FILE_SYSTEM_STORAGE |ASM_STORAGE

```

3. 切换到bin目录执行 sh install.sh 
***强调的斜体*** 注意:
- 在第8步的时候需要为oracle用户设置一个密码 (In step 8, you need to set a password for the Oracle user.)

- 在执行到14步以后，需要手动输入密码，何时输入密码请打开另外一个终端，使用 vi 或者 vim 编辑 log/success.log 文件，然后使用 shift + G，如果看到 password 关键字，则在窗口中输入root用户的密码即可，然后等待数据库创建完成即可。(After reaching step 14, you will need to manually input the password. To do this, open another terminal and use vi or vim to edit the log/success.log file. Then use shift + G to go to the end of the file. If you see the keyword 'password', enter the root user's password in the window. After entering the password, wait for the database creation to complete.)

```bash
[root@server bin]# sh install.sh install
[2024-09-13 AM 02:39:38]  ########################### [Oracle Database] Begin install ########################### 
[2024-09-13 AM 02:39:38]  1. Configuring hostname and dns begin 
[2024-09-13 AM 02:39:38]        hostname configuration successfully! 
[2024-09-13 AM 02:39:38]     Configuring hostname end 
[2024-09-13 AM 02:39:38]  2. Checking firwalld begin 
[2024-09-13 AM 02:39:38]        Firewall has been forbiden !
[2024-09-13 AM 02:39:38]     Checking firwalld end 
[2024-09-13 AM 02:39:38]  3. Checking selinux begin 
[2024-09-13 AM 02:39:38]        Selinux has been disabled 
[2024-09-13 AM 02:39:38]     Checking selinux end 
[2024-09-13 AM 02:39:38]  4. Checking user group begin  
[2024-09-13 AM 02:39:38]        Oracle user already exists ! 
[2024-09-13 AM 02:39:38]     Checking user group end  
[2024-09-13 AM 02:39:38]  5. Checking software dependences and installing loss software begin 
[2024-09-13 AM 02:39:38]        The package bc has been installed ! 
[2024-09-13 AM 02:39:38]        The package binutils has been installed ! 
[2024-09-13 AM 02:39:39]        The package compat-libcap1 has been installed ! 
[2024-09-13 AM 02:39:39]        The package compat-libstdc++-33 has been installed ! 
[2024-09-13 AM 02:39:39]        The package elfutils-libelf will be installed !
[2024-09-13 AM 02:39:40]        The package elfutils-libelf install successfully 
[2024-09-13 AM 02:39:40]        The package elfutils-libelf-devel has been installed ! 
[2024-09-13 AM 02:39:41]        The package fontconfig-devel has been installed ! 
[2024-09-13 AM 02:39:41]        The package glibc will be installed !
[2024-09-13 AM 02:39:42]        The package glibc install successfully 
[2024-09-13 AM 02:39:42]        The package glibc-devel has been installed ! 
[2024-09-13 AM 02:39:42]        The package ksh has been installed ! 
[2024-09-13 AM 02:39:43]        The package libaio will be installed !
[2024-09-13 AM 02:39:43]        The package libaio install successfully 
[2024-09-13 AM 02:39:44]        The package libaio-devel has been installed ! 
[2024-09-13 AM 02:39:44]        The package libXrender will be installed !
[2024-09-13 AM 02:39:44]        The package libXrender install successfully 
[2024-09-13 AM 02:39:45]        The package libXrender-devel has been installed ! 
[2024-09-13 AM 02:39:45]        The package libX11 will be installed !
[2024-09-13 AM 02:39:45]        The package libX11 install successfully 
[2024-09-13 AM 02:39:46]        The package libXau will be installed !
[2024-09-13 AM 02:39:46]        The package libXau install successfully 
[2024-09-13 AM 02:39:47]        The package libXi has been installed ! 
[2024-09-13 AM 02:39:47]        The package libXtst has been installed ! 
[2024-09-13 AM 02:39:47]        The package libgcc has been installed ! 
[2024-09-13 AM 02:39:48]        The package libstdc++ will be installed !
[2024-09-13 AM 02:39:48]        The package libstdc++ install successfully 
[2024-09-13 AM 02:39:49]        The package libstdc++-devel has been installed ! 
[2024-09-13 AM 02:39:49]        The package libxcb will be installed !
[2024-09-13 AM 02:39:50]        The package libxcb install successfully 
[2024-09-13 AM 02:39:50]        The package make has been installed ! 
[2024-09-13 AM 02:39:50]        The package policycoreutils will be installed !
[2024-09-13 AM 02:39:51]        The package policycoreutils install successfully 
[2024-09-13 AM 02:39:51]        The package policycoreutils-python has been installed ! 
[2024-09-13 AM 02:39:51]        The package smartmontools has been installed ! 
[2024-09-13 AM 02:39:52]        The package sysstat has been installed ! 
[2024-09-13 AM 02:39:52]     Checking software dependences and installing loss software end 
[2024-09-13 AM 02:39:52]  6. Configuring kernel parameters begin 
[2024-09-13 AM 02:39:52]        Kernel parameter configuration completed ! 
[2024-09-13 AM 02:39:52]     Configuring kernel parameters end 
[2024-09-13 AM 02:39:52]  7. Configuring resource limits begin 
[2024-09-13 AM 02:39:52]        Resource limits configuration completed ! 
[2024-09-13 AM 02:39:52]     Configuring resource limits end 
[2024-09-13 AM 02:39:52]  8. Creating user and install directory begin 
[2024-09-13 AM 02:39:52]        User oracle exists
[2024-09-13 AM 02:39:52]        Group oinstall exists !
[2024-09-13 AM 02:39:52]        Create user oracle and group 
[2024-09-13 AM 02:39:52]        Setting oracle user password
Please input oracle os user's password: oracle
Please confirm oracle os user's password: oracle
[2024-09-13 AM 02:39:54]        Setting oracle user password successfully !
[2024-09-13 AM 02:39:54]        Warning: The directory  doesn't exists and will be created 
[2024-09-13 AM 02:39:54]        The base directory /u01/app/oracle has been created ! 
[2024-09-13 AM 02:39:54]        The home directory /u01/app/oracle/product/19.0.0.0/dbhome_1 already exists ! 
[2024-09-13 AM 02:39:54]     Creating user and install directory end 
[2024-09-13 AM 02:39:54]  9. Moving database software to /u01/app/oracle/product/19.0.0.0/dbhome_1 begin 
[2024-09-13 AM 02:39:54]        Copying begin
[2024-09-13 AM 02:39:55]        Copying end
[2024-09-13 AM 02:39:55]        Please grant user privilege to /u01/app/oracle
[2024-09-13 AM 02:39:55]        Privilege has been changed ,current /u01 owner as following 
[2024-09-13 AM 02:39:55]        owner:oracle primary group:oinstall 
[2024-09-13 AM 02:39:55]     Moving database software end 
[2024-09-13 AM 02:39:55]  10. Configuring oracle user env begin 
[2024-09-13 AM 02:39:56]      Configuring oracle user end 
[2024-09-13 AM 02:39:56]  11. Checking oraInst.loc and oratab whether exists or not begin 
[2024-09-13 AM 02:39:56]        /etc/oraInst.loc file doesn't exist,passed ! 
[2024-09-13 AM 02:39:56]        /etc/oratab file doesn't exist,passed ! 
[2024-09-13 AM 02:39:56]      Checking oraInst.loc and oratab whether exists or not end 
[2024-09-13 AM 02:39:56]  12. Unzip database product file begin 
[2024-09-13 AM 02:40:56]      Unzip database product file end 
[2024-09-13 AM 02:40:56]  13. Configuring response file begin 
[2024-09-13 AM 02:40:56]        copy response file to /opt/software/oracleautoinstall/response directory
[2024-09-13 AM 02:40:56]        Installing option mode,default: INSTALL_DB_AND_CONFIG
[2024-09-13 AM 02:40:56]        Setting database type
[2024-09-13 AM 02:40:56]        Setting database global name
[2024-09-13 AM 02:40:56]        Global name doesn't been specified by user,default using ora19c 
[2024-09-13 AM 02:40:56]        Setting database sid name
[2024-09-13 AM 02:40:56]        There will be used pdb
[2024-09-13 AM 02:40:56]        Setting pdb name
[2024-09-13 AM 02:40:56]        Setting character set
[2024-09-13 AM 02:40:56]        Setting memory management method
[2024-09-13 AM 02:40:56]        Setting memory size limit
[2024-09-13 AM 02:40:56]        Installing template true
[2024-09-13 AM 02:40:56]        Setting all account password
[2024-09-13 AM 02:40:56]        Setting storage mode
[2024-09-13 AM 02:40:56]        Setting storage mode,defaults:[FILE_SYSTEM_STORAGE]
[2024-09-13 AM 02:40:56]        Specifying data file location,default: /u01/app/oracle/oradata
[2024-09-13 AM 02:40:56]        Specifying recovery localtion,default: /u01/app/oracle/fast_recovery_area
[2024-09-13 AM 02:40:56]        Setting root scripts mode
[2024-09-13 AM 02:40:56]        Setting root scripts methods
[2024-09-13 AM 02:40:56]        Unix group will be setting oinstall
[2024-09-13 AM 02:40:56]        Setting dba group
[2024-09-13 AM 02:40:56]        Setting oper group
[2024-09-13 AM 02:40:56]        Setting dgdba group
[2024-09-13 AM 02:40:56]        Setting backupdba group
[2024-09-13 AM 02:40:56]        Setting kmdba group
[2024-09-13 AM 02:40:56]        Setting racdba group
[2024-09-13 AM 02:40:56]        Setting inventory directory
[2024-09-13 AM 02:40:56]        Setting ORACLE_HOME
[2024-09-13 AM 02:40:56]        Setting ORACLE_BASE
[2024-09-13 AM 02:40:56]        Setting install version
[2024-09-13 AM 02:40:56]      Configuring response file end 
[2024-09-13 AM 02:40:56]  14. Installing software begin 
[2024-09-13 AM 02:40:56]        Please check /opt/software/oracleautoinstall/log/success.log and input root password and press enter key
redhat   #input root password in here(这里输入的是root用户密码)
[2024-09-13 AM 02:43:32]      Installing software successfully 
[2024-09-13 AM 02:43:32]  15. Create database begin 
[2024-09-13 AM 02:54:54]      Create database successfully 
[2024-09-13 AM 02:54:54]  ########################### [Oracle Database] End install   ########################### 
Running cost time: 915.92 seconds,Fri Sep 13 02:54:54 CST 2024 
```

4. 验证(Verifying)
```
[root@server bin]# cd
[root@server ~]# su - oracle
Last login: Fri Sep 13 02:43:32 CST 2024 on pts/1
[oracle@server ~]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Fri Sep 13 03:12:13 2024
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> 

```


