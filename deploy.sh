#!/usr/bin/env bash
set -e

VERSION=$1
TAG=`git tag -l | tr -d '\n'`

if [ -z ${VERSION} ]; then
    echo Version not set
    exit 1
fi
if git status; then
    echo -e "Continue without committing changes? (Y/y): "
    read CONTINUE
else
    CONTINUE=y
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
