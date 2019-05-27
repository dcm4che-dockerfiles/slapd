FROM debian:stretch

# explicitly set user/group IDs
RUN groupadd -r openldap --gid=1021 && useradd -r -g openldap --uid=1021 openldap

RUN apt-get update && \
    LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        ldap-utils \
        slapd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/ldap/slapd.d/*

ENV LDAP_ORGANISATION=dcm4che.org \
    LDAP_BASE_DN=dc=dcm4che,dc=org \
    LDAP_URLS="ldap:///" \
    LDAP_TLS_CACERT=/etc/certs/cacert.pem \
    LDAP_TLS_CERT=/etc/certs/cert.pem \
    LDAP_TLS_KEY=/etc/certs/key.pem \
    LDAP_TLS_VERIFY=never \
    LDAP_TLS_REQCERT=never

VOLUME [ "/var/lib/ldap", "/etc/ldap/slapd.d" ]

COPY docker-entrypoint.sh setenv.sh /
COPY ldap /etc/ldap
COPY certs /etc/certs
COPY bin /usr/bin

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 389
CMD ["slapd", "-d", "32768", "-u", "openldap", "-g", "openldap"]
