#!/bin/sh

set -e

if [ "$1" = 'slapd' ]; then

  . setenv.sh

  if [ ! -f /etc/openldap/slapd.d/cn\=config.ldif ]; then
    [ -d /etc/openldap/slapd.d ] || mkdir /etc/openldap/slapd.d
    . slapadd.sh
    chown -R ldap:ldap /etc/openldap/slapd.d
    chown -R ldap:ldap /var/lib/openldap/openldap-data
    [ -f /etc/openldap/configure.sh ] && ( sleep 2; /etc/openldap/configure.sh )&
  fi

  [ -d /run/openldap ] || mkdir /run/openldap && chown ldap:ldap /run/openldap

  grep -q TLS /etc/openldap/ldap.conf || cat >>/etc/openldap/ldap.conf <<EOF

TLS_CERT	$LDAP_TLS_CERT
TLS_KEY		$LDAP_TLS_KEY
TLS_CACERT	$LDAP_TLS_CACERT
TLS_REQCERT	$LDAP_TLS_REQCERT
EOF

  set -- "$@" -h "$LDAP_URLS"

  ulimit -n 1024
fi

exec "$@"
