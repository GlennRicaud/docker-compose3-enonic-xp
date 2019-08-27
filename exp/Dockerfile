FROM enonic/xp:7.0.2-ubuntu

ENV SNAPSHOTTER_VERSION 2.1.0
# Set Memory settings
# Defaults to 1/4 of servers physical mem
# On single cpu
# ENV JAVA_OPTS "-Xms2G -Xmx2G"
# On multi cpu systems
# ENV JAVA_OPTS "-Xms3G -Xmx3G -Djsse.enableSNIExtension=true -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=60 -XX:+ScavengeBeforeFullGC -XX:+CMSScavengeBeforeRemark"
# Dump memory to heapdum file on outofmem
ENV JAVA_OPTS="$JAVA_OPTS -XX:-HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/heapdump.hprof"

USER root

RUN cp -r $XP_ROOT/home.org $XP_ROOT/home

###############################################################################
#    Insert commands to place Enonic XP application in deploy folder here.    #
###############################################################################

# Either place the compiled jar file in the deploy folder...
COPY deploy/* $XP_ROOT/home/deploy/

# Or download it from an alternative source on the net.
RUN wget -O $XP_ROOT/home/deploy/snapshotter-$SNAPSHOTTER_VERSION.jar http://repo.enonic.com/public/com/enonic/app/snapshotter/$SNAPSHOTTER_VERSION/snapshotter-$SNAPSHOTTER_VERSION.jar

###############################################################################
# profiling
###############################################################################

#RUN wget https://www.yourkit.com/download/docker/YourKit-JavaProfiler-2018.04-docker.zip -P /tmp/ && \
#  unzip /tmp/YourKit-JavaProfiler-2018.04-docker.zip -d /usr/local && \
#  rm /tmp/YourKit-JavaProfiler-2018.04-docker.zip

#ENV JAVA_OPTS="$JAVA_OPTS -agentpath:/usr/local/YourKit-JavaProfiler-2018.04/bin/linux-x86-64/libyjpagent.so=port=10001,listen=all"

###############################################################################
# configure
###############################################################################

RUN mkdir -p /enonic-xp/home/snapshots && chown $XP_USER /enonic-xp/home/snapshots
RUN mkdir -p /enonic-xp/home/work && chown $XP_USER /enonic-xp/home/work
RUN mkdir -p /enonic-xp/home/repo/index && chown $XP_USER /enonic-xp/home/repo/index

COPY config/* $XP_ROOT/home/config/

COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

RUN chown enonic-xp -R $XP_ROOT/home

EXPOSE 9200

USER enonic-xp
