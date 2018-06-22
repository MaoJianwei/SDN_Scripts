
######
# modify sudo password field & nasIp
######

echo "password" | sudo -S mount -t nfs nasIP:/volume1/NFSshare /home/mao/NFS

exec 3<>/dev/tcp/flight.maojianwei.com/33333

while read -u 3 oneMsg
do
    DATE=$(date +"%Y-%m-%d")

    echo $oneMsg >> /home/mao/NFS/ADSB_Database/flight.maojianwei.com_${DATE}.csv
done
