FROM nginx:1.27.1-alpine-slim
LABEL maintainer="Tobias Raatiniemi <raatiniemi@gmail.com>"

RUN set -x \
  && apk --no-cache add curl=8.9.0-r0

HEALTHCHECK --interval=6s --timeout=3s \
  CMD curl --fail -so /dev/null http://localhost:8080/

WORKDIR /usr/share/nginx/html

COPY public_html ./
