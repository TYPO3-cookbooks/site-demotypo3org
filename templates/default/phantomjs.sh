#!/bin/bash
#
# Script for starting phantomjs as daemon
#

USER="phantomjs"
DAEMON="/usr/local/phantomjs/bin/phantomjs --webdriver=8643"
LOG_FILE="/var/log/phantomjs/main.log"

do_start()
{
        echo -n $"Starting PhantomJS: "
        pid=`ps -aefw | grep "$DAEMON" | grep -v " grep " | awk '{print $2}'`

        if [ -z "$pid" ]
        then
			sudo -u $USER $DAEMON >> $LOG_FILE &
			RETVAL=$?
			if [ $RETVAL -eq 0 ]
			then
				echo 'ok'
			else
				echo 'something went wrong!'
			fi
        else
        	echo 'already running...'
        fi

}
do_stop()
{
        echo -n $"Stopping PhantomJS: "
        pid=`ps -aefw | grep "$DAEMON" | grep -v " grep " | awk '{print $2}'`
        kill -9 $pid > /dev/null 2>&1
        RETVAL=$?
		if [ $RETVAL -eq 0 ]
		then
			echo 'ok'
		else
			echo 'no process found'
		fi
}

do_status()
{
        pid=`ps -aefw | grep "$DAEMON" | grep -v " grep " | awk '{print $2}'`
        if [ -z "$pid" ]
        then
        	echo 'PhantomJS is stopped'
        else
        	echo 'PhantomJS is running'
        fi
}

case "$1" in
        start)
                do_start
                ;;
        stop)
                do_stop
                ;;
        restart)
                do_stop
                do_start
                ;;
        status)
                do_status
                ;;
        *)
                echo "Usage: $0 {start|stop|restart|status}"
                RETVAL=1
esac

exit $RETVAL
