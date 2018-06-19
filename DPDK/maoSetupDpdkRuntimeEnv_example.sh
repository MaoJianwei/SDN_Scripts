cd dpdk-stable-17.11.1

echo -e "\n------ remove ens224, ens256 from Linux ifconfig ------\n"
echo 123 | sudo -S ifconfig ens192 0
echo 123 | sudo -S ifconfig ens224 0

echo -e "\n------ install uio, igb_uio driver ------\n"
echo 123 | sudo -S modprobe uio
echo 123 | sudo -S insmod ./x86_64-native-linuxapp-gcc/kmod/igb_uio.ko
#echo 123 | sudo -S modprobe vfio-pci

echo -e "\n------ unbind ens224, ens256 from other drivers ------\n"
echo 123 | sudo -S ./usertools/dpdk-devbind.py -u 0000:0b:00.0
echo 123 | sudo -S ./usertools/dpdk-devbind.py -u 0000:13:00.0

echo -e "\n------ bind ens224, ens256 to igb_uio driver ------\n"
echo 123 | sudo -S ./usertools/dpdk-devbind.py --bind=igb_uio 0000:0b:00.0
echo 123 | sudo -S ./usertools/dpdk-devbind.py --bind=igb_uio 0000:13:00.0

echo -e "\n------ setup HugePages ------\n"
echo 123 | sudo -S chmod 777 /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
echo 123 | sudo -S chmod 777 /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
echo 123 | sudo -S echo 2 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
echo 123 | sudo -S echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

echo -e "\n------ mount HugePages ------\n"
echo 123 | sudo -S mkdir /mnt/huge
echo 123 | sudo -S mkdir /mnt/huge1G
echo 123 | sudo -S mount -t hugetlbfs nodev /mnt/huge/
echo 123 | sudo -S mount -t hugetlbfs -o pagesize=1G nodev /mnt/huge1G/

echo -e "\n------ check NIC DPDK Binding ------\n"
echo 123 | sudo -S ./usertools/dpdk-devbind.py --status
