#!/usr/bin/env bash
set -e

export LOG_FILE=/tmp/cert-regen.log

CERT_DIR=/etc/ssl/certs
KEY_DIR=/etc/ssl/private
CONFIG_DIR=/etc/lamassu
LAMASSU_CA_PATH=$CERT_DIR/Lamassu_CA.pem
CA_KEY_PATH=$KEY_DIR/Lamassu_OP_Root_CA.key
CA_PATH=$CERT_DIR/Lamassu_OP_Root_CA.pem
SERVER_KEY_PATH=$KEY_DIR/Lamassu_OP.key
SERVER_CERT_PATH=$CERT_DIR/Lamassu_OP.pem

echo
echo "Backing up SSL certificates..."

mkdir -p /root/backups/cert_backup
cd /root/backups/cert_backup

tar -czvf etc_ssl_certs.tar.gz $CERT_DIR  >> $LOG_FILE 2>&1
tar -czvf etc_ssl_private.tar.gz $KEY_DIR >> $LOG_FILE 2>&1
tar -czvf etc_lamassu.tar.gz $CONFIG_DIR >> $LOG_FILE 2>&1

cd

echo "Generating updated SSL certificates..."

decho () {
  echo `date +"%H:%M:%S"` $1
  echo `date +"%H:%M:%S"` $1 >> $LOG_FILE
}

openssl genrsa \
  -out $CA_KEY_PATH \
  4096 >> $LOG_FILE 2>&1

openssl req \
  -x509 \
  -sha256 \
  -new \
  -nodes \
  -key $CA_KEY_PATH \
  -days 3650 \
  -out $CA_PATH \
  -subj "/C=IS/ST=/L=Reykjavik/O=Lamassu Operator CA/CN=operator.lamassu.is" \
  >> $LOG_FILE 2>&1

openssl genrsa \
  -out $SERVER_KEY_PATH \
  4096 >> $LOG_FILE 2>&1

IP=$(ifconfig eth0 | grep "inet" | grep -v "inet6" | awk '{print $2}')

openssl req -new \
  -key $SERVER_KEY_PATH \
  -out /tmp/Lamassu_OP.csr.pem \
  -subj "/C=IS/ST=/L=Reykjavik/O=Lamassu Operator/CN=$IP" \
  -reqexts SAN \
  -sha256 \
  -config <(cat /etc/ssl/openssl.cnf \
      <(printf "[SAN]\nsubjectAltName=IP.1:$IP")) \
  >> $LOG_FILE 2>&1

openssl x509 \
  -req -in /tmp/Lamassu_OP.csr.pem \
  -CA $CA_PATH \
  -CAkey $CA_KEY_PATH \
  -CAcreateserial \
  -out $SERVER_CERT_PATH \
  -extfile <(cat /etc/ssl/openssl.cnf \
      <(printf "[SAN]\nsubjectAltName=IP.1:$IP")) \
  -extensions SAN \
  -days 3650 >> $LOG_FILE 2>&1

sed -i "s/\"hostname\": \"[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\",/\"hostname\": \""$IP"\",/g" /etc/lamassu/lamassu.json

supervisorctl restart lamassu-server lamassu-admin-server >> $LOG_FILE 2>&1

rm /tmp/Lamassu_OP.csr.pem

echo
echo "Finished."
