#!/bin/bash
set -o allexport
source .env
set +o allexport


FILE=$APPDATA_VOLUME/organizr/www/organizr/data/config/config.php
echo Patching "$FILE"
echo with values below:
echo "'authBackend' => 'ldap'"
sed "s/'authBackend' => ''/'authBackend' => 'ldap'/g" -i "$FILE"
echo "'authBackendHost' => 'ldap://openldap'"
sed "s/'authBackendHost' => ''/'authBackendHost' => 'ldap:\/\/openldap'/g" -i "$FILE"
echo "'authBackendHostPrefix' => 'uid='"
sed "s/'authBackendHostPrefix' => ''/'authBackendHostPrefix' => 'uid='/g" -i "$FILE"
echo "'authBackendHostSuffix' => ',ou=people,$LDAP_HOST'"
sed "s/'authBackendHostSuffix' => ''/'authBackendHostSuffix' => ',ou=people,$LDAP_HOST'/g" -i "$FILE"
echo "'authBaseDN' => 'cn=%s,$LDAP_HOST'"
sed "s/'authBaseDN' => ''/'authBaseDN' => 'cn=%s,$LDAP_HOST'/g" -i "$FILE"
echo "'authType' => 'both'"
sed "s/'authType' => 'internal'/'authType' => 'both'/g" -i "$FILE"
echo "'ldapBindUsername' => 'cn=$LDAP_BIND_ADMIN,$LDAP_HOST'"
sed "s/'ldapBindUsername' => ''/'ldapBindUsername' => 'cn=$LDAP_BIND_ADMIN,$LDAP_HOST'/g" -i "$FILE"
echo "'ldapType' => '2'"
sed "s/'ldapType' => '1'/'ldapType' => '2'/g" -i "$FILE"
echo
echo
# fuck me I am done with that shit
echo Patching nextcloud to allow its usage in organizr iframe
docker exec nextcloud-aio-nextcloud sed ":a;N;\$!ba;s/protected \$allowedFrameAncestors = \[\n\t\t'\\\'self\\\'',\n\t];/protected \$allowedFrameAncestors = \[\n\t\t'\\\'self\\\'',\n\t\t'$HOST',\n\t\t'www.$HOST',\n\t];/g" -i /var/www/html/lib/public/AppFramework/Http/ContentSecurityPolicy.php
echo
echo
echo All files was patched successfuly
