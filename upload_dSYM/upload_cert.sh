#!/bin/bash

:<<EOF
免费SSL证书配置流程(用于配置企业包自动升级)
1、证书申请 https://www.sslforfree.com/
2、点击Create Free SSL Certificate
3、点击Manual Verification
4、点击Manually Verify Domain
5、点击Download File 下载文件
    将下载的文件存放到/home/.well-known/acme-challenge/
    nginx配置：/etc/nginx/conf.d/http.*.domain
    location /.well-known/acme-challenge/ {
        root /home/;
    }
6、点击Download SSL Certificate
7、校验
http://yourdomain/.well-known/acme-challenge/GR8aZlkqRowLN6zc4BYnkTTEzBpmz_tKGkqNFbgXp9w
也可根据该网站提示处理

下面代码自动将需要的文件上传到服务器
主要处理上传第5、6步骤中的文件，必须按照上面一步一步的完成

特别说明：该网站上面，第五步完成了，才能下载第六步的证书

EOF

# 使用方法 ./upload_cert.sh 172.16.1.66 uploadConfig
# uploadConfig 上传第五步的文件
# uploadSSL 上传证书

paramCount=$#
UPLOAD_SSL="uploadSSL"
UPLOAD_CONFIG="uploadConfig"

if [ $paramCount -ne 2 ]
then
    echo "请输入正确的参数如：${0} serverIP uploadSSL 或者 ${0} serverIP uploadConfig" && exit
fi

if [ ! -z ${1} ]
then
    serverIP=${1} && echo "serverIP = ${serverIP}"
fi

function uploadConfig() {
    challengePath="/home/.well-known/acme-challenge/"
    filePath="./file"
    if [ ! -e $filePath ]
    then
    mkdir file && echo "请将第五步下载的文件拷贝到file目录下" && exit
    fi

    serverPath="root@${serverIP}:${challengePath}"
    localPath="`pwd`/file/*"
    scp ${localPath} ${serverPath}
}


function uploadSSL() {
    #if [ "`ls -A $filePath`" = "" ]
    #then
    #    echo "将下载的文件拷贝到${filePath}目录下"
    #fi

    #sslforfree 下载的证书文件 通常下载在Downloads目录
    sslforfreeName="sslforfree.zip"
    sslforfreePath="/Users/$(whoami)/Downloads/${sslforfreeName}"

    if [ -e ${sslforfreePath} ]
    then
    cp ${sslforfreePath} "./${sslforfreeName}" && unzip "./${sslforfreeName}"
    else
    echo "${sslforfreePath} 不存在"
    #    echo "sslforfree目录不存在，将第七步下载的sslforfree解压到当前文件夹" && exit
    fi

    echo "开始处理数据。。。"

    mkdir cert
    cp "./sslforfree/private.key" "./cert/dmail.key"
    cp "./sslforfree/certificate.crt" "./cert/dmail.cert"
    cp "./sslforfree/ca_bundle.crt" "./cert/cacert.cert"

    echo >> "./cert/dmail.cert"
    cat "./cert/cacert.cert" >> "./cert/dmail.cert"

    echo "开始上传文件 serverIP = ${serverIP}。。。"

    serverPath="root@${serverIP}:/etc/certs/"
    sslforfreePath="./cert/*"
    scp ${sslforfreePath} ${serverPath}
}

# 第五步的操作
if [ ${2} = ${UPLOAD_CONFIG} ]
then
    echo "上传第五步文件"
    uploadConfig
else
    echo "上传第7步证书"
    uploadSSL
fi


