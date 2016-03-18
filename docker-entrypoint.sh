#!/bin/bash

set -e

if [ "$1" = 'slapd' ]; then
	if [ ! -f /etc/ldap/slapd.d/cn\=config.ldif ] || [ ! -f /var/lib/ldap/DB_CONFIG ]; then

		LDAP_DOMAIN=$(sed -e s/^dc=// -e s/,dc=/./g<<-EOF
			${LDAP_BASE_DN}
			EOF
			)

		cat <<- EOF | debconf-set-selections
			slapd slapd/internal/generated_adminpw password ${LDAP_ROOTPASS}
			slapd slapd/internal/adminpw password ${LDAP_ROOTPASS}
			slapd slapd/password2 password ${LDAP_ROOTPASS}
			slapd slapd/password1 password ${LDAP_ROOTPASS}
			slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
			slapd slapd/domain string ${LDAP_DOMAIN}
			slapd shared/organization string ${LDAP_ORGANISATION}
			slapd slapd/backend string HDB
			slapd slapd/purge_database boolean true
			slapd slapd/move_old_database boolean true
			slapd slapd/allow_ldap_v2 boolean false
			slapd slapd/no_configuration boolean false
			slapd slapd/dump_database select when needed
			EOF

		dpkg-reconfigure -f noninteractive slapd

		slapd -h ldapi:/// -u openldap -g openldap

		ldapmodify -Y EXTERNAL -H ldapi:/// <<- EOF
			dn: olcDatabase={0}config,cn=config
			changetype: modify
			add: olcRootPW
			olcRootPW: $(slappasswd -s ${LDAP_CONFIGPASS})
			EOF

		ldapmodify -Y EXTERNAL -H ldapi:/// <<- EOF
			dn: olcDatabase={1}hdb,cn=config
			changetype: modify
			add: olcAccess
			olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by * none
			EOF

		if [ -f /etc/ldap/configure.sh ]; then
			. /etc/ldap/configure.sh
		fi

		killall slapd

		sleep 2
	fi

	ulimit -n 1024
fi

exec "$@"
