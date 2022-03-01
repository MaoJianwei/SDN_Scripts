nano /etc/systemd/system/docker.service.d/http-proxy.conf

[Service]
Environment="HTTP_PROXY=http://ip:port/"
Environment="HTTPS_PROXY=http://ip:port/"
Environment="NO_PROXY=127.*,10.*,192.*,localhost,.your-domain.com"

systemctl daemon-reload
systemctl restart docker.service
