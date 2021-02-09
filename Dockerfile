# Here is a Dockerfile demo
FROM ubi7/ubi:7.8

MAINTAINER "Vicente Jimenez <vjjmiras@redhat.com>"

# Installation of web pacakges and customization to use port 8080
RUN yum install -y httpd && \
    yum clean all && \
    sed -i -e 's,^Listen 80,Listen 8080,' /etc/httpd/conf/httpd.conf

# Some variables that will be visible during execution of the container
ENV COURSE_CODE=DO180 \
    COURSE_TITLE="Red Hat OpenShift I: Containers & Kubernetes" \
    INSTRUCTOR='Vicente Jimenez' 

# ARG defines environment variables during the build
ARG OS_VERSION_FILE=/var/www/html/version.html 

# This is a script coded in base64
ARG WELCOME_SCRIPT=\
ZWNobyAtZSAiV2VsY29t\
ZSB0byBDb3Vyc2UgJHtD\
T1VSU0VfQ09ERX06ICR7\
Q09VUlNFX1RJVExFfSBc\
blxuWW91ciBJbnN0cnVj\
dG9yIGlzICR7SU5TVFJV\
Q1RPUn1cbiIK

# ADD copies (or downloads a file from a URL) and unpacks the content
ADD  app.tgz /var/www/html/

# COPY simply copies a local file to a specified path
COPY  data.tar /var/www/html/

# or here copies the content of the data_dir directory
#   into /var/www/html/copy_dir/
COPY  data_dir /var/www/html/copy_dir/

# Entrypoint script and Dockerfile for future reference
ADD container-entrypoint /usr/local/bin/
ADD Dockerfile /root/

# Some examples of how to run several commands in one single line
RUN echo "This is a Dockerfile demo for ${COURSE_CODE} course" \
    > /var/www/html/index.html \
    && eval $( echo "${WELCOME_SCRIPT}" | base64 -d ) \
     > /var/www/html/welcome.html \
    && ( cat /etc/redhat-release || \
         echo "Debian $(cat /etc/debian_version)" ) > ${OS_VERSION_FILE} 

# Fixing some permissions here
RUN  chgrp -R 0 /var/www/html /run/httpd /var/log/httpd \
                /usr/local/bin/container-entrypoint  && \
     chmod -R g=u /run/httpd /var/log/httpd && \
     chmod  g+x,a-w /usr/local/bin/container-entrypoint
    
# The first label will be releveant for OpenShift. The second isn't
LABEL io.openshift.expose-services=8080 \
      io.openshift.instructor='Vicente Jimenez <vjjmiras@redhat.com>'

EXPOSE 8080

# Container should run without special permissions
USER 1001

ENTRYPOINT ["/usr/local/bin/container-entrypoint"]
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]
