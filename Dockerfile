FROM alpine:latest

# Install necessary packages for fetching and processing the version
# We'll install only what's strictly needed for version extraction first.
RUN apk add --no-cache \
    curl \
    grep \
    sed

# Fetch the latest PocketBase version and set it as an environment variable
# This RUN command will execute during the build process.
# We use a more direct grep/sed to extract the tag_name.
RUN LATEST_PB_RELEASE_URL="https://api.github.com/repos/pocketbase/pocketbase/releases/latest" \
    && PB_VERSION=$(curl -s $LATEST_PB_RELEASE_URL | grep 'tag_name' | sed -E 's/.*"tag_name": "v([^"]+)".*/\1/') \
    && echo "Using PocketBase version: $PB_VERSION" \
    && export PB_VERSION

# Now, install the remaining packages needed for the actual download and unzip
# This separates the potentially resource-intensive package installation.
RUN apk add --no-cache \
    unzip \
    ca-certificates

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
