#!/bin/sh

# setup dropbox uploader config file
/dropbox_uploader.sh -f /config/.dropbox_uploader info

# run backup once on container start to ensure it works
/backup.sh

echo "${CRON} /backup.sh" > /etc/crontabs/root

# start crond in foreground
exec crond -f
