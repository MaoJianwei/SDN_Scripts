#include <iostream>
#include <sys/socket.h>
#include <netinet/if_ether.h>
#include <netinet/in.h>
#include <cstring>
#include <linux/if_packet.h>
//#include <linux/if.h>
#include <net/if.h>
#include <thread>


using namespace std;

int main(int argc, char *argv[]) {

    ios::sync_with_stdio(false);
    std::cin.tie(0);


    // construct socket.
    int sockFd = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
    if (sockFd < 0) {
        cout << "fail." << sockFd << ", " << errno << endl;
        return -1;
    } else {
        cout << "success!" << endl;
    }

    int rcvbuf = 0;
    cout << setsockopt(sockFd, SOL_SOCKET, SO_RCVBUF, &rcvbuf, sizeof(rcvbuf)) << endl;


    // get device name.
    const char * deviceName;
    if (argc > 1) {
        deviceName = argv[1];
    } else {
        deviceName = "lo";
    }
    size_t deviceLen = strnlen(deviceName, IFNAMSIZ);
    if (deviceLen >= IFNAMSIZ) {
        cout << "dev name too long." << endl;
        return -1;
    }
    cout << deviceName << " " << deviceLen << endl;


    // bind device
    struct sockaddr_ll device = {0,};
    device.sll_family = AF_PACKET;
    device.sll_ifindex = if_nametoindex(deviceName);
    device.sll_protocol = htons(ETH_P_ALL);
    int ret = bind(sockFd, (struct sockaddr*)&device, sizeof(device));
    if (ret != 0)
    {
        cout << "bind fail." << endl;
        return 0;
    }


    cout << "Start..." << endl;

    while (1) {
        printf("============================\n");

        unsigned char recvBuf[2000] = {0,};
        sockaddr addr;
        socklen_t socklen;
        ssize_t size = recvfrom(sockFd, recvBuf, 2000, 0, &addr, &socklen);

        unsigned char dstMac[6];
        unsigned char srcMac[6];
        unsigned short etherType;
        memcpy(dstMac, recvBuf, 6);
        memcpy(srcMac, recvBuf+6, 6);
        memcpy(&etherType, recvBuf+12, 2);
        etherType = ntohs(etherType);
        printf("DstMac=%.2x:%.2x:%.2x:%.2x:%.2x:%.2x SrcMac=%.2x:%.2x:%.2x:%.2x:%.2x:%.2x Ethertype=%#.4x\n",
               dstMac[0], dstMac[1], dstMac[2], dstMac[3], dstMac[4], dstMac[5],
               srcMac[0], srcMac[1], srcMac[2], srcMac[3], srcMac[4], srcMac[5],
               etherType);

        if (etherType != 0x0800)
            continue;

        unsigned char srcIp[4];
        unsigned char dstIp[4];
        unsigned char ipproto;
        memcpy(srcIp, recvBuf+14+12, 4);
        memcpy(dstIp, recvBuf+14+16, 4);
        memcpy(&ipproto, recvBuf+14+9, 1);
        printf("SrcIp=%u.%u.%u.%u DstIp=%u.%u.%u.%u IpProto=%d\n",
               srcIp[0], srcIp[1], srcIp[2], srcIp[3],
               dstIp[0], dstIp[1], dstIp[2], dstIp[3],
               ipproto);

        if (ipproto != 17 && ipproto != 6)
            continue;

        unsigned short srcPort;
        unsigned short dstPort;
        memcpy(&srcPort, recvBuf+14+20, 2);
        memcpy(&dstPort, recvBuf+14+20+2, 2);
        srcPort = ntohs(srcPort);
        dstPort = ntohs(dstPort);
        printf("SrcPort=%u DstPort=%u\n", srcPort, dstPort);

    }
    return 0;
}
