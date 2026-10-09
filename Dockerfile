# Author: Poojitha Nasappa
# SWE645 Assignment 2 - packages the HW1 student survey website into an nginx container.
FROM nginx:alpine
COPY index.html survey.html error.html /usr/share/nginx/html/
COPY assets /usr/share/nginx/html/assets
EXPOSE 80
