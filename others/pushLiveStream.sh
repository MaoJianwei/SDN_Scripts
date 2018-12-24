
# Infinitely loop:   -stream_loop -1
# Not use -re, because of easily blurred screen

video_src=""
video_src_port=""

live_addr="" # e.g.  rtmp://send1a.douyu.com/live , copy from your live platform
live_push_code="" # copy from your live platform too

count=0
while true
do
    # add -re for continuity, when use media file as input
    ffmpeg -stream_loop -1 -i "rtsp://${video_src}:${video_src_port}/" -acodec copy -vcodec copy -f flv -y "${live_addr}/${live_push_code}"
    ((count++))
    echo ""
    echo "--- Mao retry ... $count ---"
    echo ""
    sleep 1
done
