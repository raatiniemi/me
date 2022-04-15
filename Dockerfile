# checkov:skip=CKV_DOCKER_3:The base image handles user creation
FROM nginxinc/nginx-unprivileged:1.21.6-alpine
LABEL maintainer="Tobias Raatiniemi <raatiniemi@gmail.com>"

COPY public_html /usr/share/nginx/html
