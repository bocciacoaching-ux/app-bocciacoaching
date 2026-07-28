FROM debian:bookworm as builder

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Dart
RUN curl https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb https://storage.googleapis.com/download.dartlang.org/linux/debian stable main" > /etc/apt/sources.list.d/dart_stable.list && \
    apt-get update && apt-get install -y dart && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/lib/dart/bin:$PATH"

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter && \
    /flutter/bin/flutter config --enable-web && \
    /flutter/bin/flutter doctor

ENV PATH="/flutter/bin:$PATH"

COPY . .

RUN flutter pub get
RUN flutter build web --release

FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
