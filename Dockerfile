FROM debian:jessie

RUN apt-get update && \
   	LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y ldap-utils slapd && \
   	apt-get clean && \
   	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Default configuration: can be overridden at the docker command line
ENV LDAP_CONFIGPASS=secret \
    LDAP_ROOTPASS=secret \
    LDAP_ORGANISATION=dcm4che.org \
    LDAP_DOMAIN=example.com

VOLUME /var/lib/ldap
VOLUME /etc/ldap/slapd.d

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 389
CMD ["slapd", "-d", "32768", "-u", "openldap", "-g", "openldap"]
