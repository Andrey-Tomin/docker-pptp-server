#!/bin/bash

# Остановить pptpd перед изменениями
sudo systemctl stop pptpd

# Отключить debug в pptpd.conf
sudo sed -i '/^debug/d' /etc/pptpd.conf
sudo sed -i '/^logwtmp/d' /etc/pptpd.conf

# Отключить debug в ppp/options
sudo sed -i '/^debug/d' /etc/ppp/options

# Настроить systemd для перенаправления вывода в null
sudo mkdir -p /etc/systemd/system/pptpd.service.d
cat <<EOL | sudo tee /etc/systemd/system/pptpd.service.d/override.conf
[Service]
StandardOutput=null
StandardError=null
EOL

# Настроить rsyslog для игнорирования pptpd
cat <<EOL | sudo tee /etc/rsyslog.d/ignore-pptpd.conf
:programname, isequal, "pptpd" stop
EOL

# Перезапустить rsyslog
sudo systemctl restart rsyslog

# Удалить ротацию логов pptpd, если она есть
if [ -f /etc/logrotate.d/pptpd ]; then
  sudo rm /etc/logrotate.d/pptpd
fi

# Перезагрузить systemd и перезапустить pptpd
sudo systemctl daemon-reload
sudo systemctl start pptpd

echo "Все логи pptpd отключены."