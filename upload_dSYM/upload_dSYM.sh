#!/bin/sh

# 命令行上传dSYM.zip到腾讯Bugly后台
# 使用方法  ./upload.sh  /Users/mac/Documents/EasyFuture/fastlane/release_ipa/EasyFuture.app.dSYM.zip

BUGLY_DSYM_UPLOAD_DOMAIN="api.bugly.qq.com"  # Bugly服务域名
BUNDLE_IDENTIFIER="com.yifu.EasyFuture"
BUGLY_APP_VERSION="3.0.0"
P_APP_ID="020e6a6edd"
P_APP_KEY="c7a1b67b-43d2-46ee-9ad7-c38f23765490"
P_BSYMBOL_ZIP_FILE_NAME="EasyFuture.app.dSYM.zip"
P_BSYMBOL_ZIP_FILE_PATH="$1"


if [ -e $P_BSYMBOL_ZIP_FILE_PATH ]
then
    echo "该文件存在"
else
    echo "该文件不存在" && exit
fi


echo "-----开始上传-------"

DSYM_UPLOAD_URL="https://${BUGLY_DSYM_UPLOAD_DOMAIN}/openapi/file/upload/symbol?app_id=${P_APP_ID}&app_key=${P_APP_KEY}"

echo "dSYM upload url: ${DSYM_UPLOAD_URL}"

echo "-----------------------------"
STATUS=$(/usr/bin/curl -k "${DSYM_UPLOAD_URL}" --form "api_version=1" --form "app_id=${P_APP_ID}" --form "app_key=${P_APP_KEY}" --form "symbolType=2"  --form "bundleId=${BUNDLE_IDENTIFIER}" --form "productVersion=${BUGLY_APP_VERSION}" --form "fileName=${P_BSYMBOL_ZIP_FILE_NAME}" --form "file=@${P_BSYMBOL_ZIP_FILE_PATH}" --verbose)
echo "-----------------------------"

echo "Bugly server response: ${STATUS}"


echo "-----处理上传-------"

