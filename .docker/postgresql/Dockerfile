FROM postgres:latest

# Copy the PostgreSQL initialization script into the container
COPY init_postgres.sh /docker-entrypoint-initdb.d/

# Make the script executable
RUN chmod +x /docker-entrypoint-initdb.d/init_postgres.sh

EXPOSE 5432
