#!/bin/sh

if [ "${LDAP_ROOTPASS:-}" ]; then
  if [ "${LDAP_ROOTPASS_FILE:-}" ]; then
    echo >&2 "error: both LDAP_ROOTPASS and LDAP_ROOTPASS_FILE are set (but are exclusive)"
    exit 1
  fi
elif [ "${LDAP_ROOTPASS_FILE:-}" ]; then
  LDAP_ROOTPASS="$(< "${LDAP_ROOTPASS_FILE}")"
  unset LDAP_ROOTPASS_FILE
else
  LDAP_ROOTPASS=secret
fi
export LDAP_ROOTPASS

if [ "${LDAP_CONFIGPASS:-}" ]; then
  if [ "${LDAP_CONFIGPASS_FILE:-}" ]; then
    echo >&2 "error: both LDAP_CONFIGPASS and LDAP_CONFIGPASS_FILE are set (but are exclusive)"
    exit 1
  fi
elif [ "${LDAP_CONFIGPASS_FILE:-}" ]; then
  LDAP_CONFIGPASS="$(< "${LDAP_CONFIGPASS_FILE}")"
  unset LDAP_CONFIGPASS_FILE
else
  LDAP_CONFIGPASS=secret
fi
export LDAP_CONFIGPASS
