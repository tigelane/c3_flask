#!/bin/bash

exec > >(tee -a /usr/local/osmosix/logs/service.log) 2>&1
echo "Executing service script.."
agentSendLogMessage "Executing service script.."
version="2"

# RUN EVERYTHING AS ROOT
if [ "$(id -u)" != "0" ]; then
    exec sudo "$0" "$@"
fi

OSSVC_HOME=/usr/local/osmosix/service

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. $OSSVC_HOME/utils/cfgutil.sh
. $OSSVC_HOME/utils/nosqlutil.sh
. $OSSVC_HOME/utils/install_util.sh
. $OSSVC_HOME/utils/os_info_util.sh
. $OSSVC_HOME/utils/agent_util.sh

export FLASK_DIR=/opt
export FLASK_APP_DIR=$FLASK_DIR/flaskapp
export dir_name=flaskapp

thisOS=$(set -- $imageName ; echo $1)
root_dir="$( cd "$( dirname $0 )" && pwd )"
echo Root dir $root_dir

setuposprereqs() {
    agentSendLogMessage "Installing OS PreReqs.."
        agentSendLogMessage "Updating aptitude, python, and pip."
        apt-get -y update
        agentSendLogMessage "Installing Python 2.7.";
        apt-get -y install python2.7;
        apt-get -y install python-dev;
        apt-get -y install libmysqlclient-dev;
        apt-get install python-mysqldb;
        agentSendLogMessage "Installing Python pip.";
        apt-get -y install python-pip;
    }

setuppythonprereqs() {
    agentSendLogMessage "Installing Python packages.."
    pip install --upgrade pip;
    pip install MySQL-python;
    pip install flask;
    # pip install requests;
}

deploytheapplication() {
    agentSendLogMessage "FlaskDir: $FLASK_DIR"
    agentSendLogMessage "FlaskApp URL: $flaskappzip"
    mkdir -p $FLASK_DIR
    cd $FLASK_DIR
    cp $flaskappzip .
    unzip flaskapp.zip
}

# This should not be run but could be used for testing
runflaskapp() {
    agentSendLogMessage "Executing flask application"
    cd FLASK_APP_DIR
    ./flaskapp.py
}

setuposprereqs
setuppythonprereqs
deploytheapplication
# runflaskapp

