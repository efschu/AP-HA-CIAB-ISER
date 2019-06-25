#!/bin/bash
limit=0.15
zpool list -Hp| while read line;
do
        name=$(echo $line| awk '{ printf $1; }');
        tmp=$(echo $line| awk '{ printf $4/$2; }');
        tmp2=$(zfs list -H -t snapshot -o name -S creation -r $name);
        while (( $(echo $tmp '<' $limit |bc -l) )) && [ ! -z "$tmp2" ];
        do
                tmp3=$(zfs list -H -t snapshot -o name -S creation -r $name | tail -1)
                zfs list -H -t snapshot -o name -S creation -r $name | tail -1 | xargs -n 1 zfs destroy;
                tmp=$(echo $line| awk '{ printf $4/$2; }');
                tmp2=$(zfs list -H -t snapshot -o name -S creation -r $name);
                echo "zfs-auto-delete-snapshot deleted $tmp3" > /dev/kmsg;
        done;
done
