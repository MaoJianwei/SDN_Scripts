
LOG=/home/mao/mao_kernel_build.html

if [ "$(whoami)" != "root" ]
then
    echo "Mao: we need root privilege to compile & install Linux Kernel."
    echo "Mao: we need root privilege to compile & install Linux Kernel." > ${LOG}
    exit 1
fi

CORES=`cat /proc/cpuinfo | grep "processor" | wc -l`

BUILD_TIME=`date`
echo "============================== Mao Kernel Build - ${BUILD_TIME} =============================="
echo "============================== Mao Kernel Build - ${BUILD_TIME} ==============================" > ${LOG}

echo "============================== Mao Kernel Build - menuconfig  =============================="
echo "============================== Mao Kernel Build - menuconfig  ==============================" >> ${LOG}
make menuconfig

echo "============================== Mao Kernel Build - make -j${CORES}  =============================="
echo "============================== Mao Kernel Build - make -j${CORES}  ==============================" >> ${LOG}
make -j${CORES} >> ${LOG}

echo "============================== Mao Kernel Build - make modules_install  =============================="
echo "============================== Mao Kernel Build - make modules_install  ==============================" >> ${LOG}
make modules_install >> ${LOG}

echo "============================== Mao Kernel Build - make headers_install INSTALL_HDR_PATH=/usr  =============================="
echo "============================== Mao Kernel Build - make headers_install INSTALL_HDR_PATH=/usr  ==============================" >> ${LOG}
make headers_install INSTALL_HDR_PATH=/usr >> ${LOG}

echo "============================== Mao Kernel Build - menuconfig  =============================="
echo "============================== Mao Kernel Build - menuconfig  ==============================" >> ${LOG}
make install >> ${LOG}

FINISH_TIME=`date`
echo "============================== Mao Kernel Build - Done - $BUILD_TIME -> ${FINISH_TIME} =============================="
echo "============================== Mao Kernel Build - Done - $BUILD_TIME -> ${FINISH_TIME} ==============================" >> ${LOG}
