#ps -ef | grep MacService | grep -v grep | wc -l
result=`ps -ef | grep MacService | grep -v grep | wc -l`
#echo "result=$result"
if [ $result -eq 0 ]
then
    current=`date "+%Y-%m-%d %H:%M:%S"`
    echo "server not start"
    #启动服务
    sudo launchctl start com.my.macservice
    echo "server start end time = $current"
fi
