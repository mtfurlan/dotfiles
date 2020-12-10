#!/bin/bash

if [[ $EUID != 0 ]] ; then
  echo This must be run as root!
  exit 1
fi

echo "please find your version of this:"
echo "74.125.206.108 smtp --port=465 --auth-login --ssl --user=yourSendingEmail@domain.tld --pass=iWonderIfQuotesWorkForSpaces --insecure"

while read -r -t 0; do read -r; done #flush stdin
read -p "enter it: " remotes

while read -r -t 0; do read -r; done #flush stdin
read -p "where to send test email: " email

echo "remotes: $remotes"
echo "email: $email"

read -r -p "continue? [Y/n] " response
case "$response" in
  [yY][eE][sS]|[yY])
    #do nothing
    ;;
  *)
    echo "not continuing"
    exit 1
    ;;
esac


tee /etc/systemd/system/nullmailer-mount.service >/dev/null <<EOF
[Unit]
Description=Mount tempfs in /var/spool/nullmailer/

[Service]
Type=oneshot
ExecStart=mkdir /var/spool/nullmailer/tmp
ExecStart=mkdir /var/spool/nullmailer/queue
ExecStart=chown -R mail:root /var/spool/nullmailer/
ExecStart=chmod 755 /var/spool/nullmailer/
ExecStart=chmod 750 /var/spool/nullmailer/queue/
ExecStart=chmod 750 /var/spool/nullmailer/tmp/

[Install]
WantedBy=nullmailer.service
EOF

if ! grep nullmailer /etc/fstab>/dev/null ; then
  sudo tee -a /etc/fstab >/dev/null <<FSTAB
tmpfs /var/spool/nullmailer tmpfs nodev,nosuid,noexec,nodiratime,size=5M   0 0
FSTAB
fi

mkdir /var/spool/nullmailer
mount -a


# if nullmailer is already installed, reconfigure it
# the tmpfs broke it's trigger file if it was already installed
if dpkg -l nullmailer >/dev/null 2>&1; then
  dpkg --reconfigure nullmailer
else
  apt-get install nullmailer mailutils -y
fi
systemctl enable nullmailer-mount.service

echo "$remotes" > /etc/nullmailer/remotes

systemctl restart nullmailer

echo "testing" | NULLMAILER_NAME="Nullmailer Setup Script" mail -s "test email" "$email"
