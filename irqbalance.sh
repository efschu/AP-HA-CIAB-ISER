#!/bin/bash
IRQBALANCE_ARGS=""
for DRIVER in mlx4 mlx5 ;do
    IRQS=$(cat /proc/interrupts | grep ${DRIVER} | awk '{print $1}' | sed 's/://')
    cores=($(seq 1 $(grep -c processor /proc/cpuinfo)))
    i=0
    for IRQ in $IRQS ;do
        IRQBALANCE_ARGS="${IRQBALANCE_ARGS} -i ${IRQ}"
        core=${cores[$i]}
        let "mask=2**(core-1)"
        echo $(printf "%x" $mask) > /proc/irq/${IRQ}/smp_affinity
        let "i+=1"
        if [[ $i == ${#cores[@]} ]]; then
            i=0
        fi
    done
done
# if on Debian/Ubuntu:
FILE=/etc/default/irqbalance
# if on Centos/Redhat:
#FILE=/etc/sysconfig/irqbalance
sed -i "s/^#*IRQBALANCE_ARGS=.*/IRQBALANCE_ARGS=\"${IRQBALANCE_ARGS}\"/" ${FILE}
systemctl restart irqbalance
