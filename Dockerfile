FROM alpine:latest

# Define the default version as a fallback
ARG PB_VERSION_DEFAULT=0.28.4

RUN LATEST_PB_RELEASE_URL="https://api.github.com/repos/pocketbase/pocketbase/releases/latest" \
    && PB_VERSION=$(curl -s $LATEST_PB_RELEASE_URL | grep 'tag_name' | sed -E 's/.*"tag_name": "v([^"]+)".*/\1/') \
    && if [ -z "$PB_VERSION" ]; then \
         echo "Warning: Failed to fetch latest PocketBase version. Falling back to $PB_VERSION_DEFAULT." >&2; \
         PB_VERSION=$PB_VERSION_DEFAULT; \
       fi \
    && echo "Using PocketBase version: $PB_VERSION" \
    && export PB_VERSION

# Install necessary packages for fetching and processing the version
# This is done in a separate RUN to ensure it's available for the version extraction above.
RUN apk add --no-cache \
    unzip \
    ca-certificates \
    curl \
    grep \
    sed

# download and unzip PocketBase using the determined version
# The variable PB_VERSION is now available due to the 'export' in the previous RUN.
ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/

# uncomment to copy the local pb_migrations dir into the image
# COPY ./pb_migrations /pb/pb_migrations

# uncomment to copy the local pb_hooks dir into the image
# COPY ./pb_hooks /pb/pb_hooks

EXPOSE 8080

# start PocketBase
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080"]
