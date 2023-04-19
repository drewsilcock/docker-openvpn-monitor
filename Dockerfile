FROM python:3.10

ARG UPSTREAM_VERSION
ARG MAXMIND_LICENSE_KEY

RUN wget https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 \
  && mv confd-0.16.0-linux-amd64 /usr/bin/confd \
  && chmod +x /usr/bin/confd

RUN pip install gunicorn \
  && mkdir /openvpn-monitor \
  && wget -O - https://github.com/drewsilcock/openvpn-monitor/archive/${UPSTREAM_VERSION}.tar.gz | tar -C /openvpn-monitor --strip-components=1 -zxvf - \
  && cp /openvpn-monitor/openvpn-monitor.conf.example /openvpn-monitor/openvpn-monitor.conf \
  && pip install /openvpn-monitor \
  && mkdir -p /var/lib/GeoIP/ \
  && wget -O - "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=$MAXMIND_LICENSE_KEY&suffix=tar.gz" | tar -C /var/lib/GeoIP/ --strip-components=1 -zxvf -

COPY confd /etc/confd
COPY entrypoint.sh /

WORKDIR /openvpn-monitor

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]

CMD ["gunicorn", "openvpn-monitor", "--bind", "0.0.0.0:8000"]
