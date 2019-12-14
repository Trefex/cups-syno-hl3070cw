FROM centos:centos7

RUN yum install epel-release -y
RUN yum update -y
RUN yum -y install cups cups-client cups-libs cups-pdf ghostscript-cups \ 
    cups-filters cups-filters-libs cups-filesystem \ 
    python-cups
RUN yum -y install libstdc++.i686 glibc.i686 policycoreutils-python wget inotify inotify-tools
RUN wget -T 10 -nd --no-cache http://www.brother.com/pub/bsc/linux/packages/hl3070cwlpr-1.1.2-1.i386.rpm
RUN wget -T 10 -nd --no-cache http://www.brother.com/pub/bsc/linux/packages/hl3070cwcupswrapper-1.1.2-2.i386.rpm
RUN rpm -ihv --nodeps --replacefiles --replacepkgs hl3070cwlpr-1.1.2-1.i386.rpm
RUN rpm -ihv --nodeps --replacefiles --replacepkgs hl3070cwcupswrapper-1.1.2-2.i386.rpm

# Cleanup
RUN rm -rf hl3070cwlpr-1.1.2-1.i386.rpm hl3070cwcupswrapper-1.1.2-2.i386.rpm

RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
        sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
        sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
        sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
        sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
        echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
        echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

RUN sed -i '/SystemGroup sys root$/ s/$/ wheel/' /etc/cups/cups-files.conf

# Add scripts
ADD root /
RUN chmod +x /root/*
CMD ["/root/run_cups.sh"]

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services

