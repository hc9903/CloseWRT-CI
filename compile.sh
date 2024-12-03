#!/bin/bash

export WRT_TARGET=MTK-7986

export WRT_THEME=argon

export WRT_NAME=CWRT

export WRT_WIFI=CWRT

export WRT_IP=192.168.6.1

export WRT_PW=无

export WRT_REPO=https://github.com/padavanonly/immortalwrt-mt798x-23.05.git

export WRT_BRANCH=openwrt-23.05

export WRT_TEST=false

export GITHUB_WORKSPACE=$PWD

export WRT_DATE=$(TZ=UTC-8 date +"%y.%m.%d_%H.%M.%S")

export WRT_CI=$(basename $GITHUB_WORKSPACE)

export WRT_VER=$(echo $WRT_REPO | cut -d '/' -f 4)-$WRT_BRANCH

export WRT_TYPE=$(sed -n "1{s/^#//;s/\r$//;p;q}" $GITHUB_WORKSPACE/Config/$WRT_TARGET.txt)

git clone --depth=1 --single-branch --branch $WRT_BRANCH $WRT_REPO ./wrt/

cd ./wrt/
export WRT_HASH=$(git log -1 --pretty=format:'%h')


cd ..
find ./ -maxdepth 3 -type f -iregex ".*\(txt\|sh\)$" -exec dos2unix {} \; -exec chmod +x {} \;

cd ./wrt/
./scripts/feeds update -a
./scripts/feeds install -a


cd ./package/
$GITHUB_WORKSPACE/Scripts/Packages.sh
$GITHUB_WORKSPACE/Scripts/Handles.sh


cd ../

rm -rf ./tmp* ./.config*
cat $GITHUB_WORKSPACE/Config/$WRT_TARGET.txt $GITHUB_WORKSPACE/Config/GENERAL.txt >> .config
$GITHUB_WORKSPACE/Scripts/Settings.sh
make defconfig -j$(nproc)

make download -j$(nproc)

make -j$(nproc) || make -j1 V=s
