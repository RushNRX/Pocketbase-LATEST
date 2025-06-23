FROM alpine:latest

# Install necessary packages for fetching and processing the version
RUN apk add --no-cache \
    unzip \
    ca-certificates \
    curl \
    grep \
    sed

# Fetch the latest PocketBase version and set it as an environment variable
# This RUN command will execute during the build process.
RUN PB_VERSION=$(curl -s https://api.github.com/repos/pocketbase/pocketbase/releases/latest | grep 'tag_name' | sed -E 's/.*"tag_name": "v([^"]+)".*/\1/') \
    && echo "Using PocketBase version: $PB_VERSION" \
    && export PB_VERSION

# download and unzip PocketBase using the determined version
ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/

# uncomment to copy the local pb_migrations dir into the image
# COPY ./pb_migrations /pb/pb_migrations

# uncomment to copy the local pb_hooks dir into the image
# COPY ./pb_hooks /pb/pb_hooks

EXPOSE 8080

# start PocketBase
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080"]
