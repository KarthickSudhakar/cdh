# Data set
```
> cat employees.csv
1,John Smith,123-55-4567,25000.0
2,Jim Bloggs,999-88-7777,35000.0
3,Jane Doe,808-88-0880,45000.0
```

Data model
```
# Load data
> hdfs dfs -mkdir /data/employees
> hdfs dfs -put employees.csv /data/employees
  
# Create data objects
# (either the user must have Sentry privileges to create these objects or Sentry be disabled)
> cat employees.sql
CREATE EXTERNAL TABLE employees
(key INT, fullname STRING, ssn STRING, salary FLOAT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/data/employees/';
> beeline -u jdbc:hive2://localhost -f employees.sql
  
> cat employees_unmasked.sql
CREATE VIEW employees_unmasked AS
SELECT key, fullname, ssn, salary
FROM employees;
> beeline -u jdbc:hive2://localhost -f employees_unmasked.sql
  
> cat employees_masked.sql
CREATE VIEW employees_masked AS
SELECT
    key
  , fullname
  , CONCAT('***-**-',
           SUBSTR(ssn, 8, 4))
    AS ssn
  , "PRIVATE" AS salary
FROM employees;
> beeline -u jdbc:hive2://localhost -f employees_masked.sql
```

Security model
```
# Lock down the data on HDFS
> hdfs dfs -chown -R hive:hive /data/employees
> hdfs dfs -chmod -R 770 /data/employees
 
# Lock down the database objects. Sentry privileges are only additive
> hdfs dfs -cat /user/hive/sentry/sentry-provider.ini
[groups]
a = human_resources, all_staff
b = all_staff
[roles]
human_resources = server=server1->db=default->table=employees_unmasked->action=SELECT
all_staff = server=server1->db=default->table=employees_masked->action=SELECT
  
# Lock down the policy file
> hdfs dfs -chown jeremy:hive /user/hive/sentry/sentry-provider.ini
> hdfs dfs -chmod 640 /user/hive/sentry/sentry-provider.ini
```

Testing
```
> su a
> groups
a
> hdfs dfs -cat /data/employees/employees.csv
cat: Permission denied: user=a, access=EXECUTE, inode="/data/employees":hive:hive:drwxrwx---
> beeline -u jdbc:hive2://localhost -n a -e "SELECT * FROM employees"
Error: Error while processing statement: FAILED: SemanticException No valid privileges (state=42000,code=40000)
> beeline -u jdbc:hive2://localhost -n a -e "SELECT * FROM employees_unmasked"
+------+-------------+--------------+----------+
| key  |  fullname   |     ssn      |  salary  |
+------+-------------+--------------+----------+
| 1    | John Smith  | 123-55-4567  | 25000.0  |
| 2    | Jim Bloggs  | 999-88-7777  | 35000.0  |
| 3    | Jane Doe    | 808-88-0880  | 45000.0  |
+------+-------------+--------------+----------+
> beeline -u jdbc:hive2://localhost -n a -e "SELECT * FROM employees_masked"
+------+-------------+--------------+----------+
| key  |  fullname   |     ssn      |  salary  |
+------+-------------+--------------+----------+
| 1    | John Smith  | ***-**-4567  | PRIVATE  |
| 2    | Jim Bloggs  | ***-**-7777  | PRIVATE  |
| 3    | Jane Doe    | ***-**-0880  | PRIVATE  |
+------+-------------+--------------+----------+
> impala-shell -q "SELECT * FROM employees"
ERROR: AuthorizationException: User 'a' does not have privileges to execute 'SELECT' on: default.employees
> impala-shell -q "SELECT * FROM employees_unmasked"
+-----+------------+-------------+--------+
| key | fullname   | ssn         | salary |
+-----+------------+-------------+--------+
| 1   | John Smith | 123-55-4567 | 25000  |
| 2   | Jim Bloggs | 999-88-7777 | 35000  |
| 3   | Jane Doe   | 808-88-0880 | 45000  |
+-----+------------+-------------+--------+
> impala-shell -q "SELECT * FROM employees_masked"
+-----+------------+-------------+---------+
| key | fullname   | ssn         | salary  |
+-----+------------+-------------+---------+
| 1   | John Smith | ***-**-4567 | PRIVATE |
| 2   | Jim Bloggs | ***-**-7777 | PRIVATE |
| 3   | Jane Doe   | ***-**-0880 | PRIVATE |
+-----+------------+-------------+---------+
 
> su b
> groups
b
> hdfs dfs -cat /data/employees/employees.csv
cat: Permission denied: user=b, access=EXECUTE, inode="/data/employees":hive:hive:drwxrwx---
> beeline -u jdbc:hive2://localhost -u b -e "SELECT * FROM employees"
Error: Error while processing statement: FAILED: SemanticException No valid privileges (state=42000,code=40000)
> beeline -u jdbc:hive2://localhost -u b -e "SELECT * FROM employees_unmasked"
Error: Error while processing statement: FAILED: SemanticException No valid privileges (state=42000,code=40000)
> beeline -u jdbc:hive2://localhost -u b -e "SELECT * FROM employees_masked"
+------+-------------+--------------+----------+
| key  |  fullname   |     ssn      |  salary  |
+------+-------------+--------------+----------+
| 1    | John Smith  | ***-**-4567  | PRIVATE  |
| 2    | Jim Bloggs  | ***-**-7777  | PRIVATE  |
| 3    | Jane Doe    | ***-**-0880  | PRIVATE  |
+------+-------------+--------------+----------+
> impala-shell -q "SELECT * FROM employees"
ERROR: AuthorizationException: User 'b' does not have privileges to execute 'SELECT' on: default.employees
> impala-shell -q "SELECT * FROM employees_unmasked"
ERROR: AuthorizationException: User 'b' does not have privileges to execute 'SELECT' on: default.employees_unmasked
> impala-shell -q "SELECT * FROM employees_masked"
+-----+------------+-------------+---------+
| key | fullname   | ssn         | salary  |
+-----+------------+-------------+---------+
| 1   | John Smith | ***-**-4567 | PRIVATE |
| 2   | Jim Bloggs | ***-**-7777 | PRIVATE |
| 3   | Jane Doe   | ***-**-0880 | PRIVATE |
+-----+------------+-------------+---------+
```
