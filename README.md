# Vaultwarden Dropbox Nightly Backup
Run this image alongside your Vaultwarden container for automated nightly (1AM UTC) backups of your Vaultwarden database and your attachments to your Dropbox account. Backups are encrypted (OpenSSL AES256) and zipped (`.tar.gz`) with a passphrase of your choice.

**IMPORTANT: Make sure you have at least one personal device (e.g. laptop) connected to Dropbox and syncing files locally. This will save you in the event Vaultwarden goes down and your Dropbox account login was stored in Vaultwarden!!!**

**Note:** Encrypting Vaultwarden backups is not required since the data is already encrypted with user master passwords. We've added this for good practice and added obfuscation should your Dropbox account get compromised.

## How to Use
- Pre-built images are available at `jackyaz/vaultwarden_dropbox_backup`.
- Volume mount the `/data` folder your vaultwarden container uses.
- Volume mount the `/config` folder that will contain the Dropbox Uploader configuration (Dropbox app key, secret and refresh token). See Initial setup for more details.
- Pick a secure `BACKUP_ENCRYPTION_KEY`. This is for added protection and will be needed when decrypting your backups. An example command to generate a key is `openssl rand -base64 48`
- Follow the steps below to grant upload access to your Dropbox account.
- This image will always run an extra backup on container start (regardless of cron interval) to ensure your setup is working.
- Supports an optional `DELETE_AFTER` environment variable which is used to delete old backups after X many days. This job is executed with each backup cron job run.
- Set local timezone using the `TZ` environmental variable - set to your zone as seen from [this list](https://manpages.ubuntu.com/manpages/bionic/man3/DateTime::TimeZone::Catalog.3pm.html)

### Initial setup
1. Open the following URL in your browser and log in using your account: https://www.dropbox.com/developers/apps
2. Click on "Create App" then select "Choose an API: Scoped Access"
3. Choose the type of access you need: "App folder"
4. Enter the "App Name" that you prefer (e.g. MyVaultBackups); must be unique
5. Click "Create App"
6. Switch to the "Permissions" tab and check "files.metadata.read/write" and "files.content.read/write"
7. Click "Submit"
8. Once your app is created, you can find your "App key" and "App secret" in the "Settings" tab
9. Navigate to the below URL, replacing DROPBOX_APP_KEY with your App key from step 8
   
   `https://www.dropbox.com/oauth2/authorize?client_id=DROPBOX_APP_KEY&token_access_type=offline&response_type=code`
   This will provide you with a short-lived access code
10. Create the below 3 environment variables for the Docker container:

    `DROPBOX_APP_KEY=<your Dropbox App key>`

    `DROPBOX_APP_SECRET=<your Dropbox App secret>`

    `DROPBOX_ACCESS_CODE=<your Dropbox short-lived token>`

    Make sure to remove the surrounding `< >` when setting the variables!
11. Start the container. This will use the environment variables to request a refresh token from Dropbox and store all required fields in /config/.dropbox_uploader within the container (this should have been mapped in point 3 of `How to Use`)

### Decrypting Backup
`openssl enc -d -aes256 -salt -pbkdf2 -in mybackup.tar.gz | tar xz --strip-components=1`

### Restoring Backup to Vaultwarden
Volume mount the decrypted `./bwdata` folder to your vaultwarden container. Done!
