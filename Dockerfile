FROM nginx:1.25-alpine

# Copy custom nginx config
COPY src/nginx.conf /etc/nginx/nginx.conf

# Copy static content
COPY src/index.html /usr/share/nginx/html/

# Create non-root user directories
RUN chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /tmp/nginx.pid && \
    chown -R nginx:nginx /tmp/nginx.pid

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

EXPOSE 80

USER nginx

CMD ["nginx", "-g", "daemon off;"]