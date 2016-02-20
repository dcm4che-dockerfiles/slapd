FROM debian:jessie

# explicitly set user/group IDs
RUN groupadd -r openldap --gid=1021 && useradd -r -g openldap --uid=1021 openldap

RUN apt-get update && \
    LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y ldap-utils slapd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/ldap/slapd.d/*

# Default configuration: can be overridden at the docker command line
ENV LDAP_CONFIGPASS=secret \
    LDAP_ROOTPASS=secret \
    LDAP_ORGANISATION=dcm4che.org \
    LDAP_BASE_DN=dc=dcm4che,dc=org

VOLUME [ "/var/lib/ldap", "/etc/ldap/slapd.d" ]

COPY docker-entrypoint.sh /
COPY unldif.sed /usr/bin

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 389
CMD ["slapd", "-d", "32768", "-u", "openldap", "-g", "openldap"]
