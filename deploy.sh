#!/usr/bin/env bash
set -e

VERSION=$1
COMMIT=$2

TAG=`git tag -l | tr -d '\n'`

if [ -z ${VERSION} ]; then
    echo Version not set
    exit 1
fi
if [[ -z ${COMMIT} ]]; then
    if [[ -z "`git status --porcelain`" ]]; then
        CONTINUE=y
    else
        git status -s
        echo -e "Continue without committing changes? (Y/y): "
        read CONTINUE
    fi
else
    echo "Checking for changes"
    if [[ -z "`git status --porcelain`" ]]; then
        CONTINUE=y
    else
        echo "Attempting commit"
        git add .
        git commit -m "Bump v$VERSION"
        CONTINUE=y
    fi
fi

if [[ "y" == ${CONTINUE} ]] || [[  "Y" == ${CONTINUE} ]]; then
    if [ "${TAG}" != "${VERSION}" ]; then
        echo "Tagging version ${VERSION}"
        git tag ${VERSION}
    fi

    echo "Pushing master"
    git push github master --tags

    if grep -q 'auths": {}' ~/.docker/config.json ; then
        echo "Docker is not logged in"
        docker login
    fi
    echo "Pushing to Docker hub"
    docker build . --force-rm --rm -t chrisdlangton/h2o-flow:${VERSION} --compress && \
        docker push chrisdlangton/h2o-flow:${VERSION} && \
        docker push chrisdlangton/h2o-flow:latest && \
        echo ok && exit

    echo Failed
    exit 1
fi
