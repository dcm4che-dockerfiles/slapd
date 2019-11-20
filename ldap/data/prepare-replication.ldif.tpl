dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: syncprov

dn: cn=config
changeType: modify
add: olcServerID
{{ LDAP_REPLICATION_HOSTS }}

dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcLimits
olcLimits: dn.exact="cn=admin,$LDAP_BASE_DN" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited
-
add: olcDbIndex
olcDbIndex: entryUUID  eq
olcDbIndex: entryCSN  eq

dn: olcOverlay=syncprov,olcDatabase={1}mdb,cn=config
changetype: add
objectClass: olcOverlayConfig
objectClass: olcSyncProvConfig
olcOverlay: syncprov
