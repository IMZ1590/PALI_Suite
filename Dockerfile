FROM nginx:alpine

# Copy all static content (index.html, assets/, packages/) to Nginx root
COPY . /usr/share/nginx/html

# Expose HTTP port
EXPOSE 80
