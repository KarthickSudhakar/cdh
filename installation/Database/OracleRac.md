1. Hue 구성
//------------------------------------------------------------------------------------------------------------
Oracle RAC 환경 Hue 연동
- Hue는 Oracle과 연동할때 OCI 기반으로 django를 사용함 (참고1)
- Oracle RAC은 instance들을 하나로 묶어 cluster alias name 구성되어 있음 (tnsnames.ora 참고)

적용부분) CM의 Hue servcie 구성에서 hue_safety_valve_server.ini에대한 Hue Server 고급 구성 스니펫(안전밸브)
engine=oracle
port=0
user=test
password=test
name=(DESCRIPTION=(LOAD_VALANCE=off)
(DESCRIPTION=(LOAD_BALANCE=off)(FAILOVER=on)(CONNECT_TIMEOUT=5)(TRANSPORT_CONNECT_TIMEOUT=3)(RETRY_COUNT=3)(ADDRESS=(PROTOCOL=TCP)(HOST=Cluster_alias명)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=PUDB)))

요약: 참고1 에서와 같이 Oracle connection string을 조합할때 hue.ini의 database 변수 중 user, password, name을 조합하여 Oracle과 connection을 함으로 RAC 기반에서 정의된 cluster alias name명이 포함된 tnsnames.ora의 TNS entry명의 value부분을 hue.ini의 name에 적용

참고1) django 에서 Oracle connection string 셋팅 부분
파일위치: hue/desktop/core/ext-py/Django-1.6.10/django/db/backends/oracle/base.py

def _connect_string(self):
        settings_dict = self.settings_dict
        if not settings_dict['HOST'].strip():
            settings_dict['HOST'] = 'localhost'
        if settings_dict['PORT'].strip():
            dsn = Database.makedsn(settings_dict['HOST'],
                                   int(settings_dict['PORT']),
                                   settings_dict['NAME'])
        else:
            dsn = settings_dict['NAME']
        return "%s/%s@%s" % (settings_dict['USER'],
                             settings_dict['PASSWORD'], dsn)
http://www.cloudera.com/documentation/enterprise/5-4-x/topics/cm_mc_hue_service.html#concept_af3_wy4_1r
//-------------------------------------------------------------------------------------------------------------

2. Cloudera Manager
//-------------------------------------------------------------------------------------------------------------
You can configure Cloudera Manager to use Oracle RAC database with failover by overwriting the connection parameters for the Oracle Driver  in the /etc/cloudera-scm-server/db.properties file.

com.cloudera.cmf.db.type=oracle
com.cloudera.cmf.orm.hibernate.connection.driver_class=oracle.jdbc.driver.OracleDriver
com.cloudera.cmf.orm.hibernate.connection.url=jdbc:oracle:thin:@(DESCRIPTION=(LOAD_BALANCE=off)(FAILOVER=on) /  
(CONNECT_TIMEOUT=5)(TRANSPORT_CONNECT_TIMEOUT=3)(RETRY_COUNT=3)(ADDRESS=(PROTOCOL=TCP)(HOST=hostname1)(PORT=1521))  /  
(ADDRESS=(PROTOCOL=TCP)(HOST=hostname2)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=bla)))
com.cloudera.cmf.orm.hibernate.connection.username=xxxx
com.cloudera.cmf.orm.hibernate.connection.password=yyyy
//-------------------------------------------------------------------------------------------------------------

3. Hive Metastore DB
//--------------------------------------------------------------------------------------------------------------
Cloudera Manager에서 Hive 구성에서 hive-site.xml에 대한 Metastore Server 고급 구성 스니펫(안전벨브)의 옵션에 하기의 4개의 옵션과 값을 입력
javax.jdo.option.ConnectionURL
값: JDBC URL 정보(transname.ora 정보)
javax.jdo.option.ConnectionDriverName
값: oracle.jdbc.driver.OracleDriver
javax.jdo.option.ConnectionUserName
값: Usr_Name
javax.jdo.option.ConnectionPassword
값: Password

//--------------------------------------------------------------------------------------------------------------

4. Oozie
//--------------------------------------------------------------------------------------------------------------
Cloudera Manager에서 Oozie 구성에서 oozie-site.xml에 대한 Oozie Server 고급 구성 스니펫(안전벨브)의 옵션에 하기의 1개 옵션 추가
oozie.service.JPAService.jdbc.url 
값: JDBC URL 정보(transname.ora 정보)
//--------------------------------------------------------------------------------------------------------------

5. Sentry
//--------------------------------------------------------------------------------------------------------------
Cloudera Manager에서 Sentry 구성에서 sentry-site.xml에 대한 Sentry 서비스 고급 구성 스니펫(안전벨브)의 옵션에 하기의 1개 옵션 추가
옵션: sentry.store.jdbc.url
값: JDBC URL 정보(transname.ora 정보)
//--------------------------------------------------------------------------------------------------------------
