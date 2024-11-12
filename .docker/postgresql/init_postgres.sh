#!/bin/bash

# Wait for PostgreSQL to start
until psql -U "$POSTGRES_USER" -c '\q'; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 1
done

# Create the new database
psql -U "$POSTGRES_USER" -c "CREATE DATABASE $POSTGRES_DB_NAME;"

# Create the new user with login and create privileges
psql -U "$POSTGRES_USER" -c "CREATE USER $POSTGRES_USER_NAME WITH PASSWORD '$POSTGRES_USER_PASSWORD' LOGIN CREATEDB;"

# Grant all privileges on the database to the new user
psql -U "$POSTGRES_USER" -c "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB_NAME TO $POSTGRES_USER_NAME;"

# Connect to the newly created database
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB_NAME" <<EOSQL
-- Grant usage on the schema
GRANT USAGE ON SCHEMA public TO tester;

-- Grant create on the schema
GRANT CREATE ON SCHEMA public TO $POSTGRES_USER_NAME;

-- Grant all privileges on all tables in the schema (including future tables)
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO $POSTGRES_USER_NAME;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $POSTGRES_USER_NAME;

-- Grant all privileges on all sequences in the schema (including future sequences)
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO $POSTGRES_USER_NAME;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $POSTGRES_USER_NAME;

-- Grant all privileges on all functions in the schema
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO $POSTGRES_USER_NAME;

-- Grant all privileges on the database (for creating schemas and other database-level operations)
GRANT CONNECT, CREATE, TEMPORARY ON DATABASE $POSTGRES_DB_NAME TO $POSTGRES_USER_NAME;

-- Grant create on the database to allow creating schemas
GRANT CREATE ON DATABASE $POSTGRES_DB_NAME TO $POSTGRES_USER_NAME;
EOSQL