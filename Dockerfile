# checkov:skip=CKV_DOCKER_3:The base image handles user creation
FROM nginxinc/nginx-unprivileged:1.23.3-alpine
LABEL maintainer="Tobias Raatiniemi <raatiniemi@gmail.com>"

WORKDIR /usr/share/nginx/html

COPY public_html ./
