FROM openjdk:11-jdk-slim as builder 

RUN apt update && \
    apt install -y maven

# Build song-server jar
WORKDIR /srv
COPY . /srv
RUN mvn package -DskipTests

###############################################################################################################

FROM openjdk:11-jre-slim

# Paths
ENV APP_HOME /app-server
ENV APP_LOGS $APP_HOME/logs
ENV JAR_FILE  /spring-boot-admin-server.jar

COPY --from=builder /srv/target/spring-boot-admin-server.jar $JAR_FILE

WORKDIR $APP_HOME

CMD mkdir -p  $APP_HOME $APP_LOGS \
        && java -Dlog.path=$APP_LOGS \
        -jar $JAR_FILE \
        --spring.config.location=classpath:/application.yml
