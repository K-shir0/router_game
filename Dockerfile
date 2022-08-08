FROM cirrusci/flutter:3.0.5 AS builder

COPY . /tmp/
WORKDIR /tmp

RUN flutter pub get
RUN flutter build web \
    --release


FROM nginx:stable-alpine

COPY --from=builder /tmp/build/web /usr/share/nginx/html/
#COPY assets /usr/share/nginx/html/assets

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf