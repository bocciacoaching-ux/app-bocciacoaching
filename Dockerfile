FROM debian:bookworm as builder

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter - skip doctor to avoid Gradle download
RUN git clone https://github.com/flutter/flutter.git /flutter && \
    cd /flutter && \
    git checkout stable

ENV PATH="/flutter/bin:$PATH"
ENV FLUTTER_SKIP_DOWNLOAD_LOCK_FILE=true

# Mark flutter dir as safe for git (running as root)
RUN git config --global --add safe.directory /flutter

# Configure Flutter for web only
RUN /flutter/bin/flutter config --enable-web --no-analytics && \
    /flutter/bin/flutter config --no-enable-android && \
    /flutter/bin/flutter config --no-enable-ios

# Pre-download Dart SDK without Gradle
RUN /flutter/bin/dart --version

COPY pubspec.* ./

# Get dependencies but skip android/ios setup
RUN /flutter/bin/flutter pub get --no-example 2>/dev/null || true

COPY . .

RUN /flutter/bin/flutter build web --release --no-tree-shake-icons

FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
