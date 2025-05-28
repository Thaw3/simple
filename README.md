# simple

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

```bash
docker build -t flask_api:v1 .
```

```bash
docker build -t mariadb:v1 . 
```

```bash
export APIPWD="/Users/kyawswartun/Dev/proj/simple/flask/api"
```

```bash
docker run -p 5000:5000 -v "$APIPWD":/app flask_api
```

```bash
export SQLPWD="/Users/kyawswartun/Dev/proj/simple/flask/sql"
```

```bash
docker run -it \
  --name my-mariadb \
  -e MYSQL_ROOT_PASSWORD=root_password \
  -e MYSQL_DATABASE=simple_db \
  -e MYSQL_USER=flutter \
  -e MYSQL_PASSWORD=password \
  -v "$SQLPWD/simple_db.sql":/docker-entrypoint-initdb.d/simple_db.sql \
  -p 3306:3306 \
  mariadb:v1 bash
```