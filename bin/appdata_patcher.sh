#!/bin/bash
set -o allexport
source .env
set +o allexport


FILE=$APPDATA_VOLUME/organizr/www/organizr/data/config/config.php
echo Patching "$FILE"
echo with values below:
echo "'authBackend' => 'ldap'"
sed "s/'authBackend' => ''/'authBackend' => 'ldap'/g" -i "$FILE"
echo "'authBackendHost' => 'ldap://lldap'"
sed "s/'authBackendHost' => ''/'authBackendHost' => 'ldap:\/\/lldap'/g" -i "$FILE"
echo "'authBackendHostPrefix' => 'cn='"
sed "s/'authBackendHostPrefix' => ''/'authBackendHostPrefix' => 'cn='/g" -i "$FILE"
echo "'authBackendHostSuffix' => ',ou=people,$LDAP_HOST'"
sed "s/'authBackendHostSuffix' => ''/'authBackendHostSuffix' => ',ou=people,$LDAP_HOST'/g" -i "$FILE"
echo "'authBaseDN' => 'cn=%s,$LDAP_HOST'"
sed "s/'authBaseDN' => ''/'authBaseDN' => 'cn=%s,$LDAP_HOST'/g" -i "$FILE"
echo "'authType' => 'both'"
sed "s/'authType' => 'internal'/'authType' => 'both'/g" -i "$FILE"
echo "'ldapBindUsername' => 'cn=$LDAP_BIND_ADMIN,ou=people,$LDAP_HOST'"
sed "s/'ldapBindUsername' => ''/'ldapBindUsername' => 'cn=$LDAP_BIND_ADMIN,ou=people,$LDAP_HOST'/g" -i "$FILE"
echo "'ldapType' => '2'"
sed "s/'ldapType' => '1'/'ldapType' => '2'/g" -i "$FILE"
echo
echo
echo All files was patched successfuly
