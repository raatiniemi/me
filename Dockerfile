FROM nginx:1.21.6-alpine
LABEL maintainer="Tobias Raatiniemi <raatiniemi@gmail.com>"

COPY public_html /usr/share/nginx/html
