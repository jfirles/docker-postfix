#!/bin/bash

## Validamos que esten todas la variables
## verificamos que estan seteadas las variables de la base de datos
VARS_MUST_SETTED="SMTP_SERVER_DOMAIN SMTP_ALLOWED_RELAY POSTMASTER_EMAIL"

for i in $VARS_MUST_SETTED;do
        VALUE=${!i}
        if [ -z $VALUE ];then
                echo "ERROR: $i env var is not setted"
                exit 1
        fi
done

## añadimos el mailname
echo $SMTP_SERVER_DOMAIN > /etc/mailname

## cambiamos el myhostname
sed -i "s/^myhostname.*/myhostname = $SMTP_SERVER_DOMAIN/g" /etc/postfix/main.cf

## cambiamos el mynetworks
ALLOWED_RELAY=$(echo $SMTP_ALLOWED_RELAY | sed 's/:/ /g')
sed -i "s#^mynetworks.*#mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 $ALLOWED_RELAY#g" /etc/postfix/main.cf

HOSTNAME=$(echo $SMTP_SERVER_DOMAIN | awk -F"." '{print $1}')
## cambiamos el mydestination
sed -i "s#mydestination.*#mydestination = \$myhostname, /etc/mailname, $HOSTNAME, localhost.localdomain, localhost#g" /etc/postfix/main.cf

## creamos el aliases
echo "postmaster:    root" > /etc/aliases
echo "root:	$POSTMASTER_EMAIL" >> /etc/aliases
newaliases

exec "$@"
