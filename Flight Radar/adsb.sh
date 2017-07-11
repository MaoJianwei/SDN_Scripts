# cat<&6 > /home/mao/adsb2.txt &
# cat<&6 | grep 780C7A
# cat <&6


if [[ $# < 1 ]]
then
    echo "Usage:"
    echo "1. Intercept Flight:  adsb.sh <Callsign>"
    echo "2. Intercept ICAO:    adsb.sh -i <ICAO>"
    echo "3. Intercept All:     adsb.sh -a"
    echo "press <enter> to stop output and exit"
    exit 1
fi


NETWORK="/dev/tcp/flight.maojianwei.com/33333"


function interceptALL() {
    exec 8<>$NETWORK
    cat<&8 &
    SHOW_ALL_PID=$!

    read
    kill $SHOW_ALL_PID
}

function interceptICAO() {
    ICAO=$1
    exec 6<>$NETWORK
    cat<&6 | grep $ICAO &
    INTERCEPT_PID=`expr $! - 1`

    read
    kill $INTERCEPT_PID
}


function interceptFlight() {
    TARGET=$1
    Callsign=""
    ICAO=""

    exec 6<>$NETWORK

    while read -u 6 msg
    do
        Callsign=$(echo $msg | cut -d ',' -f 11)

        if [[ $Callsign = $TARGET ]]
        then
            ICAO=$(echo $msg | cut -d ',' -f 5)

            echo "----------------------------------------"
            echo "   Callsign: $Callsign   ICAO: $ICAO    "
            echo "----------------------------------------"
            break;
        fi
    done


    DATETIME=$(date "+%Y-%m-%d-%H-%M-%S")
    exec 8<>$NETWORK
    cat<&8 | grep $ICAO > /home/mao/$1.$DATETIME.flight &
    FILE_RECORD_PID=`expr $! - 1`


    cat<&6 | grep $ICAO &
    SHOW_RECORD_PID=`expr $! - 1`


    read
    kill $FILE_RECORD_PID $SHOW_RECORD_PID


    echo "----------------------------------------"
    echo "   Callsign: $Callsign   ICAO: $ICAO"
    echo "----------------------------------------"
}

function cleanNetwork() {
    for cat_pid in $(ps -e | grep pts | grep cat | awk '{print $1}')
    do
        kill $cat_pid
    done
}

case $1 in
    -a|-A|--all|--ALL)
        interceptALL
    ;;
    -c|-C|--clean|--CLEAN)
        cleanNetwork
    ;;
    -i|-I|--icao|--ICAO)
        interceptICAO $2
    ;;
    *)
        interceptFlight $1
    ;;
esac

exit 0
