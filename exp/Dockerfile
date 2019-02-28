FROM enonic/xp-app:6.15.5

ENV SNAPSHOTTER_VERSION 2.0.0
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
RUN wget -O $XP_ROOT/home/deploy/snapshotter-$SNAPSHOTTER_VERSION.jar http://repo.enonic.com/public/com/enonic/app/app-snapshotter/$SNAPSHOTTER_VERSION/app-snapshotter-$SNAPSHOTTER_VERSION.jar
RUN mkdir -p /enonic-xp/home/snapshots && chown $XP_USER /enonic-xp/home/snapshots

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

COPY config/* $XP_ROOT/home/config/

COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

RUN mkdir $XP_ROOT/home/repo && mkdir -p $XP_ROOT/home/work && mkdir -p $XP_ROOT/home/snapshots
RUN chown -R enonic-xp:enonic-xp $XP_ROOT/home

USER enonic-xp
