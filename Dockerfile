FROM ubuntu:12.04
MAINTAINER "Christian Kniep <christian@qnib.org>"

RUN echo "2014-10-02.1";apt-get update

## cluser
RUN mkdir -p /chome
RUN useradd -u 2000 -M -d /chome/cluser cluser
RUN echo "cluser:cluser"|chpasswd
## basic install
RUN apt-get install -y vim gnuplot
## SSHD
RUN apt-get install -y openssh-server xauth
RUN sed -i -e 's/#X11UseLocalhost.*/X11UseLocalhost no/' /etc/ssh/sshd_config
RUN mkdir -p /var/run/sshd
# ROOT
RUN echo "root:root" | chpasswd
USER root
ENV HOME /root
ADD ssh /tmp/ssh/
RUN if [ -f /tmp/ssh/*.pub ];then mkdir -p /root/.ssh; cat /tmp/ssh/*.pub >> /root/.ssh/authorized_keys;chmod 600 /root/.ssh/authorized_keys;chmod 700 /root/.ssh;fi

## SUPERVISOR
RUN apt-get install -y supervisor
ADD etc/supervisord.d /etc/supervisord.d
ADD etc/supervisord.conf /etc/supervisord.conf

## create a compute node (slurm)
RUN apt-get install -y slurm-llnl


RUN apt-get install -y curl
RUN echo "deb http://ppa.launchpad.net/narayan-desai/infiniband/ubuntu precise main " >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F583E9CA3A95A7BADF2B33278F491D5599E66448
RUN apt-get update
RUN apt-get install -y libibcommon1 libibumad1 libibumad1 infiniband-diags openmpi1.5-bin


CMD supervisord -c /etc/supervisord.conf

