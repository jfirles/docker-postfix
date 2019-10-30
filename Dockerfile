FROM debian:buster
MAINTAINER Jose Fco. Irles <jfirles@siptize.com>
LABEL maintainer="jfirles@siptize.com"
LABEL "com.siptize.vendor"="Siptize S.L."
LABEL "com.siptize.project"="common"
LABEL "com.siptize.app"="postfix"
LABEL "com.siptize.version"="1.0.1"
LABEL version="1.0.1"

## zona horaria
RUN echo "Europe/Madrid" > /etc/timezone
RUN rm /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Madrid /etc/localtime

## actualizamos e instalamos lo basico
RUN apt-get update && apt-get dist-upgrade -y && apt-get install postfix locales rsyslog supervisor procps -y

## Locales
RUN echo "LANG=es_ES.UTF-8" > /etc/default/locale && echo "LC_MESSAGES=POSIX" >> /etc/default/locale \
 && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen \
 && /usr/sbin/locale-gen

## Añadimos el entrypoint
ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 25

ENTRYPOINT ["docker-entrypoint.sh"]
#CMD ["/bin/bash"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
