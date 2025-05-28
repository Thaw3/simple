FROM mariadb:latest
EXPOSE 3306

# Copy your SQL file into the init directory
# You MUST build this with the correct context (sql/ folder must exist)
COPY simple_db.sql /docker-entrypoint-initdb.d/
