#!/bin/bash
# Author: thorian
# Scope: Anonymize your system

# Variables:
INTERFACE="wlan0"
MODE="dummy"
USAGE="offline"
FAKE_HOSTNAME="$(date +%s|md5sum|head -c 10)"
OLD_FAKE_HOSTNAME="/tmp/OLD_FAKE_HOSTNAME"
TRUE_HOSTNAME="real_hostname"
#FORMER_HOST="$(cat former_host)"

# Get Options:
while getopts ":m:u:i:h" opt; do
  case $opt in
    m)
      MODE="$OPTARG"
      ;;
    u)
      USAGE="$OPTARG"
      ;;
    i)
      INTERFACE="$OPTARG"
      ;;
    h)
      MODE="help"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Anonymize MAC
anonymize()
{
	service network-manager stop
	ifconfig $INTERFACE down
	hostname
	macchanger -r $INTERFACE
	if [ "$USAGE" == "online" ]
	then
		ifconfig $INTERFACE up
		service network-manager start
	elif [ "$USAGE" == "offline" ]
	then
		echo "Interface $INTERFACE is offline. Didn't try to enable."
		service network-manager start
	else
		echo "Some error occured!"
	fi
}
# Deanonymize MAC
deanonymize()
{
	service network-manager stop
	ifconfig $INTERFACE down
	hostname
	macchanger -p $INTERFACE
        if [ "$USAGE" == "online" ]
        then
			ifconfig $INTERFACE up
			service network-manager start
        elif [ "$USAGE" == "offline" ]
        then
                echo "Interface $INTERFACE is offline. Didn't try to enable."
                service network-manager start
        else
                echo "Some error occured!"
        fi
}
hostname()
{
	if [ "$MODE" == "anon" ]
	then
		echo "$FAKE_HOSTNAME" > /etc/hostname
		echo "$FAKE_HOSTNAME" > $OLD_FAKE_HOSTNAME
		sed -i "s/$TRUE_HOSTNAME/$FAKE_HOSTNAME/g" /etc/hosts
	elif [ "$MODE" == "non" ]
	then
		echo "$TRUE_HOSTNAME" > /etc/hostname
		if [ -f $OLD_FAKE_HOSTNAME ]
		then
			sed -i "s/$(cat $OLD_FAKE_HOSTNAME)/$TRUE_HOSTNAME/g" /etc/hosts
			rm $OLD_FAKE_HOSTNAME
		else
			echo "Old hostname could not be found. Correct manually!"
		fi
	fi
}
help()
{
	
	echo "-------------------------------------------------------"
	echo "| You chose the -h option."
	echo "|"
	echo "| You can use this script with the following options:"
	echo "| -m:	(mode)	you can choose between two parameters:"
	echo "|		-'non'		(deanonymize)"
	echo "|		-'anon'		(anonymize)"
	echo "| -u:	(usage)	you can choose between two parameters:"
	echo "|		- 'online'	(bring interface up again)"
	echo "|		- 'offline'	(leave interface down)"
	echo "| -i: (interface) lets you set which interface to use"
	echo "| -h:	(help)	displays this help and quits."
	echo "-------------------------------------------------------"
}

# Main:
case $MODE in
	anon)
		anonymize
	;;
	non)
		deanonymize
	;;
	help)
		help
	;;
	dummy)
		echo "You got to choose someting to do!"
		echo "No instructions means no action!"
	;;
	*)
		echo "Something went wrong! Quitting!"
	;;
esac
