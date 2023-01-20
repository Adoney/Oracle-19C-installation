-- -----------------------------------------------------------------------------------
-- File Name    : https://github.com/Adoney/Oracle-19C-installation.git
-- Author       : Jackson Adonia
-- Description  : Oracle 19c installation guide
-- Last Modified: 20/01/2023
-- -----------------------------------------------------------------------------------

========================================================================================================

PRE INSTALLATION DB CHECKS

========================================================================================================

Services 
service --status-all | more
service --status-all | grep ntpd
service --status-all | less

============== **Hardware**================

1. Architecture (Should be the one intended. Either 32bit or 64bit)
uname -m

2. Runlevel (Should be 3 or 5)
cat /proc/cpuinfo | Runlevel

3. Local disk space for oracle software (atleast 6.4GB)
free

4. RAM (Should be not less than 8GB)
grep MemTotal /proc/meminfo

5. Check Storage Hardware
df -h 

6. To determine the distribution and version of Linux installed, enter one of the following
commands:
# cat /etc/oracle-release
# cat /etc/redhat-release
# cat /etc/os-releas

============== **Software**================

1. Opererating System
hostnamectl
cat /etc/redhat-release

2. Kernel parameter

              2.1.sem
              /proc/sys/kernel/sem

              Minimum
              250 32000 100 128

              To configure kernel parameters
              https://docs.oracle.com/database/121/LADBI/app_manual.htm#CIHGDACA 

              2.2 shmmax 
              /proc/sys/kernel/shmmax

              (Half of RAM)

              2.3 shmmni
              shmmni	4096	/proc/sys/kernel/shmmni

              2.4 file-max
              file-max	6815744	/proc/sys/fs/file-max

              2.5 aio-max-nr
              aio-max-nr	1048576
              Note: This value limits concurrent outstanding requests and should be set to avoid I/O subsystem failures.

              /proc/sys/fs/aio-max-nr

              2.6 ip_local_port_range
              ip_local_port_range	Minimum: 9000 Maximum: 65500

              2.7 rmem_default
              rmem_default	262144	/proc/sys/net/core/rmem_default

              2.8 rmem_max
              rmem_max	4194304	/proc/sys/net/core/rmem_max

              2.9 wmem_default
              wmem_default	262144	/proc/sys/net/core/wmem_default

              2.10 wmem_max
              wmem_max	1048576	/proc/sys/net/core/wmem_max

=========================================================
Steps to Edit sysctl.conf and add the below parameters:-

fs.file-max = 6815744
kernel.sem = 250 32000 100 128
kernel.shmmni = 4096
kernel.shmall = 1073741824
kernel.shmmax = 4398046511104
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500
kernel.panic_on_oops=1

Then execute:-

/sbin/sysctl -p

for the above changes to take effect immediately.

============== **Oracle 19c Preinstallations**==========================

*** Log in as root

1. CentOS 
>>>>  yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-19c-1.0-1.el7.x86_64.rpm

2. Oracle Linux 6 and Oracle Linux 7:

>>>>  yum install oracle-rdbms-server-12cR1-preinstall

3. Oracle Linux 5:

>>>> yum install oracle-validated

Enter the following command as root to update the sysctl.conf settings:

>>>> sysctl -p

============== ** Operating System Requirements for x86-64 Linux Platforms ** ============

1. Supported Red Hat Enterprise Linux 7 Distributions for x86-64

>> Install the latest released versions of the following packages:
        bc
        binutils
        compat-libcap1
        compat-libstdc++-33
        elfutils-libelf
        elfutils-libelf-devel
        fontconfig-devel
        glibc
        glibc-devel
        ksh
        libaio
        libaio-devel
        libX11
        libXau
        libXi
        libXtst
        libXrender
        libXrender-devel
        libgcc
        libstdc++
        libstdc++-devel
        libxcb
        make
        smartmontools
        sysstat

Steps:- Check which packages are installed and which are missing:-

rpm -qa --qf '%{name}-%{version}-%{release}.%{arch}\n' | sort | grep package_name

OR

For multiple packages
rpm -q bc binutils compat-libcap1 compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel fontconfig-devel glibc glibc-devel ksh libaio libaio-devel libX11 libXau libXi libXtst libXrender libXrender-devel libgcc libstdc++ libstdc++-devel libxcb make smartmontools sysstat

