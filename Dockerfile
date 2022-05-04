FROM shipilev/openjdk-shenandoah:8 

ENV KARMA_VER=v2.5.2 \
    JAVA_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseContainerSupport -XX:MaxRAMFraction=1 -XX:+UseShenandoahGC -XX:ShenandoahGCHeuristics=compact -XX:+UseStringDeduplication -XX:+ExitOnOutOfMemoryError -Dlog4j2.formatMsgNoLookups=true" \ 
    USER=user \
    USER_HOME=/home/user \
    KARMA_USER_HOME=/home/user/karma \
    UID=1000   

# install some packages and add the server 
RUN apt-get update && apt-get install -y git curl sudo gosu wget unzip links vim nano maven libgconf-2-4 && \
    apt-get clean && \  
    groupadd --gid $UID $USER && useradd --gid $UID --uid $UID -d / $USER && echo "user:$6$04SIq7OY$7PT2WujGKsr6013IByauNo0tYLj/fperYRMC4nrsbODc9z.cnxqXDRkAmh8anwDwKctRUTiGhuoeali4JoeW8/:16231:0:99999:7:::" >> /etc/shadow && \
    mkdir -p /home/$USER/.m2 && \ 
    cd /home/$USER && \
    usermod -d /home/$USER/ $USER && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    git clone --branch $KARMA_VER --single-branch https://github.com/usc-isi-i2/Web-Karma.git Web-Karma && \
    chown -R $USER:$USER /home/$USER
# build the server 
RUN cd /home/$USER/Web-Karma && sudo -HEu $USER mvn clean install -Dmaven.test.skip -DskipTests && \
    chown -R $USER:$USER /home/$USER

WORKDIR /home/$USER/Web-Karma/karma-web

EXPOSE 8080

CMD ["sudo", "-HEu", "user", "mvn", "-Dslf4j=false", "-Dlog4j.configuration=file:./target/classes/log4j.properties", "jetty:run"]
