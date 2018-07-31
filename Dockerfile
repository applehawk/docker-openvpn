# Original credit: https://github.com/jpetazzo/dockvpn

# Smallest base image
FROM ruby:alpine

LABEL maintainer="Modification - github.com/applehawk (Kyle Manna <kyle@kylemanna.com>)"

# Testing: pamtester
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV OPENVPNMCGEN /usr/local/ovpnmcgen
ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki
ENV EASYRSA_VARS_FILE $OPENVPN/vars

# Prevents refused client connection because of an expired CRL
ENV EASYRSA_CRL_DAYS 3650

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Initialize OVPNMCGEN
RUN mkdir OPENVPNMCGEN
ADD ./Gemfile OPENVPNMCGEN
RUN gem install bundler

WORKDIR OPENVPNMCGEN
RUN pwd
RUN bundle install

WORKDIR /usr/local/bin

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
