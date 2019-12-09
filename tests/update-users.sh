#!/usr/bin/env bash

set -ex

CONFIGS=$(psec environments path)/configs
USER_ARGS="{ 'server': '10.0.8.100', 'users': ['desktop', 'user1', 'user2'], 'local_service_ip': '172.16.0.1' }"

if [ "${DEPLOY}" == "docker" ]
then
	docker run -it -v ${CONFIGS}/config.cfg:/algo/config.cfg -v ~/.ssh:/root/.ssh -v ${CONFIGS}:/algo/configs -e "USER_ARGS=${USER_ARGS}" travis/algo /bin/sh -c "chown -R root: /root/.ssh && chmod -R 600 /root/.ssh && source .env/bin/activate && ansible-playbook users.yml -e \"${USER_ARGS}\" -t update-users"
else
  ansible-playbook users.yml -e "${USER_ARGS}" -t update-users
fi

#
# IPsec
#

if sudo openssl crl -inform pem -noout -text -in ${CONFIGS}/10.0.8.100/ipsec/.pki/crl/phone.crt | grep CRL
  then
    echo "The CRL check passed"
  else
    echo "The CRL check failed"
    exit 1
fi

if sudo openssl x509 -inform pem -noout -text -in ${CONFIGS}/10.0.8.100/ipsec/.pki/certs/user1.crt | grep CN=user1
  then
    echo "The new user exists"
  else
    echo "The new user does not exist"
    exit 1
fi

#
# WireGuard
#

if sudo test -f ${CONFIGS}/10.0.8.100/wireguard/user1.conf
  then
    echo "WireGuard: The new user exists"
  else
    echo "WireGuard: The new user does not exist"
    exit 1
fi

#
# SSH tunneling
#

if sudo test -f ${CONFIGS}/10.0.8.100/ssh-tunnel/user1.ssh_config
  then
    echo "SSH Tunneling: The new user exists"
  else
    echo "SSH Tunneling: The new user does not exist"
    exit 1
fi
