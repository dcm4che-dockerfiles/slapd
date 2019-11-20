dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcSyncRepl
{{ LDAP_REPLICATION_HOSTS_DB_SYNC_REPL }}
-
add: olcMirrorMode
olcMirrorMode: TRUE
