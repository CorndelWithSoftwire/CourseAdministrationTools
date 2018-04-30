#!/bin/bash
#
# Backup script from https://bitbucket.org/atlassianlabs/automatic-cloud-backup/issues/17/backup-script-for-confluence-cloud-find-it
#
# Expects the following variables
# * USERNAME
# * PASSWORD
# * INSTANCE
# * LOCATION
#

# Set this to your Atlassian instance's timezone.
# See this for a list of possible values:
# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
TIMEZONE=Europe/Amsterdam

##----START-----###
echo "Starting the script..."

# Grabs cookies and generates the backup on the UI. ########
### PLEASE NOTICE THAT THE SESSION IS CREATED BY CALLING THE JIRA SESSION ENDPOINT!!! ######
#### THE SCRIPT DOES NOT WORK IF JIRA IS NOT INSTALLED !!! #######
TODAY=$(TZ=$TIMEZONE date +%Y%m%d)
COOKIE_FILE_LOCATION=jiracookie
curl --silent --cookie-jar $COOKIE_FILE_LOCATION -X POST "https://${INSTANCE}/rest/auth/1/session" -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}" -H 'Content-Type: application/json' --output /dev/null

## The $BKPMSG variable will print the error message, you can use it if you're planning on sending an email
BKPMSG=$(curl -s --cookie $COOKIE_FILE_LOCATION --header "X-Atlassian-Token: no-check" -H "X-Requested-With: XMLHttpRequest" -H "Content-Type: application/json"  -X POST https://${INSTANCE}/wiki/rest/obm/1.0/runbackup -d '{"cbAttachments":"true" }' )

 ## Checks if the backup procedure has failed
if [ "$(echo "$BKPMSG" | grep -ic backup)" -ne 0 ]; then
rm $COOKIE_FILE_LOCATION
echo "FAILED, IT RETURNED $BKPMSG"
exit 1
fi

## Checks if the backup exists every 10 seconds, 2000 times. If you have a bigger instance with a larger backup file you'll probably want to increase that.
for (( c=1; c<=2000; c++ ))
do
PROGRESS_JSON=$(curl -s --cookie $COOKIE_FILE_LOCATION https://${INSTANCE}/wiki/rest/obm/1.0/getprogress.json)
FILE_NAME=$(echo "$PROGRESS_JSON" | sed -n 's/.*"fileName"[ ]*:[ ]*"\([^"]*\).*/\1/p')

##ADDED: PRINT BACKUP STATUS INFO ##
echo "$PROGRESS_JSON"

if [[ $PROGRESS_JSON == *"error"* ]]; then
break
fi

if [ ! -z "$FILE_NAME" ]; then
break
fi
sleep 10
done

#If after 2000 attempts it still fails it ends the script.
if [ -z "$FILE_NAME" ];
then
rm $COOKIE_FILE_LOCATION
exit
else

## PRINT THE FILE TO DOWNLOAD ##
echo "File to download: $FILE_NAME"

curl -s -L --cookie $COOKIE_FILE_LOCATION "https://${INSTANCE}/wiki/download/$FILE_NAME" -o "$LOCATION/CONF-backup-${TODAY}.zip"

fi
rm $COOKIE_FILE_LOCATION
