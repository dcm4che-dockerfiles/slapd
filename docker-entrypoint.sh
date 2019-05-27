#!/bin/bash

set -e

if [ "$1" = 'slapd' ]; then

	. setenv.sh

	if [ ! -f /etc/ldap/slapd.d/cn\=config.ldif ] || [ ! -f /var/lib/ldap/DB_CONFIG ]; then

		LDAP_DOMAIN=$(sed -e s/^dc=// -e s/,dc=/./g <<< $LDAP_BASE_DN)

		cat <<- EOF | debconf-set-selections
			slapd slapd/internal/generated_adminpw password $LDAP_ROOTPASS
			slapd slapd/internal/adminpw password $LDAP_ROOTPASS
			slapd slapd/password2 password $LDAP_ROOTPASS
			slapd slapd/password1 password $LDAP_ROOTPASS
			slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
			slapd slapd/domain string $LDAP_DOMAIN
			slapd shared/organization string $LDAP_ORGANISATION
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
			add: olcRootPW
			olcRootPW: $(slappasswd -s $LDAP_CONFIGPASS)

			dn: olcDatabase={1}hdb,cn=config
			add: olcAccess
			olcAccess: {0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break

			dn: cn=config
			add: olcTLSCACertificateFile
			olcTLSCACertificateFile: $LDAP_TLS_CACERT
			-
			add: olcTLSCertificateFile
			olcTLSCertificateFile: $LDAP_TLS_CERT
			-
			add: olcTLSCertificateKeyFile
			olcTLSCertificateKeyFile: $LDAP_TLS_KEY
			-
			add: olcTLSVerifyClient
			olcTLSVerifyClient: $LDAP_TLS_VERIFY
			EOF

		if [ -f /etc/ldap/configure.sh ]; then
			. /etc/ldap/configure.sh
		fi

		killall slapd

		sleep 2
	fi

	if [ ! -f /etc/ldap/ldap.conf.done ]; then
		touch /etc/ldap/ldap.conf.done
		cat > /etc/ldap/ldap.conf <<- EOF
			TLS_CERT	$LDAP_TLS_CERT
			TLS_KEY	$LDAP_TLS_KEY
			TLS_CACERT	$LDAP_TLS_CACERT
			TLS_REQCERT	$LDAP_TLS_REQCERT
			EOF
	fi

	set -- "$@" -h "$LDAP_URLS"

	ulimit -n 1024
fi

exec "$@"
