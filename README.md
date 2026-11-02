# GreenCityUser

User microservice for GreenCity. It stores accounts, handles sign-up and sign-in, and issues access tokens for the rest of the system.

Students run this service on their own machines. There is no cloud environment and no production deploy. Docker is optional and only packages the app that was already built locally.

The main API is [GreenCityMVP21](https://github.com/Java-groups/GreenCityMVP21). It owns the database schema and calls this service at `http://localhost:8060` for `/ownSecurity`. The front end is [GreenCityClient](https://github.com/ita-social-projects/GreenCityClient). Start the services in that order: GreenCityMVP21, then this service, then the client.

## Requirements

* Java 21
* Maven 3.9 or newer
* Docker Desktop, used by GreenCityMVP21 to run PostgreSQL
* Docker is optional here, only if you want to run the packaged image

## Run locally

1. In GreenCityMVP21, start PostgreSQL and run `greencity.GreenCityApplication` once. Liquibase in that project creates the schema and the language rows (`ua`, `en`, `ru`). Database, user, and password are `greencity`. PostgreSQL listens on port **5432**.

2. Export the same datasource variables for this service. The active profile is `dev` unless you set `PROFILE`. Mail and Google values are optional; set them only when you want verification email or Google sign-in.

```properties
DATASOURCE_URL=jdbc:postgresql://localhost:5432/greencity
DATASOURCE_USER=greencity
DATASOURCE_PASSWORD=greencity
EMAIL_ADDRESS=
EMAIL_PASSWORD=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_ID_MANAGER=
```

3. Open this repository as a Maven project, select JDK 21, and run `greencity.UserApplication` from the `core` module. In IntelliJ IDEA, put the variables on that run configuration.

From the repository root the same start is:

```shell
mvn -pl core -am install -DskipTests
mvn -pl core spring-boot:run
```

4. Open Swagger UI: http://localhost:8060/swagger-ui/index.html

This service does not migrate the database. `spring.jpa.hibernate.ddl-auto` is `validate`, so it starts only after GreenCityMVP21 has created the tables.

## Try the API

1. `POST /ownSecurity/signUp` creates an account. Pass `lang` as `ua`, `en`, or `ru`. The user stays in status `CREATED` until the email is verified. Without mail credentials the message is not delivered.

2. To skip the mailbox, activate the row yourself. `user_status` is stored as an ordinal: `2` is `ACTIVATED`.

```sql
UPDATE users SET user_status = 2 WHERE email = 'you@gmail.com';
```

3. `POST /ownSecurity/signIn` returns access and refresh tokens.

4. In Swagger, click **Authorize** and paste the access token as `Bearer <token>`.

5. A new account has role `ROLE_USER`. Roles are stored as text. For admin-only endpoints:

```sql
UPDATE users SET role = 'ROLE_ADMIN' WHERE email = 'you@gmail.com';
```

Sign in again after changing the role so the new token contains it.

## Docker

Build the jar first. The image only copies `core/target/app.jar`; it does not compile the project. The container must reach the PostgreSQL started by GreenCityMVP21.

```shell
mvn -B -pl core -am package -DskipTests
docker build -t greencity-user:local .
docker run --rm -p 8060:8060 --env-file .env greencity-user:local
```

Put the same variables from the local setup into `.env`. Do not commit that file. From inside the container, `localhost` is the container itself, so point `DATASOURCE_URL` at the host database (`host.docker.internal` on Docker Desktop).

## Checks

Checkstyle and the formatter run during `mvn verify`. The GitHub Actions workflow on `main`, `master`, and `dev` runs that verify step and then builds the Docker image. It does not push the image anywhere.

IDE setup for Checkstyle: [GreenCity wiki](https://github.com/ita-social-projects/GreenCity/wiki/Setup-CheckStyle-to-your-IDE).
