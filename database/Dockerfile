FROM postgres:latest
ENV POSTGRES_DB=askmate
ENV POSTGRES_USER=admin
ENV POSTGRES_PASSWORD=supersecret
COPY ./startup.sql /docker-entrypoint-initdb.d/
EXPOSE 5432