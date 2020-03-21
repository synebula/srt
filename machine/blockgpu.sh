#!/bin/bash
devicelist=(0000:01:00.1 0000:01:00.0)

vfiobind() {
    dev="$1"
        vendor=$(cat /sys/bus/pci/devices/$dev/vendor)
        device=$(cat /sys/bus/pci/devices/$dev/device)
        if [ -e /sys/bus/pci/devices/$dev/driver ]; then
                echo $dev > /sys/bus/pci/devices/$dev/driver/unbind
        fi
       echo "$vendor $device" > /sys/bus/pci/drivers/vfio-pci/new_id
}


for data in ${devicelist[@]}  
do  
    echo $data | grep ^# >/dev/null 2>&1 && continue
        vfiobind $data
done

exit 0
