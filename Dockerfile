FROM openjdk:8-jre

VOLUME ["/hygieia/logs"]

RUN  mkdir /hygieia/config

ENV PROP_FILE /hygieia/config/application.properties

WORKDIR /hygieia

COPY target/*.jar /hygieia
COPY docker/properties-builder.sh /hygieia/
RUN ["chmod", "+x", "/hygieia/properties-builder.sh"]
CMD ./properties-builder.sh &&\
  java -Djava.security.egd=file:/dev/./urandom -jar *.jar --spring.config.location=$PROP_FILE