# Spring Boot Admin
## 1. What is spring boot admin?

Spring boot admin manages and monitors spring boot applications. The project is built using [codecentric's spring-boot-admin-starter-server](https://github.com/codecentric/spring-boot-admin).


## 2. Registering Client Applications

In order to let spring boot admin monitor other applications, register the client applications by adding application url to the application.yml, for example: to register program service, add the following to application.yml:

```
spring.boot.admin.client.url: http://localhost:8082 
management.endpoints.web.exposure.include: "*"
```
As with Spring Boot 2 most of the endpoints aren’t exposed via http by default, we expose all of them. For production you should carefully choose which endpoints to expose.


Add the following dependencies to program service:

```
<dependency>
	<groupId>de.codecentric</groupId>
	<artifactId>spring-boot-admin-starter-client</artifactId>
	<version>2.1.3</version>
</dependency>
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-webflux</artifactId>
</dependency>
```



Spring boot admin reference guide:
https://codecentric.github.io/spring-boot-admin/2.1.3/#_what_is_spring_boot_admin

## 3. Configuration with a Dockerized Spring Boot Service
The environment variable `SPRING_BOOT_ADMIN_CLIENT_URL` must be defined with the url of the `spring-boot-admin` server url.

As an example, to run the spring boot service `car_service` while registering it with the `spring-boot-admin` server at `https://my-spring-boot-admin-server.org` , the following command must be run:
```bash
docker run -e "SPRING_BOOT_ADMIN_CLIENT_URL=https://my-spring-boot-admin-server.org" car_service
```

The following is an example `docker-compose.yml`, where the `Dockerfile.car_service` is the dockerfile for the `car_service`
```yaml
version: '3.2'
services:
  car_service:
    build:
      context: ./
      dockerfile: Dockerfile.car_service
    environment:
      SPRING_BOOT_ADMIN_CLIENT_URL: "https://my-spring-boot-admin-server"
```

