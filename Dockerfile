FROM openjdk:11-jdk

RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm \
    apt-get clean

WORKDIR /home/app/

COPY /build/libs/VulnerableApp-1.0.0.jar .

EXPOSE 9090

CMD ["java", "-jar", "VulnerableApp-1.0.0.jar"]