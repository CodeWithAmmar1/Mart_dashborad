# Stage 1: Build the Flutter Web app
FROM debian:latest AS build-env

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl git wget unzip xz-utils libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK and switch to stable
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter channel stable
RUN flutter upgrade

# Copy your app files
COPY . /app
WORKDIR /app

# Build the web app
RUN flutter config --enable-web
RUN flutter pub get
# Using the simplified build command
RUN flutter build web --release

# Stage 2: Serve the app using Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]