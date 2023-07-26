FROM openjdk:11-jdk

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean

RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm

WORKDIR /home/app/

COPY . .

RUN ./gradlew build

EXPOSE 9090

CMD ["java", "-jar", "build/libs/VulnerableApp-1.0.0.jar"]