#!/bin/sh

if [ $UID -ne 0 ]; then
   echo "Please start the script as root or sudo!"
   exit 1;
fi

if [ ! -f /Library/LaunchDaemons/autosetproxy.plist ]; then
   cat >/Library/LaunchDaemons/autosetproxy.plist <<END
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>autosetproxy</string>
  <key>ProgramArguments</key>
  <array>
  <string>/usr/bin/autosetproxy</string>
  </array>
  <key>Nice</key>
  <integer>1</integer>
  <key>StartInterval</key>
  <integer>60</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardErrorPath</key>
  <string>/tmp/autosetproxy.err</string>
  <key>StandardOutPath</key>
  <string>/tmp/autosetproxy.out</string>
</dict>
</plist>
END

   launchctl load /Library/LaunchDaemons/autosetproxy.plist

   cat ./autosetproxy >/usr/bin/autosetproxy
   chmod +x /usr/bin/autosetproxy

   echo "Install... Done!"
   exit 0
fi

if [ "$1" = "-uninstall" ]; then
   launchctl unload /Library/LaunchDaemons/autosetproxy.plist
   rm -f /usr/bin/autosetproxy /Library/LaunchDaemons/autosetproxy.plist
   echo "Uninstall... Done!"
   exit 0
fi

echo "Starting..."

IFACE=en1
ISERV=Wi-Fi
IPADDR=192.168.1.1

PSTATE="setwebproxystate setsecurewebproxystate setftpproxystate setstreamingproxystate setgopherproxystate setsocksfirewallproxystate"

COUNTON=0
COUNTOFF=0

while :; do 

   if (echo "show State:/Network/Global/IPv4" | scutil | grep Router | cut -d' ' -f5) | grep -q $IPADDR; then

      if [ $COUNTON -eq 0 ]; then
         echo "$ISERV: Turning on proxy..."

         for I in $PSTATE; do
            networksetup -$I $ISERV on;
         done

      echo "Done!"
      fi

      COUNTON=1
      COUNTOFF=0

   else
   
      if [ $COUNTOFF -eq 0 ]; then
         echo "$ISERV: Turning off proxy..."

         for I in $PSTATE; do
            networksetup -$I $ISERV off;
         done

      echo "Done!"
      fi

      COUNTON=0
      COUNTOFF=1

   fi

   sleep 2;

done
