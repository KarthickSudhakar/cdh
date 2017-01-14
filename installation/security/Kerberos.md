# Kerberos

Install MID Kerberos Server
```
yum install krb5-libs krb5-server
/var/kerberos/krb5kdc/kdc.conf
kdb5_util create -s -r HADOOP.COM
/var/kerberos/krb5kdc/kadm5.acl
service krb5kdc start
service kadmin start
kadmin.local addprinc -pw cloudera cloudera-scm/admin@JACKSON.HADOOP.COM
```
If you have hang with the message below, that is because of Entropy
```
Loading random data
```
http://www.cloudera.com/documentation/enterprise/5-8-x/topics/encryption_prereqs.html


1. kdb5_util create -r JACKSON.CLOUDERA.COM -s (when hanging and freezing)
https://www.digitalocean.com/community/tutorials/how-to-setup-additional-entropy-for-cloud-servers-using-haveged
https://www.cloudera.com/documentation/enterprise/latest/topics/encryption_prereqs.html#concept_by1_pv4_y5

# Reference
https://docs.oracle.com/cd/E26925_01/html/E25888/intro-25.html
http://blog.naver.com/PostView.nhn?blogId=nahaeya100&logNo=140122278976
http://blog.hkwon.me/use-openldap-part1/
https://blog.cloudera.com/blog/2015/03/how-to-quickly-configure-kerberos-for-your-apache-hadoop-cluster/
http://bloodguy.tistory.com/entry/Hadoop-%EB%B3%B4%EC%95%88%EC%84%A4%EC%A0%95-security-kerberos-spnego-ssl
https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Managing_Smart_Cards/Using_Kerberos.html (Redhat)

