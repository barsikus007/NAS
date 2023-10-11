#!/bin/bash
set -o allexport
source .env
set +o allexport


INITIAL_DIR=apps/
PATCHES_DIR=patched_apps/
rm -rf $PATCHES_DIR
mkdir $PATCHES_DIR
echo '*' >> $PATCHES_DIR/.gitignore
echo
echo
FILE_DIR=openldap/ldifs/
OLD_FILE_DIR=$INITIAL_DIR$FILE_DIR
NEW_FILE_DIR=$PATCHES_DIR$FILE_DIR
FILE=tree.ldif
OLD_FILE=$OLD_FILE_DIR$FILE
NEW_FILE=$NEW_FILE_DIR$FILE
echo Patching $OLD_FILE
echo with values below:
mkdir -p $NEW_FILE_DIR
cp $OLD_FILE $NEW_FILE_DIR
echo LDAP_HOST="$LDAP_HOST"
sed "s/%%LDAP_HOST%%/$LDAP_HOST/g" -i $NEW_FILE
echo LDAP_FIRST_DC="$LDAP_FIRST_DC"
sed "s/%%LDAP_FIRST_DC%%/$LDAP_FIRST_DC/g" -i $NEW_FILE
echo LDAP_ORGANIZATION="$LDAP_ORGANIZATION"
sed "s/%%LDAP_ORGANIZATION%%/$LDAP_ORGANIZATION/g" -i $NEW_FILE
echo
echo
echo All files was patched successfuly
echo Please review them and copy with command below:
echo sudo cp -r $PATCHES_DIR'*' "$APPDATA_VOLUME"/
