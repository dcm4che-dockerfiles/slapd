#!/bin/sh

set -x
: LDAP_CONFIGPASS=${LDAP_CONFIGPASS}
: LDAP_ROOTPASS=${LDAP_ROOTPASS}
: LDAP_DOMAIN=${LDAP_DOMAIN}
: LDAP_ORGANISATION=${LDAP_ORGANISATION}
: LDAP_BASE_DN=${LDAP_BASE_DN}

if [ ! -e /var/lib/ldap/docker_bootstrapped ]; then

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

	slapd -h "ldapi:/// ldap:///" -u openldap -g openldap

	ldapmodify -Y EXTERNAL -H ldapi:/// <<- EOF
		dn: olcDatabase={0}config,cn=config
		changetype: modify
		add: olcRootPW
		olcRootPW: $(slappasswd -s ${LDAP_CONFIGPASS})
		EOF

	if [ -f /etc/ldap/configure ]; then
		. /etc/ldap/configure
	fi

	killall slapd

	sleep 2

	touch /var/lib/ldap/docker_bootstrapped
fi

ulimit -n 1024
exec "$@"
