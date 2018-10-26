#!/bin/sh

# 操作列表
# git add .
# git commit -m '更新信息'
# git push  或者 git push origin master
#  git tag 0.1.0
# git tag push --tags
#本地验证
# pod lib lint
#远程验证
# pod spec lint
#远程私有库验证
#pod spec lint --private
#推送到本地搜索库
#pod repo push localSpec MyLib.podspec




#使用方法 ./upload.sh 更新信息 tag值 podspec文件名

message=${1}
tag=${2}
podspecName=${3}

method="使用方法：./upload.sh 更新信息 tag值 podspec文件名"

if [ ${#podspecName} -eq 0 ]
then
    echo "参数不合法 - $method" & exit
fi

git add .

git commit -m "${message}"

git push origin master

git tag $tag 2> error.sh
error=$(cat ./error.sh)
if [ ${#error} -ne 0 ]  #不等于零说明有错误
then
    echo $error
    #删除本地tag
    git tag -d $tag
    #删除远端tag
    git push origin :refs/tags/$tag
fi

git tag $tag
git push --tags

#本地验证库信息  --verbose
pod lib lint --allow-warnings

#验证远端信息
pod spec lint --private

#推送到私有库
pod repo push localSpec MyLib.podspec
