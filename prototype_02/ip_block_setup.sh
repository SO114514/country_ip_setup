#################################################################################################################
#                                CONDITION OF USE                                                               #
#---------------------------------------------------------------------------------------------------------------#
#                     The script use for blocking an IP address.                                                #
# List of IP address will obtain from ARIN, APNIC, RIPE NCC, AFRINIC and LACNIC.                                #
# Which country you want to block thier IP address, add alpha-2, (ISO 3166) like CN in line 14 BLOCK_COUNTRIES. #
#################################################################################################################

#!/bin/sh

APNIC_URL='http://ftp.apnic.net/stats/apnic/delegated-apnic-latest'
ARIN_URL='http://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest'
AFRINIC_URL='http://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest'
RIPE_URL='https://ftp.apnic.net/stats/ripe-ncc/delegated-ripencc-latest'
LACNIC_URL='https://ftp.lacnic.net/pub/stats/ripencc/delegated-ripencc-latest'
BLOCKED_COUNTRIES="CN SG ID"

# Obtain the IP addresses from the specified country each lists of and DROP.
function drop_iptables(){

    echo "Getting the data..."
    for URL in ${APNIC_URL} ${ARIN_URL} ${AFRINIC_URL} ${RIPE_URL} ${LACNIC_URL}; do
        if curl -s ${URL} > /tmp/delegated-latest; 
        then
            echo "Setting up iptables: ${URL}"
            iptables -D INPUT -j DROP-BLOCKED-IP > /dev/null 2>&1
            iptables -F DROP-BLOCKED-IP          > /dev/null 2>&1
            iptables -X DROP-BLOCKED-IP          > /dev/null 2>&1
            iptables -N DROP-BLOCKED-IP
            
            for COUNTRY in ${BLOCKED_COUNTRIES}; do
                echo "Processing country: ${COUNTRY}"
                for i in $(awk -F'|' -v country="$COUNTRY" '$2==country&&$3=="ipv4"{print $4","$5}' /tmp/delegated-latest)
                do
                    IP_LIST_1=$(echo $i | cut -d',' -f1)
                    IP_LIST_2=$(echo $i | cut -d',' -f2)
                    IP_BLOCK=$(cider_calculate $IP_LIST_1 $IP_LIST_2)

                    if [ "${IP_BLOCK}" != "null" ]; then
                        iptables -A DROP-BLOCKED-IP -s ${IP_BLOCK} -j DROP
                        echo "iptables -A DROP-BLOCKED-IP -s ${IP_BLOCK} -j DROP # ${COUNTRY}"
                        echo "${IP_BLOCK} - ${COUNTRY}" >> /var/log/blocked_ips.log
                    fi
                done
            done
            rm -rf /tmp/delegated-latest
        else
            echo "Failed obtain the data: ${URL}"
        fi
    done
    iptables -A DROP-BLOCKED-IP -j RETURN
    iptables -I INPUT 1 -j DROP-BLOCKED-IP
    iptables -nvxL
    rm -rf /tmp/delegated-apnic-latest
}

# Intialize iptables lists.
function init_iptables(){

    iptables -D INPUT -j DROP-BLOCKED-IP
    iptables -F DROP-BLOCKED-IP
    iptables -X DROP-BLOCKED-IP
    iptables -nvxL
    echo -e '\n==================================================\n'
    echo -e '\niptables initialised\n'
}

# CIDR calculated from the number of IP addresses.
function cider_calculate(){
    
    local IP_ADDRESS_NUM=4294967296
    local IP_ADDRESS=$1
    local IP_NUM=$2
    local IP_CIDR='null'
    
    for i in $(seq 1 32)
    do
        IP_ADDRESS_NUM=$((${IP_ADDRESS_NUM}/2))
        if [ $((IP_ADDRESS_NUM/IP_NUM)) -eq 1 -a $((IP_ADDRESS_NUM%IP_NUM)) -eq 0 ]; then
            IP_CIDR=$i
            break
        fi
    done
    
    echo "$IP_ADDRESS/$IP_CIDR"
}

function echo_erase(){

    local STRING="$1"
    echo -n ${STRING}
    for i in $(seq 0 ${#STRING})
    do
        echo -n $'\b'
    done
}

# Run iptables.
drop_iptables

echo -e '\nSettings complete\n'
echo -e 'If there are no problems with the current settings, exit and save with ‘Ctrl + C’ within 110 seconds\n'
sleep 110
init_iptables
