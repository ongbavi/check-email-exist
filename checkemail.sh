#! /bin/bash

# Set useful variables
EMAIL="$1";
DOMAIN=`cut -d "@" -f 2 <<< "$1"`;
MX_HOSTS=(`nslookup -q=mx $DOMAIN | grep mail | cut -d " " -f 5`) # Find MX hosts of our domain
PORTS=25; # The PORTS to test our telnet on, port 25 only
dt=`date '+%d/%m/%Y_%H:%M:%S'`

if [[ $# == 2 ]]; then
    SENDER="$2"
fi
if [ -z $SENDER ]; then
    SENDER='<>'
fi

check (){
OUTPUT=`expect expectTelnet.tcl $EMAIL $MX_HOSTS $PORTS $SENDER`;
	if [[ `echo $OUTPUT|grep "2.1.5"` ]];then
		echo "$dt $EMAIL : exists";
	elif [[ `echo $OUTPUT|grep "2.1.1"` ]]; then
		echo "$EMAIL does not exists $OUTPUT";
	else echo "$dt $EMAIL : can't check $MX_HOSTS";
	fi
}

if [[ $DOMAIN = "gmail.com" || $DOMAIN = "yahoo.com" ||$DOMAIN == "hotmail.com" || $DOMAIN == "live.com" ]]; then
	echo "$EMAIL của gmail";
else 
	if [[ `echo $MX_HOSTS | grep google.com` || `echo $MX_HOSTS|grep outlook.com` || `echo $MX_HOSTS|grep yahoodns` ]]; then
		echo "$dt $EMAIL : is gmail or outlook or yahoo, not check";
	else 
		if [[ `echo "quit" | timeout --signal=9 10 telnet $MX_HOSTS 25 | grep "Escape character is"` ]];then #time out after 10s
			check
		else
			echo "$dt $EMAIL : server $MX_HOSTS port 25 is not open, timeout 10s";
		fi
	fi
fi
exit 1;
