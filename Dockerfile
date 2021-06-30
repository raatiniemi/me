FROM nginx:1.21.0-alpine
LABEL maintainer="Tobias Raatiniemi <raatiniemi@gmail.com>"

RUN set -x \
  && apk --no-cache add curl=7.77.0-r1

COPY public_html /usr/share/nginx/html
