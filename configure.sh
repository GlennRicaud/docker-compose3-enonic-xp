#!/bin/bash

xpProj="exp"
apacheProj="apache2"


echo "###############################################################################"
echo "### Enonic XP configurator"
instanceHostname=$1

if [ -z "$instanceHostname" ]; then
	echo "hostname argument is missing, aborting."
	exit 1
fi

apache2VHostTemplate=apache2/sites/vhost.example.conf.template
expVHostFile=exp/config/com.enonic.xp.web.vhost.cfg

echo "###############################################################################"
echo "### Creating apache2 config for $instanceHostname"

cp $apache2VHostTemplate apache2/sites/$instanceHostname.conf
sed -i".tmp" -e "s/SITE_HOSTNAME_ESCAPED/$(echo $instanceHostname | sed 's/\./\\\\./g')/g" apache2/sites/$instanceHostname.conf
sed -i".tmp" -e "s/SITE_HOSTNAME/$instanceHostname/g" apache2/sites/$instanceHostname.conf
rm apache2/sites/$instanceHostname.conf.tmp

echo "###############################################################################"
echo "### Adding $instanceHostname to Enonic XP vhosts"

sed -i".tmp" -e "s/SITE_HOSTNAME/$instanceHostname/g" $expVHostFile
rm $expVHostFile.tmp

echo "###############################################################################"
echo "### Adding $instanceHostname to docker-compose.yml"

sed -i".tmp" -e "s/SITE_HOSTNAME/$instanceHostname/g" docker-compose.yml
rm docker-compose.yml.tmp


echo "###############################################################################"
echo "### Generate and store password"
echo "###############################################################################"

suPasswdClear=$(openssl rand -base64 16 | tr -cd '[[:alnum:]]')
hashedPwd=$(echo -n ${suPasswdClear} | shasum -a 512 | awk '{print $1}')
suPasswd=$(echo "{sha512}${hashedPwd}")

sed -i".tmp" -e "s/xp.suPassword=.*/$(echo xp.suPassword=$suPasswdClear)/g" $xpProj/env.sh
sed -i".tmp" -e "s/xp.suPassword=.*/$(echo xp.suPassword=$suPasswd)/g" $xpProj/config/system.properties
rm $xpProj/env.sh.tmp
rm $xpProj/config/system.properties.tmp

echo "###############################################################################"
echo "### Ready to build and deploy with docker-compose"
echo "###############################################################################"