If any rpm is missing, please install the same using yum:-

yum install package_name

============== **Oracle User Environment Configuration**================

1. Group and User

>>>>  id oracle

OR

>>>>>  cat /etc/group | oracle

>>>>>  less /etc/passwd

uid=54321(oracle) gid=54421(oinstall) groups=54322(dba),54323(oper),54327(asmdba)

If groups are missing =================================================
groupadd -g 54321 oinstall
groupadd -g 54322 dba
groupadd -g 54323 oper
groupadd -g 54324 backupdba
groupadd -g 54325 dgdba
groupadd -g 54326 kmdba
groupadd -g 54327 asmdba
groupadd -g 54328 asmoper
groupadd -g 54329 asmadmin

OR 

>>>>> /usr/sbin/groupadd -g 54321 oinstall

useradd -u 54321 -g oinstall -G dba,oper,backupdba,dgdba,kmdba oracle

>>>>> passwd oracle


5. Verify preinstalled features
cat /etc/sysctl.conf

6. Set oracle password: passwd oracle

7. Create required directories for oracle 19c software and datafiles and archivelog
mkdir -p /u01/app/oracle/product/19c/db_1/
mkdir -p /u01/app/oracle/oradata
mkdir -p /u01/app/oracle/archive
chown -R oracle:oinstall /u01/
chmod -R 775 /u01


8. Set bash_profile i.e. Environment variables

>>>>    vi .bash_profile

export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_BASE=/u01/app/oracle
export DB_HOME=$ORACLE_BASE/product/19c/db_1
export ORACLE_HOME=$DB_HOME
export ORACLE_SID=test
export ORACLE_TERM=xterm
export BASE_PATH=/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:$BASE_PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

>>>>>    . .bash_profile


confim the details above
>>>>  env | grep ORA


Add below entries in /etc/security/limits.conf file which will define limits
Add the following lines to a file called "/etc/security/limits.d/oracle-database-preinstall-19c.conf" file.

oracle   soft   nofile    1024
oracle   hard   nofile    65536
oracle   soft   nproc    16384
oracle   hard   nproc    16384
oracle   soft   stack    10240
oracle   hard   stack    32768
oracle   hard   memlock    134217728
oracle   soft   memlock    134217728

Additional Setups ====================================================================================================

Set secure Linux to permissive by editing the "/etc/selinux/config" file, making sure the SELINUX flag is set as follows.
SELINUX=permissive
Once the change is complete, restart the server or run the following command.
>>> setenforce Permissive
>>> If you have the Linux firewall enabled, you will need to disable or configure it, as shown here. To disable it, do the following.
 systemctl stop firewalld
>>> systemctl disable firewalld


========================================================================================================

INSTALLATION DB CHECKS

========================================================================================================


1. Unzip software.
>>> cd $ORACLE_HOME
unzip -oq /path/to/software/LINUX.X64_193000_db_home.zip

2. Interactive mode.
./runInstaller

# Silent mode.
./runInstaller -ignorePrereq -waitforcompletion -silent                        \
    -responseFile ${ORACLE_HOME}/install/response/db_install.rsp               \
    oracle.install.option=INSTALL_DB_SWONLY                                    \
    ORACLE_HOSTNAME=${ORACLE_HOSTNAME}                                         \
    UNIX_GROUP_NAME=oinstall                                                   \
    INVENTORY_LOCATION=${ORA_INVENTORY}                                        \
    SELECTED_LANGUAGES=en,en_GB                                                \
    ORACLE_HOME=${ORACLE_HOME}                                                 \
    ORACLE_BASE=${ORACLE_BASE}                                                 \
    oracle.install.db.InstallEdition=EE                                        \
    oracle.install.db.OSDBA_GROUP=dba                                          \
    oracle.install.db.OSBACKUPDBA_GROUP=dba                                    \
    oracle.install.db.OSDGDBA_GROUP=dba                                        \
    oracle.install.db.OSKMDBA_GROUP=dba                                        \
    oracle.install.db.OSRACDBA_GROUP=dba                                       \
    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false                                 \
    DECLINE_SECURITY_UPDATES=true
Run the root scripts when prompted.
As a root user, execute the following script(s):
        1. /u01/app/oraInventory/orainstRoot.sh
        2. /u01/app/oracle/product/19.0.0/dbhome_1/root.sh




