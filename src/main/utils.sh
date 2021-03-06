#!/usr/bin/env bash

# shell utilities

function build() {
    VERSION_DATA=`cat ${GOPATH}/src/github.com/TeaWeb/code/teaconst/const.go`
    VERSION_DATA=${VERSION_DATA#*"Version = \""}
    VERSION=${VERSION_DATA%%[!0-9.]*}
    TARGET=${GOPATH}/dist/teaweb-v${VERSION}
    EXT=""
    if [ ${GOOS} = "windows" ]
    then
        EXT=".exe"
    fi

    echo "[================ building ${GOOS}/${GOARCH}/v${VERSION}] ================]"

    echo "[create target directory]"

    if [ -d ${TARGET} ]
    then
        rm -rf ${TARGET}
    fi

    mkdir ${TARGET}
    mkdir ${TARGET}/bin
    mkdir ${TARGET}/plugins
    mkdir ${TARGET}/tmp
    mkdir ${TARGET}/configs

    echo "[build static file]"

    # remove plus
    if [ -f ${GOPATH}/src/github.com/TeaWeb/code/teaweb/plus.go ]
    then
        rm -f ${GOPATH}/src/github.com/TeaWeb/code/teaweb/plus.go
    fi

    # build main & plugin
    go build -o ${TARGET}/bin/teaweb${EXT} ${GOPATH}/src/github.com/TeaWeb/code/main/main.go

    if [ -d ${GOPATH}/src/github.com/TeaWeb/jsapps ]
    then
        go build -o ${TARGET}/plugins/jsapps.tea${EXT} ${GOPATH}/src/github.com/TeaWeb/jsapps/main/plugin.go
        cp ${GOPATH}/src/github.com/TeaWeb/jsapps/main/jsapps.js ${TARGET}/configs/jsapps.js
        cp ${GOPATH}/src/main/plugins/jsapps.js ${TARGET}/plugins/jsapps.js
    fi

    # restore plus
    if [ -f ${GOPATH}/drafts/src/plus.go ]
    then
        cp ${GOPATH}/drafts/src/plus.go ${GOPATH}/src/github.com/TeaWeb/code/teaweb/plus.go
    fi

    echo "[copy files]"
    cp -R ${GOPATH}/src/main/configs/admin.sample.conf ${TARGET}/configs/admin.conf
    cp -R ${GOPATH}/src/main/configs/server.prod.conf ${TARGET}/configs/server.conf
    cp -R ${GOPATH}/src/main/configs/mongo.conf ${TARGET}/configs/
    cp -R ${GOPATH}/src/main/configs/server.conf ${TARGET}/configs/
    cp -R ${GOPATH}/src/main/configs/server.www.proxy.conf ${TARGET}/configs/
    cp -R ${GOPATH}/src/main/www ${TARGET}/

    cp -R ${GOPATH}/src/main/public ${TARGET}/
    cp -R ${GOPATH}/src/main/resources ${TARGET}/
    cp -R ${GOPATH}/src/main/views ${TARGET}/
    cp -R ${GOPATH}/src/main/libs ${TARGET}

    if [ ${GOOS} = "windows" ]
    then
        cp ${GOPATH}/src/main/start.bat ${TARGET}
    fi

    # remove plus files
    rm -rf ${TARGET}/views/@default/plus

    echo "[zip files]"
    cd ${TARGET}/../
     if [ -f teaweb-${GOOS}-${GOARCH}-v${VERSION}.zip ]
    then
        rm -f teaweb-${GOOS}-${GOARCH}-v${VERSION}.zip
    fi
    zip -r -X -q teaweb-${GOOS}-${GOARCH}-v${VERSION}.zip  teaweb-v${VERSION}/
    cd -

    echo "[clean files]"
    rm -rf ${TARGET}

    echo "[done]"
}