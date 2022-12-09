#!/bin/sh

# create backup filename
BACKUP_FILE="vaultwarden_$(date "+%F-%H%M%S")"

# use sqlite3 to create backup (avoids corruption if db write in progress)
sqlite3 /data/db.sqlite3 ".backup '/tmp/db.sqlite3'"

# tar up backup and encrypt with openssl and encryption key
tar -czf - /tmp/db.sqlite3 /data/attachments /data/config.json | openssl enc -e -aes256 -salt -pbkdf2 -pass pass:"${BACKUP_ENCRYPTION_KEY}" -out "/tmp/${BACKUP_FILE}.tar.gz"

# upload encrypted tar to dropbox
/dropbox_uploader.sh -f /config/.dropbox_uploader upload "/tmp/${BACKUP_FILE}.tar.gz" "/${BACKUP_FILE}.tar.gz"

# cleanup tmp folder
rm -rf /tmp/*

# delete older backups if variable is set & greater than 0
if [ -n "$DELETE_AFTER" ] && [ "$DELETE_AFTER" -gt 0 ]; then
  /deleteold.sh
fi
