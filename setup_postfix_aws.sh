#!/bin/bash

PKGNAME=postfix
POSTFIXDIR=/etc/${PKGNAME}
MAINCF_FILE=${POSTFIXDIR}/main.cf
SASL_FILE=${POSTFIXDIR}/sasl_passwd

CERTFILE=/etc/ssl/certs/ca-certificates.crt

MYEUID=`id | awk -F= '{print $2}' | awk -F\( '{print $1}'`

if [ ${MYEUID} -ne 0 ]
then
   echo "This script must be run as root or via sudo as root, exiting."
   exit 2
fi

dpkg -S ${PKGNAME} > /dev/null 2>&1

if [ $? ]; then
	export DEBIAN_FRONTEND=noninteractive
	echo "Installing ${PKGNAME}..."
	/usr/bin/aptitude -y install ${PKGNAME} > /dev/null 2>&1 
fi

if [ -d ${POSTFIXDIR} ]; then 

	cd ${POSTFIXDIR}

	echo "Enter SMTP USERNAME:"
	read MYUSERNAME

	echo "Enter SMTP PASSWORD?"
	read -s MYPASSWORD

	if [ -f ${SASL_FILE} ]; then
		sed -i "s/USERNAME/$MYUSERNAME/g" ${SASL_FILE}; sed -i "s/PASSWORD/$MYPASSWORD/g" ${SASL_FILE};
		sleep 1
		/usr/sbin/postmap hash:${SASL_FILE}
	else
		echo "No ${SASL_FILE}.  Exiting..."
		echo 1
	fi
	
	if [ -f ${CERTFILE} ]; then
		/usr/sbin/postconf 'smtp_tls_CAfile = ${CERTFILE}'
	else
		echo "No ${SASL_FILE}.  Exiting..."
		echo 1
	fi

	/etc/init.d/postfix restart
	rm -f ${SASL_FILE}

else
	echo "${POSTFIXDIR} not available.  Exiting..."
	echo 1
fi

