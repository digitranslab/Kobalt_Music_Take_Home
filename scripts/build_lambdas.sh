#!/bin/bash

set -euo pipefail


usage() { echo "Usage: $0 [-f <lambda-function-names>]" 1>&2; exit 1; }

while getopts ":f:" arg;
do
  case ${arg} in
    f)
      FUNCTION_NAME=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done


cd "$(dirname "$0")" && cd ../

mkdir -p build
mkdir -p build/lambda

BUILD_FOLDER="$PWD/build"
LAMBDA_VERSION="1.0.0"
ROOT_DIR=${PWD}


if [[ -z ${FUNCTION_NAME+x} ]]
then
  LAMBDAS=$(for path in $(ls -d  backend/lambdas/*/handler.py); do basename $(dirname ${path}); done)
  function join_by { local IFS="$1"; shift; echo "$*"; }
  bash scripts/$(basename "$0") -f $(join_by , ${LAMBDAS})
fi

if [[ ! -z ${FUNCTION_NAME+x} ]]
then
  FUNCTION_NAMES=${FUNCTION_NAME//,/ }

  rm -rf "${BUILD_FOLDER}" && mkdir -p "${BUILD_FOLDER}"/lambda

  for function_name in ${FUNCTION_NAMES}
  do
    echo "Building artefact for job: ${function_name}..."

    cd backend/lambdas/"${function_name}"

    files=$(ls | grep -v -e __init__.py -e __pycache__)
    if [[ -f "requirements.txt" ]]; then
        echo -e "[install]\nprefix=" > setup.cfg
        python3 -m pip install --upgrade pip > /dev/null
        # this looks redundant
        # pip3 install -t $OLDPWD/package -r requirements.txt
        python3 -m pip install -t $OLDPWD/package -r requirements.txt > /dev/null
        cp $files $OLDPWD/package/
        pwd
        cd $OLDPWD
#      (cd package && zip -rq "${BUILD_FOLDER}"/lambda/"${function_name}"-"${LAMBDA_VERSION}".zip .)
        (cd package && zip -rq "${BUILD_FOLDER}"/lambda/"${function_name}".zip .)
        rm backend/lambdas/"${function_name}"/setup.cfg
        rm -rf package
    fi

  done
fi

exit 0
