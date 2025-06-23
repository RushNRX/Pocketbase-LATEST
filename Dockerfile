FROM alpine:latest as builder

# Install necessary packages for fetching and processing the version
RUN apk add --no-cache \
    unzip \
    ca-certificates \
    curl \
    grep \
    sed

# Fetch the latest PocketBase version and set it as an environment variable
# This RUN command will execute during the build process.
# If the API call fails or the format is unexpected, we'll use a default.
ARG PB_VERSION_DEFAULT=0.28.4
ENV PB_VERSION=$PB_VERSION_DEFAULT

RUN LATEST_PB_RELEASE_URL="https://api.github.com/repos/pocketbase/pocketbase/releases/latest" \
    && LATEST_TAG=$(curl -s $LATEST_PB_RELEASE_URL | grep 'tag_name' | sed -E 's/.*"tag_name": "v([^"]+)".*/\1/') \
    && if [ -n "$LATEST_TAG" ]; then \
         PB_VERSION=$LATEST_TAG; \
         echo "Using PocketBase version: $PB_VERSION"; \
       else \
         echo "Warning: Failed to fetch latest PocketBase version. Falling back to $PB_VERSION_DEFAULT." >&2; \
       fi \
    && export PB_VERSION

# Download and unzip PocketBase using the determined version
# The ADD instruction needs the version to be available at build time.
# Since ENV is not directly usable by ADD in the same stage, we'll use a trick.
# We'll create a file containing the version, and then use that in ADD.
RUN echo "$PB_VERSION" > /pb_version.txt

FROM alpine:latest

# Install necessary packages for the final image
RUN apk add --no-cache \
    unzip \
    ca-certificates

# Copy the version from the builder stage
COPY --from=builder /pb_version.txt /pb_version.txt

# Read the version from the file
ARG PB_VERSION=$(cat /pb_version.txt)

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
