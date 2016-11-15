# Sentry
Kerberized 일단 제외.(원래는 필수)<br>
Impala에 적용

## 모든 노드에 리눅스 그룹&유저 생성
```
$ sudo groupadd selector
$ sudo groupadd inserter
$ sudo useradd -u 1100 -g selector jackson
$ sudo useradd -u 1200 -g inserters cho
```

## Impala Role 생성(Hue 에서 admin user로 작업)
```
CREATE ROLE read_auth;
CREATE ROLE write_auth;
```

## 모든 테이블에 읽기권한을 준다.(Group selector)
```
GRANT SELECT ON DATABASE default TO ROLE read_auth;
GRANT ROLE read_auth TO GROUP selector;
```

## sample07 테이블만 쓰기권한을 준다(Group inserter)
```
REVOKE ALL ON DATABASE default FROM ROLE write_auth;
GRANT SELECT(description) ON TABLE sample_07 TO ROLE write_auth;
GRANT ROLE write_auth TO GROUP inserter;
```

## Hue에 사용자 생성
사용자 관리에서 jackson, cho 생성한다.

## Sentry 설정에서 관리자 그룹 등록
Sentry > Configuration > Admin Groups 에 selector, inserter 추가.

## Sentry 가 보초를 설 Impala 설정
Impala > Configuration > Sentry Service 에 Sentry 체크

## 이제 테스트 해보자
Hue 에서 jackson으로 로그인하면 일단 모든 테이블이 보인다.<br>
cho로 로그인하면 뭔가가 다르다.

## 참고
https://www.cloudera.com/documentation/enterprise/5-6-x/topics/sg_sentry_service_config.html
https://www.cloudera.com/documentation/enterprise/5-3-x/topics/sg_hive_sql.html



