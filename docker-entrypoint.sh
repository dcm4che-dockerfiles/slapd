#!/bin/sh

set -e

if [ "$1" = 'slapd' ]; then

  . setenv.sh

  if ! $(getent passwd $LDAP_USER_ID > /dev/null); then
    deluser ldap
    addgroup -g $LDAP_GROUP_ID -S ldap
    adduser -u $LDAP_USER_ID -D -S -h /usr/lib/openldap -s /sbin/nologin -g 'OpenLDAP User' -G ldap ldap
    chown -R ldap:ldap /var/lib/openldap
  fi

  if [ ! -f /etc/openldap/slapd.d/cn\=config.ldif ]; then
    chown ldap:ldap /etc/openldap/slapd.d
    su -s /bin/sh ldap -c /slapadd.sh
    [ -f /etc/openldap/configure.sh ] && ( sleep 2; /etc/openldap/configure.sh )&
  fi

  [ -d /run/openldap ] || mkdir /run/openldap && chown ldap:ldap /run/openldap

  grep -q TLS /etc/openldap/ldap.conf || cat >>/etc/openldap/ldap.conf <<EOF

TLS_CERT	$LDAP_TLS_CERT
TLS_KEY		$LDAP_TLS_KEY
TLS_CACERT	$LDAP_TLS_CACERT
TLS_REQCERT	$LDAP_TLS_REQCERT
EOF

  if [ -n "$LDAP_EXTRA_HOST" ] && ! grep -q $LDAP_EXTRA_HOST /etc/hosts; then
    if [ -n "$LDAP_EXTRA_HOST_IP_PREFIX" ]; then
      IP=$(ip a | sed -e /$LDAP_EXTRA_HOST_IP_PREFIX/\!d -e 's%^[^1-9]*\([^/]*\).*%\1%')
    else
      IP=$(hostname -i)
    fi
    echo $IP$'\t'$LDAP_EXTRA_HOST >>/etc/hosts
  fi

  set -- "$@" -d "$LDAP_DEBUG" -h "$LDAP_URLS"

  ulimit -n 1024
fi

exec "$@"
