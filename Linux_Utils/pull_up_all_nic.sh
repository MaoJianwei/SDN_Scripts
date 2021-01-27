for i in `cat /proc/net/dev | awk '{print $1}' | sed '1,2d' | sed -n '/^e/p' | sed 's/://'`
do
    echo "Pull up ${i} ..."
    ip link set ${i} up
done
