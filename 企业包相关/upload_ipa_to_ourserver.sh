#!/bin/bash
serverPath="root@serverIP:/home/nginx/webroot/webclient/download/iOS/"
localPath="`pwd`/build/your.*" #包含ipa 和 plist文件
scp ${localPath} ${serverPath}
