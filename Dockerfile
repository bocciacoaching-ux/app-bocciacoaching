FROM debian:bookworm as builder

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter directly from GitHub
RUN git clone https://github.com/flutter/flutter.git /flutter && \
    cd /flutter && \
    git checkout stable && \
    /flutter/bin/flutter config --enable-web --no-analytics && \
    /flutter/bin/flutter config --no-enable-android && \
    /flutter/bin/flutter config --no-enable-ios && \
    /flutter/bin/flutter doctor -v

ENV PATH="/flutter/bin:$PATH"

COPY pubspec.* ./
RUN flutter pub get

COPY . .

RUN flutter build web --release --web-only --no-tree-shake-icons

FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
