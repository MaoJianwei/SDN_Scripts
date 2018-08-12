
while true
do

    while (( 2 < $(date +%H) && $(date +%H) < 7 )) 
    do
        echo $(date +%H)
        sleep 10
    done

    curl -v --header "X-Requested-With: XMLHttpRequest" --cookie "cookie-from-browser-debugger" -d "query-data-from-browser-debugger" https://bbs.byr.cn/article/JobInfo/ajax_post.json
    sleep 1200
done
