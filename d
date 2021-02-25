#!/bin/bash
if [ -f "`pwd`/.d" ]; then
  source "`pwd`/.d"
fi

setup() {
	if [ -z $directory ]; then
    directory=`pwd`
  fi

  PROJECT=${PROJECT:=${directory##*/}}
  USER=${USER:=www-data}

	if [ "$(docker-compose --project-directory "$directory" -p $PROJECT-blue top)" ]; then
    CURRENT_PROJECT="$PROJECT-blue"
    DEPLOY_PROJECT="$PROJECT-green"
	else
    CURRENT_PROJECT="$PROJECT-green"
    DEPLOY_PROJECT="$PROJECT-blue"
	fi

	echo "[$CURRENT_PROJECT]"
}

composer() {
  docker run --rm -u $USER --interactive --tty --volume $directory:/app composer "$args"
}

console() {
  args="exec -u $USER app php /script/bin/console $args"
  run
}

exec() {
  args="exec -u $USER app $args"
  run
}

run() {
  docker-compose --project-directory "$directory" --project-name="$CURRENT_PROJECT" $args
}

version() {
  echo 'maximevalette/d version 0.4'
}

deploy() {
  echo "Building $DEPLOY_PROJECT container"
  docker-compose --project-name=$DEPLOY_PROJECT build

  echo "Stopping $CURRENT_PROJECT container"
  docker-compose --project-name=$CURRENT_PROJECT down

  echo "Starting $DEPLOY_PROJECT container"
  docker-compose --project-name=$DEPLOY_PROJECT up $args
}

while [ "$1" != "" ]; do
  case "$1" in
    -p | --project )  shift
                      PROJECT=$1
                      shift
                      ;;
    -d | --dir )      shift
                      directory=$1
                      shift
                      ;;
                      
    project)          setup
                      exit
                      ;;
    composer)         setup
                      shift
                      args="$@"
                      composer
                      exit
                      ;;
    console)          setup
                      shift
                      args="$@"
                      console
                      exit
                      ;;
    exec)             setup
                      shift
                      args="$@"
                      exec
                      exit
                      ;;
    run)              setup
                      shift
                      args="$@"
                      run
                      exit
                      ;;
    deploy)           setup
                      shift
                      args="$@"
                      deploy
                      exit
                      ;;
                                        
    ps)               docker ps
                      exit
                      ;;
    ssh)              shift
                      docker exec -it "$1" sh
                      exit
                      ;;
                      
    version)          version
                      exit
                      ;;

    *)                version
                      echo 'Available commands: [-p] [-d] project composer console exec run deploy ps ssh version'
                      exit
                      ;;
  esac
done