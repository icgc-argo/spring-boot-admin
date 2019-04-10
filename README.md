# Spring Boot Admin
1. What is spring boot admin?

Spring boot admin manages and monitors spring boot applications. The project is built using [codecentric's spring-boot-admin-starter-server](https://github.com/codecentric/spring-boot-admin).

2. Resigtering Client Applications

In order to let spring boot admin monitor other applications, register the client applications by adding application url to the application.yml, for example: 
register program service,
add the following to application.yml:

```
spring.boot.admin.client.url: http://localhost:8082 
management.endpoints.web.exposure.include: "*"
```
As with Spring Boot 2 most of the endpoints aren’t exposed via http by default, we expose all of them. For production you should carefully choose which endpoints to expose.



Spring boot admin reference guide:
https://codecentric.github.io/spring-boot-admin/2.1.3/#_what_is_spring_boot_admin