========================================================================================================

POST INSTALLATION DB CHECKS

========================================================================================================


============== **DB info**================

-- -----------------------------------------------------------------------------------
-- Description  : Displays general information about the database.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @db_info
-- -----------------------------------------------------------------------------------

SET PAGESIZE 1000
SET LINESIZE 100
SET FEEDBACK OFF

SELECT *
FROM   v$database;

SELECT *
FROM   v$instance;

SELECT *
FROM   v$version;

SELECT a.name,
       a.value
FROM   v$sga a;

SELECT Substr(c.name,1,60) "Controlfile",
       NVL(c.status,'UNKNOWN') "Status"
FROM   v$controlfile c
ORDER BY 1;

SELECT Substr(d.name,1,60) "Datafile",
       NVL(d.status,'UNKNOWN') "Status",
       d.enabled "Enabled",
       LPad(To_Char(Round(d.bytes/1024000,2),'9999990.00'),10,' ') "Size (M)"
FROM   v$datafile d
ORDER BY 1;

SELECT l.group# "Group",
       Substr(l.member,1,60) "Logfile",
       NVL(l.status,'UNKNOWN') "Status"
FROM   v$logfile l
ORDER BY 1,2;

PROMPT
SET PAGESIZE 14
SET FEEDBACK ON


**DB Size  ===============================================================================

select sum(bytes)/1024/1024 size_in_mb from dba_data_files; 

** consumed space ========================================================================

SELECT /* + RULE */  df.tablespace_name "Tablespace",
       df.bytes / (1024 * 1024) "Size (MB)",
       SUM(fs.bytes) / (1024 * 1024) "Free (MB)",
       Nvl(Round(SUM(fs.bytes) * 100 / df.bytes),1) "% Free",
       Round((df.bytes - SUM(fs.bytes)) * 100 / df.bytes) "% Used"
  FROM dba_free_space fs,
       (SELECT tablespace_name,SUM(bytes) bytes
          FROM dba_data_files
         GROUP BY tablespace_name) df
WHERE fs.tablespace_name (+)  = df.tablespace_name
GROUP BY df.tablespace_name,df.bytes
UNION ALL
SELECT /* + RULE */ df.tablespace_name tspace,
       fs.bytes / (1024 * 1024),
       SUM(df.bytes_free) / (1024 * 1024),
       Nvl(Round((SUM(fs.bytes) - df.bytes_used) * 100 / fs.bytes), 1),
       Round((SUM(fs.bytes) - df.bytes_free) * 100 / fs.bytes)
  FROM dba_temp_files fs,
       (SELECT tablespace_name,bytes_free,bytes_used
          FROM v$temp_space_header
         GROUP BY tablespace_name,bytes_free,bytes_used) df
WHERE fs.tablespace_name (+)  = df.tablespace_name
GROUP BY df.tablespace_name,fs.bytes,df.bytes_free,df.bytes_used
ORDER BY 4 DESC;


-- -----------------------------------------------------------------------------------
-- Description  : Displays information about all database users.
-- Requirements : Access to the dba_users view.
-- Call Syntax  : @users [ username | % (for all)]
-- -----------------------------------------------------------------------------------
SET LINESIZE 200 VERIFY OFF

COLUMN username FORMAT A20
COLUMN account_status FORMAT A16
COLUMN default_tablespace FORMAT A15
COLUMN temporary_tablespace FORMAT A15
COLUMN profile FORMAT A15

SELECT username,
       account_status,
       TO_CHAR(lock_date, 'DD-MON-YYYY') AS lock_date,
       TO_CHAR(expiry_date, 'DD-MON-YYYY') AS expiry_date,
       default_tablespace,
       temporary_tablespace,
       TO_CHAR(created, 'DD-MON-YYYY') AS created,
       profile,
       initial_rsrc_consumer_group,
       editions_enabled,
       authentication_type
FROM   dba_users
WHERE  username LIKE UPPER('%&1%')
ORDER BY username;

SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- Description  : Displays information about database services.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @services
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
COLUMN name FORMAT A30
COLUMN network_name FORMAT A50
COLUMN pdb FORMAT A20

SELECT name,
       network_name,
       pdb
FROM   dba_services
ORDER BY name;
