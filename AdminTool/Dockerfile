# Start with a base image that has the dependencies for Flutter
FROM ubuntu:22.04 AS build

# Install Flutter dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl git unzip xz-utils zip libglu1-mesa && \
    apt-get install -y ca-certificates && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up environment variables
ENV FLUTTER_HOME="/opt/flutter"
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME && \
    flutter doctor

# Set the working directory in the Docker image
WORKDIR /app

# Copy the project files into the Docker image
COPY . .

# Get Flutter dependencies
RUN flutter pub get

# Build the app for release (change this according to your target platform)
# For a web app
RUN flutter build web
# For an Android app, uncomment the next line
#RUN flutter build apk
# For an iOS app, uncomment the next line
# Note: Building for iOS requir

# Use nginx to serve the web application
# If you're not deploying a web app, you may not need this stage.
FROM nginx:stable-alpine

# Copy the build artifacts from the build stage to the nginx container
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 81
EXPOSE 81

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
