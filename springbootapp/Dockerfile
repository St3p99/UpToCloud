FROM maven:3.8.5-openjdk-11

USER root
COPY /uptocloud.p12 $JAVA_HOME/jre/lib/security

RUN ls -l >> /dev/stderr

WORKDIR $JAVA_HOME/jre/lib/security

RUN keytool -keystore cacerts -storepass sdcc2022 -noprompt -trustcacerts -importcert -alias uptocloud -file uptocloud.p12

WORKDIR /
COPY . .
#RUN mvn install
RUN mvn clean install
CMD mvn spring-boot:run

