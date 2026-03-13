# Stage 1: Build the Flutter Web app
FROM debian:latest AS build-env

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl git wget unzip xz-utils libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user to avoid permission warnings
RUN useradd -ms /bin/bash flutteruser
USER flutteruser

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /home/flutteruser/flutter
ENV PATH="/home/flutteruser/flutter/bin:/home/flutteruser/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Set working directory
WORKDIR /home/flutteruser/app
COPY --chown=flutteruser:flutteruser . .

# Build the web app
RUN flutter config --enable-web
RUN flutter pub get
# Simplified command - the renderer is handled automatically
RUN flutter build web --release

# Stage 2: Serve the app using Nginx
FROM nginx:alpine
COPY --from=build-env /home/flutteruser/app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]