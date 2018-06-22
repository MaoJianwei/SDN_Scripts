site="campus"

while true
do
initHtml=$(curl -s http://"pi-"${site}".maojianwei.com"/monitor.html)
cpuHtml=${initHtml#*CPU_Temp=}
cpuHtml=${cpuHtml%%</br>*}
gpuHtml=${initHtml#*GPU_Temp=}
gpuHtml=${gpuHtml%%</br>*}

DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M:%S")

echo ${DATE}"_"${TIME}","${cpuHtml}","${gpuHtml} >> /home/mao/station_monitor/${site}_${DATE}.csv
echo ${DATE}"_"${TIME}","${cpuHtml}","${gpuHtml} >> /home/mao/NFS/station_monitor/${site}_${DATE}.csv
sleep 1
done
