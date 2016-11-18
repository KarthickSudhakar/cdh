# UDF

1. upload jar to HDFS
```
sudo -u hive hadoop fs -put /root/HiveUDFs-0.0.1-SNAPSHOT.jar /user/hive/lib
```

2. connect hive2 server with beeline
```
!connect jdbc:hive2://localhost:10000/default
```

3. create user-defined function (permanent)
```
CREATE FUNCTION ssnMasking AS 'com.cloudera.ps.udf.SsnMasking' USING JAR 'hdfs://	ip-10-0-0-201.ap-northeast-2.compute.internal/user/hive/lib/hive-udfs.jar';
```

4. test
```
+-----------+------------+----------+--+
| col_name  | data_type  | comment  |
+-----------+------------+----------+--+
| key       | int        |          |
| fullname  | string     |          |
| ssn       | string     |          |
| salary    | float      |          |
+-----------+------------+----------+--+
4 rows selected (0.234 seconds)
0: jdbc:hive2://localhost:10000/default> select fullname, ssnMasking(ssn), salary from employees;
INFO  : Compiling command(queryId=hive_20161118083636_99dd2741-1520-4613-9d39-25a64b3c4995): select fullname, ssnMasking(ssn), salary from employees
INFO  : converting to local hdfs://ip-10-0-0-201.ap-northeast-2.compute.internal//user/hive/lib/hive-udfs.jar
INFO  : Added [/tmp/ebf927eb-d3fd-4ab8-a612-b9a33200942d_resources/hive-udfs.jar] to class path
INFO  : Added resources: [hdfs://ip-10-0-0-201.ap-northeast-2.compute.internal//user/hive/lib/hive-udfs.jar]
INFO  : Semantic Analysis Completed
INFO  : Returning Hive schema: Schema(fieldSchemas:[FieldSchema(name:fullname, type:string, comment:null), FieldSchema(name:_c1, type:string, comment:null), FieldSchema(name:salary, type:float, comment:null)], properties:null)
INFO  : Completed compiling command(queryId=hive_20161118083636_99dd2741-1520-4613-9d39-25a64b3c4995); Time taken: 0.103 seconds
INFO  : Executing command(queryId=hive_20161118083636_99dd2741-1520-4613-9d39-25a64b3c4995): select fullname, ssnMasking(ssn), salary from employees
INFO  : Query ID = hive_20161118083636_99dd2741-1520-4613-9d39-25a64b3c4995
INFO  : Total jobs = 1
INFO  : Launching Job 1 out of 1
INFO  : Starting task [Stage-1:MAPRED] in serial mode
INFO  : Number of reduce tasks is set to 0 since there's no reduce operator
INFO  : number of splits:1
INFO  : Submitting tokens for job: job_1479275435486_0007
INFO  : The url to track the job: http://ip-10-0-1-14.ap-northeast-2.compute.internal:8088/proxy/application_1479275435486_0007/
INFO  : Starting Job = job_1479275435486_0007, Tracking URL = http://ip-10-0-1-14.ap-northeast-2.compute.internal:8088/proxy/application_1479275435486_0007/
INFO  : Kill Command = /opt/cloudera/parcels/CDH-5.9.0-1.cdh5.9.0.p0.23/lib/hadoop/bin/hadoop job  -kill job_1479275435486_0007
INFO  : Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 0
INFO  : 2016-11-18 08:36:19,069 Stage-1 map = 0%,  reduce = 0%
INFO  : 2016-11-18 08:36:24,298 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 1.52 sec
INFO  : MapReduce Total cumulative CPU time: 1 seconds 520 msec
INFO  : Ended Job = job_1479275435486_0007
INFO  : MapReduce Jobs Launched:
INFO  : Stage-Stage-1: Map: 1   Cumulative CPU: 1.52 sec   HDFS Read: 3674 HDFS Write: 91 SUCCESS
INFO  : Total MapReduce CPU Time Spent: 1 seconds 520 msec
INFO  : Completed executing command(queryId=hive_20161118083636_99dd2741-1520-4613-9d39-25a64b3c4995); Time taken: 12.248 seconds
INFO  : OK
+-------------+--------------+----------+--+
|  fullname   |     _c1      |  salary  |
+-------------+--------------+----------+--+
| John Smith  | ***-**-4567  | 25000.0  |
| Jim Bloggs  | ***-**-7777  | 35000.0  |
| Jane Doe    | ***-**-0880  | 45000.0  |
+-------------+--------------+----------+--+
3 rows selected (12.398 seconds)
```
