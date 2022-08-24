# Version: 0.0.9

FROM almalinux:8

ARG EMBEDDED

VOLUME /backup

# ADDING THIS TO CONNECT TO EXTERNAL POSTGRES -> OVERRIDE IN RUN COMMAND OR IN COMPOSE FILE
ENV DB_HOST=postgres-whd
ENV CONSOLETYPE=serial PRODUCT_VERSION=12.7.8 PRODUCT_NAME=webhelpdesk-12.7.8.8471-1.x86_64.rpm.gz GZIP_FILE=webhelpdesk.rpm.gz RPM_FILE=webhelpdesk.rpm EMBEDDED=${EMBEDDED:-true} WHD_HOME=/usr/local/webhelpdesk

RUN echo Environment :: $EMBEDDED

ADD functions /etc/rc.d/init.d/functions
### USE THIS FOR LOCALLY DOWNLOADED RPM
# ADD webhelpdesk-12.7.8.8471-1.x86_64.rpm /$RPM_FILE

### USE THIS FOR DOWNLOADING FROM INTERWEBZ
ADD http://downloads.solarwinds.com/solarwinds/Release/WebHelpDesk/$PRODUCT_VERSION/$PRODUCT_NAME /$GZIP_FILE


RUN dnf update -y && dnf install -y python3-devel urw-base35-fonts && pip3 install supervisor && dnf clean all
RUN gunzip -dv /$GZIP_FILE && dnf install -y /$RPM_FILE && rm /$RPM_FILE && rm -rf /var/cache/dnf
RUN cp $WHD_HOME/conf/whd.conf.orig $WHD_HOME/conf/whd.conf && sed -i 's/^PRIVILEGED_NETWORKS=[[:space:]]*$/PRIVILEGED_NETWORKS=0.0.0.0\/0/g' $WHD_HOME/conf/whd.conf

ADD whd_start_configure.sh $WHD_HOME/whd_start_configure.sh
ADD whd_start.sh $WHD_HOME/whd_start.sh
ADD whd_configure.sh $WHD_HOME/whd_configure.sh
ADD setup_whd_db.sh $WHD_HOME/setup_whd_db.sh
ADD setup_whd_embedded_db.sh $WHD_HOME/setup_whd_embedded_db.sh
ADD whd-api-config-call.properties $WHD_HOME/whd-api-config-call.properties
ADD whd-api-create-call.properties $WHD_HOME/whd-api-create-call.properties
ADD run.sh /run.sh
ADD supervisord.conf /home/docker/whd/supervisord.conf
# ADD whd $WHD_HOME/whd
ADD whd_bin $WHD_HOME/bin/whd
RUN ln -s /usr/lib64/libcrypto.so.1.1 /usr/lib64/libcrypto.so.10
RUN ln -s /usr/lib64/libssl.so.1.1 /usr/lib64/libssl.so.10
RUN ln -s /usr/lib64/libreadline.so.7 /usr/lib64/libreadline.so.6
RUN chmod 744 /run.sh && chmod 644 $WHD_HOME/*.properties && chmod 755 $WHD_HOME/whd && chmod 744 $WHD_HOME/*.sh && chmod 755 $WHD_HOME/bin/whd 
EXPOSE 8081

ENTRYPOINT ["/run.sh"]

