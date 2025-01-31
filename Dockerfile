FROM alpine:latest

# set TZ default if not defined in ENVs
ENV TZ=UTC

# set cron default if not defined in ENVs
ENV CRON="0 1 * * *"

# set empty ENVs for Dropbox API IDs and secrets
ENV DROPBOX_APP_KEY=""
ENV DROPBOX_APP_SECRET=""
ENV DROPBOX_ACCESS_CODE=""

# install sqlite, curl, bash (for script)
RUN apk add --no-cache \
    sqlite \
    curl \
    bash \
    tzdata \
    openssl

# copy dropbox uploader script
COPY dropbox_uploader.sh /

# set timezone from ENVs
RUN export TZ=/usr/share/zoneinfo/${TZ}

# copy backup script to /
COPY backup.sh /

# copy entrypoint to /
COPY entrypoint.sh /

# copy delete older backup script to /
COPY deleteold.sh /

# give execution permission to scripts
RUN chmod +x /entrypoint.sh && \
    chmod +x /backup.sh && \
    chmod +x /dropbox_uploader.sh && \
    chmod +x /deleteold.sh

ENTRYPOINT ["/entrypoint.sh"]
