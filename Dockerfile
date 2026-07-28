FROM google/dart:latest as builder

WORKDIR /app

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter && \
    /flutter/bin/flutter config --enable-web && \
    /flutter/bin/flutter precache --web

ENV PATH="/flutter/bin:$PATH"

COPY . .

RUN flutter pub get
RUN flutter build web --release

FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
