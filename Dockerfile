FROM nginx:1.21.3-alpine
LABEL maintainer="Tobias Raatiniemi <raatiniemi@gmail.com>"

RUN set -x \
  && apk --no-cache add curl=7.79.1-r0 libcurl=7.79.1-r0

COPY public_html /usr/share/nginx/html
