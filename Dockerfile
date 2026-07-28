FROM cirrusci/flutter:latest

WORKDIR /app

COPY . .

RUN flutter pub get
RUN flutter build web --release

FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
