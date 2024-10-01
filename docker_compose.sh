#!/bin/bash
trap "exit" 0
DC="docker compose" # add  `-f docker/compose.yml` if it's in another folder
if [ $# -eq 0 ]; then
    $DC ps -a
elif [ $1 == "up" ]; then
    $DC up -d
elif [ $1 == "nr" ]; then
    if [ $# -gt 1 ]; then
        $DC exec node su node -c "${*:2}"
    else
        $DC exec node su node
    fi
elif [ $1 == "npm" ]; then
    $DC exec node su node -c "npm ${*:2}"
elif [ $1 == "install" ]; then
    $DC exec node su node -c 'npm install'
elif [ $1 == "recreate" ]; then
    $DC up -d --force-recreate ${*:2}
elif [ $1 == "build" ]; then
    $DC up -d --force-recreate --build ${*:2}
else
    $DC $*
fi

#ReadMe

# ./dc to show all containers with status
# ./dc up to start in detached mode
# ./dc install to run npm install in the node container as user node
# ./dc npm install package-name-here to run any npm command inside node container. Works with ./dc npm run start too
# ./dc nr interactive exec inside node container
# ./dc nr node index.js run any command inside node container
# ./dc recreate applies any modifications to docker-compose.yml
# ./dc recreate node applies modifications to compose, only for node container
# ./dc build if you have a custom dockerfile, does run dc up with a fresh build.
# ./dc logs -n 10 -f node - any other docker-compose command works as expected.
