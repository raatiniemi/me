# checkov:skip=CKV_DOCKER_3:The base image handles user creation
FROM nginxinc/nginx-unprivileged:1.27.1-alpine-slim
LABEL maintainer="Tobias Raatiniemi <raatiniemi@gmail.com>"

HEALTHCHECK --interval=6s --timeout=3s \
  CMD curl --fail -so /dev/null http://localhost:8080/

WORKDIR /usr/share/nginx/html

COPY public_html ./
