# Vaultwarden Dropbox Nightly Backup
Run this image alongside your Vaultwarden container for automated nightly (1AM UTC) backups of your Vaultwarden database and your attachments to your Dropbox account. Backups are encrypted (OpenSSL AES256) and zipped (`.tar.gz`) with a passphrase of your choice.

**IMPORTANT: Make sure you have at least one personal device (e.g. laptop) connected to Dropbox and syncing files locally. This will save you in the event Vaultwarden goes down and your Dropbox account login was stored in Vaultwarden!!!**

**Note:** Encrypting Vaultwarden backups is not required since the data is already encrypted with user master passwords. We've added this for good practice and added obfuscation should your Dropbox account get compromised.

## Dropbox App Setup
1. Open the following URL in your browser and log in using your account: https://www.dropbox.com/developers/apps
2. Click on "Create App" then select "Choose an API: Scoped Access"
3. Choose the type of access you need: "App folder"
4. Enter the "App Name" that you prefer (e.g. Vaultwarden_Backups); must be unique
5. Click "Create App"
6. Switch to the "Permissions" tab and check "files.metadata.read/write" and "files.content.read/write"
7. Click "Submit"
8. Once your app is created, you can find your "App key" and "App secret" in the "Settings" tab
9. Navigate to the below URL, replacing DROPBOX_APP_KEY with your App key from step 8
   
   `https://www.dropbox.com/oauth2/authorize?client_id=DROPBOX_APP_KEY&token_access_type=offline&response_type=code`
   
   This will provide you with a short-lived access code
10. Make a note of the App key, App secret and Access Code and set up the Docker container as below

## Usage
A Docker image for this app is available on [Docker Hub](https://hub.docker.com/r/jackyaz/vaultwarden_dropbox_backup)
This image will always run an extra backup on container start (regardless of cron interval) to ensure your setup is working.

### docker cli
```bash
docker run -d \
  --name=vaultwarden_dropbox_backup \
  -e DROPBOX_APP_KEY="<your Dropbox App key>" \
  -e DROPBOX_APP_SECRET="<your Dropbox App secret>" \
  -e DROPBOX_ACCESS_CODE="<your Dropbox short-lived access code>" \
  -e CRON="0 1 * * *" \
  -e DELETE_AFTER="30" \
  -e TZ="Europe/London" \
  -e BACKUP_ENCRYPTION_KEY="xxxyyyzzz" \
  -v /path/to/vaultwarden/data:/data \
  -v /path/to/config:/config \
  --restart unless-stopped \
  jackyaz/vaultwarden_dropbox_backup
```

### Parameters
The Docker images supports some parameters. These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-v /apps/vaultwarden:/data` would map ```/apps/vaultwarden``` on the Docker host to ```/data``` inside the container.

#### Environment Variables (-e)
| Env | Function |
| :----: | --- |
| `DROPBOX_APP_KEY="<your Dropbox App key>"` | The App Key for the Dropbox app created in [Dropbox App Setup](#dropbox-app-setup) |
| `DROPBOX_APP_SECRET="<your Dropbox App secret>"` | The App Secret for the Dropbox app created in [Dropbox App Setup](#dropbox-app-setup) |
| `DROPBOX_ACCESS_CODE="<your Dropbox short-lived access code>"` | The Access Code for the Dropbox app created in [Dropbox App Setup](#dropbox-app-setup) |
| `CRON="0 1 * * *"` | cron schedule for backups, defaults to daily at 1AM |
| `DELETE_AFTER="30"` | Used to delete old backups after X many days. This job is executed with each backup cron job run |
| `TZ="Europe/London"` | Timezone to use within the container |
| `BACKUP_ENCRYPTION_KEY="xxxyyyzzz"` | This is for added protection and will be needed when decrypting your backups. An example command to generate a key is `openssl rand -base64 48` |

#### Volume Mappings (-v)
| Parameter | Function |
| :----: | --- |
| `-v /data` | Local path for data directory from Vaultwarden |
| `-v /config` | Local path for saved Dropbox configuration |

When creating the container, ensure you provide a value for all environment variables as appropriate.