#!/bin/bash

function print_usage() {
  echo "---------------------------------------"
  echo " Usage: $executable -h <HOSTNAME> [--no-ssl] [--letsencrypt] [--usercert]"
	echo "  -h hostname : hostname, e.g orgname-instansname.enonic.cloud"
  echo "  --no-ssl [DEFAULT]: no ssl config in apache "
	echo "  --letsencrypt : use apache-template with letsencrypt "
	echo "  --usercert : use apache-config with user provided ssl-certificate "
  echo "---------------------------------------"
}

xpProj="exp"
expVHostFile=exp/config/com.enonic.xp.web.vhost.cfg

ctxHome=$(dirname "$0")

apacheTemplateRoot="$ctxHome/_apache_templates"
apacheTemplateName="apache2_no_ssl"
apacheRootFolder="$ctxHome/apache2"
apacheVHostTemplate=$apacheRootFolder/sites/vhost.example.conf.template

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
      -h|--host)
      hostName="$2"
      shift # past argument
      shift # past value
      ;;
      --letsencrypt)
      apacheTemplateName="apache2_letsencrypt"
      shift # past argument
      ;;
			--usercert)
			apacheTemplateName="apache2_user	cert"
			shift # past argument
			;;
			--no-ssl)
			apacheTemplateName="apache2_no_ssl"
			shift # past argument
			;;
      *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done

if [ -z "$hostName" ]; then
	echo "hostname argument is missing, aborting."
	print_usage
	exit 1
fi

echo ""
echo "###############################################################################"
echo "### Enonic XP configurator"
echo "###############################################################################"

echo "Creating apache2 config for $hostName"

apacheTemplate=$apacheTemplateRoot/$apacheTemplateName
if [ ! -d "$apacheTemplate" ]; then
	echo "no maching apache-template found at $apacheTemplate"
	exit 1
fi

echo "Using template $apacheTemplate"
cp -R $apacheTemplate/* $apacheRootFolder

cp $apacheVHostTemplate $apacheRootFolder/sites/$hostName.conf
sed -i".tmp" -e "s/##SITE_HOSTNAME_ESCAPED##/$(echo $hostName | sed 's/\./\\\\./g')/g" $apacheRootFolder/sites/$hostName.conf
sed -i".tmp" -e "s/##SITE_HOSTNAME##/$hostName/g" $apacheRootFolder/sites/$hostName.conf
rm $apacheRootFolder/sites/$hostName.conf.tmp
rm -rf $apacheTemplateRoot

echo "------------------------------------------------------------"
echo "Adding $hostName to Enonic XP vhosts"
sed -i".tmp" -e "s/##SITE_HOSTNAME##/$hostName/g" $expVHostFile
rm $expVHostFile.tmp

echo "------------------------------------------------------------"
echo "Adding $hostName to docker-compose.yml"

sed -i".tmp" -e "s/##SITE_HOSTNAME##/$hostName/g" docker-compose.yml
rm docker-compose.yml.tmp

echo "------------------------------------------------------------"
echo "Generate and store password"

suPasswdClear=$(openssl rand -base64 16 | tr -cd '[[:alnum:]]')
hashedPwd=$(echo -n ${suPasswdClear} | shasum -a 512 | awk '{print $1}')
suPasswd=$(echo "{sha512}${hashedPwd}")

sed -i".tmp" -e "s/xp.suPassword=.*/$(echo xp.suPassword=$suPasswdClear)/g" $xpProj/env.sh
sed -i".tmp" -e "s/xp.suPassword=.*/$(echo xp.suPassword=$suPasswd)/g" $xpProj/config/system.properties
rm $xpProj/env.sh.tmp
rm $xpProj/config/system.properties.tmp

echo "------------------------------------------------------------"
echo "Done! Ready to build and deploy with docker-compose"
echo ""
