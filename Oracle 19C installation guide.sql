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


============== **Software**================

1. Opererating System
hostnamectl
cat /etc/redhat-release

2. Kernel parameter

              2.1.sem
              /proc/sys/kernel/sem

              Minimum
              250 32000 100 128

              To configure kernel parameter
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


============== **Oracle User Environment Configuration**================

1. Group and User

# id oracle

OR

cat /etc/group | oracle

less /etc/passwd

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

# /usr/sbin/groupadd -g 54321 oinstall

useradd -u 54321 -g oinstall -G dba,oper,backupdba,dgdba,kmdba oracle

passwd oracle



Oracle 19c preinstall=======================================================================
yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-19c-1.0-1.el7.x86_64.rpm

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