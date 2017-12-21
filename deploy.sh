#!/usr/bin/env bash
set -e

VERSION=$1
SILENT=$2

TAG=`git tag -l | tr -d '\n'`

if [ -z ${VERSION} ]; then
    echo Version not set
    exit 1
fi
if [[ -z ${SILENT} ]]; then
    if [[ -z "`git status --porcelain`" ]]; then
        CONTINUE=y
    else
        git status -s
        echo -e "Continue without committing changes? (Y/y): "
        read CONTINUE
    fi
else
    if [[ -z "`git status --porcelain`" ]]; then
        CONTINUE=y
    else
        git add .
        git commit -m "Bump v$VERSION"
        CONTINUE=y
    fi
fi

if [[ "y" == ${CONTINUE} ]] || [[  "Y" == ${CONTINUE} ]]; then
    if [ "${TAG}" != "${VERSION}" ]; then
        echo tagging
        exit
        git tag ${VERSION}
    fi
    exit
    git push github master --tags

    sudo docker build . --force-rm --rm -t chrisdlangton/h2o-flow:${VERSION} --compress && \
        sudo docker push chrisdlangton/h2o-flow:${VERSION} && \
        sudo docker push chrisdlangton/h2o-flow:latest && \
        echo ok && exit

    echo Failed
    exit 1
fi
