MEM_TOTAL=$(awk '/MemTotal/ {printf( "%.0f\n", $2 / 1000 )}' /proc/meminfo)
MEM_FREE=$(awk '/MemFree/ {printf( "%.0f\n", $2 / 1000 )}' /proc/meminfo)
MEM_USED=$(echo "$MEM_TOTAL - $MEM_FREE" | bc)
MEM_USED_PERCENT=$(echo "$MEM_USED $MEM_TOTAL" | awk '{printf ("%.2f", ($1 / $2) * 100)}')

USED_DISK_SIZE=$(df --output=used | tail --lines=+2 | paste -sd+ | bc)
AVAIL_DISK_SIZE=$(df --output=avail | tail --lines=+2 | paste -sd+ | bc)
AVAIL_DISK_PERCENT=$(echo "$USED_DISK_SIZE $AVAIL_DISK_SIZE" | awk '{printf ("%.2f", ($1 / $2) * 100)}')

USED_DISK_SIZE=$(echo "$USED_DISK_SIZE" | awk '{printf ("%d", ($1 / 1000))}')
AVAIL_DISK_SIZE=$(echo "$AVAIL_DISK_SIZE" | awk '{printf ("%d", ($1 / 1000000))}')

LAST_BOOT=$(uptime -s)
LAST_BOOT=${LAST_BOOT::-3}

LVM_COUNT=$(lsblk -o TYPE | grep lvm | wc -l | awk '{print $1}')
HAS_LVM="no"
if [[ "$LVM_COUNT" > "0" ]]
then
	HAS_LVM="yes"
fi

IP=$(hostname -I)
IP="${IP%% *}"

MAC=$(ip a | grep ether | head -n 1 | awk '{print $2}')

echo "#Architecture: " $(uname -a)
echo "#CPU physical :" $(cat /proc/cpuinfo | grep 'physical id' | sort -u | wc -l)
echo "#vCPU :" $(nproc)
echo "#Memory Usage:" "${MEM_USED}/${MEM_TOTAL}MB" "($MEM_USED_PERCENT%)"
echo "#Disk Usage:" "${USED_DISK_SIZE}MB/${AVAIL_DISK_SIZE}GB" "($AVAIL_DISK_PERCENT%)"
echo "#CPU load: " $(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%    "}')
echo "#Last boot: $LAST_BOOT"
echo "#LVM: $HAS_LVM"
echo "#Active TCP Connections: $(grep </proc/net/tcp -c '^ *[0-9]\+: [0-9A-F: ]\{27\} 01 ')"
echo "#Session count: $(who | wc -l)"
echo "#Logged-in user count: $(who | awk '{print $1}' | sort -u | wc -l)"
echo "#Network: IP $IP ($MAC)"
echo "#Sudo: $(cat /var/log/sudo/sudo.log | grep -c COMMAND) cmd"
