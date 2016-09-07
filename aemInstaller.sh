#!/bin/bash
while [[ $# > 1 ]]
do
    key="$1"
    
    case $key in
        -i|--install_file)
        FILENAME="$2"
        shift
        ;;
        -r|--runmode)
        RUNMODE="$2"
        shift
        ;;
        -p|--port)
        PORT="$2"
        shift
        ;;
        *)

        ;;
    esac
    shift
done



java -jar $FILENAME -listener-port 50007 -r $RUNMODE nosample -p $PORT 2>&1 &
aemPID=$!

nc -vklp 50007 > "install.log" 2>&1 &
pid=$!

while sleep 60
do
    if grep --quiet "started" "install.log"
    then
        if [ -f /aem/postInstallHook.sh ] ; then { echo "running post install hook"; /aem/postInstallHook.sh; } else { echo "no post install hook found"; } fi
        kill $pid
        kill $aemPID
        exit 0
    fi
done

