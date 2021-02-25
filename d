#!/bin/bash
setup() {
	if [ -z $directory ]; then
    directory=`pwd`
  fi
  
	if [ -z $project ]; then
    project=${directory##*/}
  fi

	if [ "$(/usr/local/bin/docker-compose --project-directory "$directory" -p $project-blue top)" ]; then
    CURRENT_PROJECT="$project-blue"
    DEPLOY_PROJECT="$project-green"
	else
    CURRENT_PROJECT="$project-green"
    DEPLOY_PROJECT="$project-blue"
	fi

	echo "[$CURRENT_PROJECT]"
}

composer() {
  /usr/local/bin/docker run --rm -u www-data --interactive --tty --volume $directory:/app composer "$args"
}

console() {
  args="exec -u www-data app php /script/bin/console $args"
  run
}

run() {
  /usr/local/bin/docker-compose --project-directory "$directory" --project-name="$CURRENT_PROJECT" $args
}

deploy() {
  echo "Building $DEPLOY_PROJECT container"
  /usr/local/bin/docker-compose --project-name=$DEPLOY_PROJECT build

  echo "Stopping $CURRENT_PROJECT container"
  /usr/local/bin/docker-compose --project-name=$CURRENT_PROJECT down

  echo "Starting $DEPLOY_PROJECT container"
  /usr/local/bin/docker-compose --project-name=$DEPLOY_PROJECT up $args
}

while [ "$1" != "" ]; do
  case "$1" in
    -p | --project )  shift
                      project=$1
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
                      
    version)          echo '0.3-beta'
                      exit
                      ;;
  esac
done