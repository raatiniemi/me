FROM nginx:1.19.3-alpine
LABEL maintainer="Tobias Raatiniemi <raatiniemi@gmail.com>"

COPY public_html /usr/share/nginx/html
