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
		echo "$dt $EMAIL : exists" >> log;
	elif [[ `echo $OUTPUT|grep "2.1.1"` ]]; then
		echo "$dt $EMAIL : does not exists" >> log;
	else echo "$dt $EMAIL : can't check $MX_HOSTS $OUTPUT" >> log;
	fi
}

if [[ $DOMAIN == "hotmail.com" || $DOMAIN == "live.com" || $DOMAIN == "amazonses.com" ]]; then
	echo "$dt $EMAIL : của gmail" >> log;
else 
	if [[ `echo $MX_HOSTS|grep outlook.com`  ]]; then
		echo "$dt $EMAIL : is gmail or outlook or yahoo, not check" >> log;
	else 
		if [[ `echo "quit" | timeout --signal=9 10 telnet $MX_HOSTS 25 | grep "Escape character is"` ]];then #time out after 10s
			check
		else
			echo "$dt $EMAIL : server $MX_HOSTS port 25 is not open, timeout 10s" >> log;
		fi
	fi
fi
exit 1;
