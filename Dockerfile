FROM nginx:1.21.3-alpine
LABEL maintainer="Tobias Raatiniemi <raatiniemi@gmail.com>"

RUN set -x \
  && apk --no-cache add curl=7.77.0-r1 libcurl=7.77.0-r1 libxml2=2.9.10-r7

COPY public_html /usr/share/nginx/html
