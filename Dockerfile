FROM alpine:3.23 AS build
WORKDIR /app

RUN apk add --no-cache npm

COPY ./package.json ./package-lock.json* ./

RUN npm ci && npm cache clean --force

COPY . .

RUN npm run build && rm -rf node_modules && npm cache clean --force

FROM alpine:3.23
RUN apk add --no-cache nginx=~1.29 && adduser -S -D -H -u 10001 nginx_usr \
    && chown -R nginx_usr /var/lib/nginx /var/log/nginx /run/nginx /usr/share/nginx /etc/nginx

COPY --from=build /app/build /usr/share/nginx/html
COPY ./frontend.nginx.conf /etc/nginx/nginx.conf

USER nginx_usr

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
