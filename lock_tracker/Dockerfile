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
ENV ANDROID_HOME="/opt/android-sdk"
ENV FLUTTER_HOME="/opt/flutter"
ENV PATH="$PATH:$FLUTTER_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

# Download and install Android command line tools
#RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
#    curl -o cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip && \
#    unzip cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools && \
#    mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest && \
#    rm cmdline-tools.zip


# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME && \
    flutter doctor


# Accept Android SDK licenses
#RUN yes | sdkmanager --licenses

# Install Android platforms and build-tools
#RUN sdkmanager "platform-tools" "platforms;a ndroid-29" "build-tools;29.0.3"

# Set the working directory in the Docker image
WORKDIR /app

# Copy your app files to the Docker image
COPY . .

# Get Flutter dependencies
RUN flutter pub get

# Build the app for release (change this according to your target platform)
# For a web app
RUN flutter build web
# For an Android app, uncomment the next line
# RUN flutter build apk
# For an iOS app, uncomment the next line
# Note: Building for iOS requires a macOS environment
# RUN flutter build ios

# The following stage is for running a Flutter web app.
# If you're building for iOS or Android, you might not need this stage.
# Start with a base image for serving the web app
FROM nginx:stable-alpine

# Copy the build artifacts from the build stage to the nginx container
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]




