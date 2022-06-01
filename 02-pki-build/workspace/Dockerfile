#
#FROM nginx:1.18.0
FROM nginx:1.19.0

MAINTAINER F and P

#ENV VAULT_VERSION="1.4.2" \
ENV VAULT_VERSION="1.9.3" \
    VAULT_ADDR="http://127.0.0.1:8200" \
    VAULT_TOKEN="CHANGEME"

LABEL type="vault-pki-client"

# CHANGE WORKING DIRECTORY
WORKDIR /tmp

# BECOME ROOT TO INSTALL REQUIRED PACKAGES
USER root

# SET UP FOR CODE DIRECTORIES
RUN mkdir -p /tmp/stage/vault_pki_nginx && \
    mkdir -p /tmp/stage/requirements && \
    mkdir -p /files && \
    mkdir -p /vault/secrets

# COPY REPO
COPY tmp /vault/secrets/
COPY files /files/
COPY www /usr/share/nginx/html/
#COPY config/ /vault/secrets
COPY config /etc/nginx/conf.d/
#COPY vault_${VAULT_VERSION}_linux_amd64.zip /tmp/


# UPDATE / UPGRADE APT & INSTALL PREREQUISITE PACKAGES
#RUN apt-get -y update && \
#    apt-get -y upgrade && \
#    apt-get -yq install \
#        software-properties-common \
#        apt-utils \
#        apt-transport-https \
##        python \
##        python3 \
##        python3-pip \
#        curl \
#        ssh \
#        patch \
#        gnupg2 \
#        sudo \
#        software-properties-common \
#        vim \
#        bash \
#        ca-certificates \
#        unzip \
#        jq \
#        rr \
#        dnsutils \
#        inetutils-ping \
#        net-tools \
#        tcpdump \
#        netcat \
#        cron \
#	    expect \
#        wget

# INSTALL PIP
#RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
#    python3 get-pip.py && \
#RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py && \
#    python get-pip.py && \

# PIP INSTALL PACKAGES
#    pip install --requirement /tmp/stage/requirements/requirements.testngx
#    which pip

# DOWNLOAD & SETUP VAULT
#RUN wget --quiet --output-document=/tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
#RUN wget --quiet --output-document=/tmp/vault.zip https://releases.hashicorp.com/vault/1.4.2/vault_1.4.2_linux_amd64.zip
##RUN wget --quiet https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
#RUN unzip -o /tmp/vault_${VAULT_VERSION}_linux_amd64.zip -d /vault && \
#    rm -f /tmp/vault.zip && \
#    chmod +x /vault

# UPDATE PATH
ENV PATH="PATH=$PATH:$PWD/vault" https_proxy="" http_proxy=""

# KEEPALIVE
#RUN chmod 744 /files/keepalive.sh
#CMD ["/files/keepalive.sh"]
#ENTRYPOINT ["/bin/sh", "/files/keepalive.sh"]

# IMPLEMENT TCPDUMP FIXES
#RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump && \
#    ln -s /usr/bin/tcpdump /usr/sbin/tcpdump

# EXECUTE VAULT PKI REQUEST
RUN touch /vault/secrets/server.certificate && \
    touch /vault/secrets/server.private_key && \
    touch /vault/secrets/server.bundle && \
    chmod 0644 //usr/share/nginx/html/yoyodyne* &&\
    chmod 0644 /etc/nginx/conf.d/default.conf &&\
    chmod 0600 /vault/secrets/server.certificate && \
    chmod 0600 /vault/secrets/server.private_key && \
    chmod 0600 /vault/secrets/server.bundle

# EXECUTE PKI GRAB FOR CONFIG
#RUN sh /vault/secrets/pki_init.sh

# CLEAN UP
RUN apt-get -y autoremove && \
    apt-get -y autoclean && \
    apt-get -y clean && \
    apt -y autoremove && \
    rm -rf /var/tmp/* /var/lib/apt/archive/* /var/lib/apt/lists/*

WORKDIR /vault

