#!/bin/sh
#pkg签名
echo "pkg开始签名"
productsign --sign 3C08C00A7B33A10645E6DDC2299A7D54C56 ./Mac.pkg ./Mac_sign.pkg
echo "pkg开始签名结束"

NOTRAIZED_FILE="./Mac_sign.pkg"
USERNAME="appid" #苹果z开发者账号
PASSWORD="xznq-jivl-glrx" #苹果网站生成的专用密码
BUNDLE_ID="com.my.mac.pkg" # 自定义
PROVIDER="K8MXV5"
BUIDL_LOG="notarized.txt"
UUID=""

echo "###### start notarized ${NOTRAIZED_FILE} ... ######"
xcrun altool --notarize-app \
             --primary-bundle-id "${BUNDLE_ID}" \
             --username "${USERNAME}" \
             --password "${PASSWORD}" \
             --asc-provider "${PROVIDER}" \
             --file "${NOTRAIZED_FILE}" &> "${BUIDL_LOG}"
# get success uuid
# RequestUUID =
UUID=`cat ${BUIDL_LOG} | grep -Eo 'RequestUUID = [[:alnum:]]{8}-([[:alnum:]]{4}-){3}[[:alnum:]]{12}' | grep -Eo '[[:alnum:]]{8}-([[:alnum:]]{4}-){3}[[:alnum:]]{12}' | sed -n "1p"`

# if file unable upload or upload failed exit
if [[ "$UUID" == "" ]]; then
  echo "###### No success no uploaded, unknown error ######"
  cat ${BUIDL_LOG}  | awk 'END {print}'
  exit
fi
echo "###### notarization UUID is $UUID ######"

sleep 120

#search notarized result
while true; do
  echo "###### checking for notarization... ######"
  xcrun altool --notarization-info "${UUID}" \
               -u "${USERNAME}" \
               -p "${PASSWORD}" &> "${BUIDL_LOG}"
  r=`cat ${BUIDL_LOG}`
  t=`echo "$r" | grep "success"`
  f=`echo "$r" | grep "invalid"`
  if [[ "$t" != "" ]]; then
      echo "###### notarization done! ######"
      xcrun stapler staple "${NOTRAIZED_FILE}"
      echo "###### stapler done! ######"
      break
  fi
  if [[ "$f" != "" ]]; then
      echo "###### Failed : $r ######"
      exit
  fi
  echo  "###### please waiting, sleep 1min then check again... ######"
  sleep 60
done
exit
