#!/usr/bin/env bash
set -e

VERSION=$1

if [ -z ${VERSION} ]; then
    echo Version not set
    exit 1
fi

git status
echo -e "Continue? (Y/y): "
read CONTINUE

if [[ "y" == ${CONTINUE} ]] || [[  "Y" == ${CONTINUE} ]]; then
    git tag ${VERSION}
    git push github master --tags

    sudo docker build . --force-rm --rm -t chrisdlangton/h2o-flow:${VERSION} --compress && \
        sudo docker push chrisdlangton/h2o-flow:${VERSION} && \
        sudo docker push chrisdlangton/h2o-flow:latest && \
        echo ok && exit

    echo Failed
    exit 1
fi