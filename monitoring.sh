#The architecture of your operating system and its kernel version
architecture=$(uname -a)

#The number of physical processors
nr_pysical_processors=$(grep "physical id" /proc/cpuinfo | wc -l)

#The number of virtual processors
nr_virtual_processors=$(grep "processor" /proc/cpuinfo | wc -l)

#The current available RAM on your server and its utilisation rate as a percentage
total_RAM=$(free --mega | grep "Mem:" | awk '{print $2}')
used_RAM=$(free --mega | grep "Mem:" | awk '{print $3}')
used_RAM_percent=$(free --mega | grep "Mem:" | awk '{printf("%.2f", $3/$2*100)}')

#The current available storage on your server and its utilization rate as a percentage
total_disk_space=$(df -m | grep "/dev/" | grep -v "/boot" | grep -v "tmpfs" | awk '{disk_total += $2} END {printf "%.1f", disk_total/1024}')
used_disk_space=$(df -m | grep "/dev/" | grep -v "/boot" | grep -v "tmpfs" | awk '{disk_use += $3} END {print disk_use}')
used_disk_percent=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{use += $3} {total += $2} END {printf ("%d", use/total*100)}')

#The current utilization rate of your processors as a percentage 
cpu_use=$(vmstat | tail -1 | awk '{printf "%.1f", 100 - $15}')

#The date and time of the last reboot
reboot_date=$(who -b | awk '{print $3}')
reboot_time=$(who -b | awk '{print $4}')

#Whether LVM is active or not
LVM_activity=$(if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; then echo yes; else echo no; fi)

#The number of active connections
active_con=$(ss -ta | grep ESTAB | wc -l)

#The number of users using the server
users=$(users | wc -w)

#The IPv4 address of your server and its MAC (Media Access Control) address
IP=$(hostname -I)
MAC=$(ip link | grep "link/ether" | awk '{print $2}')

#The number of commands executed with the sudo program
commands_sudo=$(journalctl _COMM=sudo | grep COMMAND | wc -l)


wall "  Architecture:   $architecture
        CPU:            $nr_pysical_processors
        vCPU:           $nr_virtual_processors
        Memory Usage:   $used_RAM/"$total_RAM"MB ($used_RAM_percent%)
        Disk Usage:     $used_disk_space/"$total_disk_space"GB ($used_disk_percent%)
        CPU load:       $cpu_use
        Last boot:      $reboot_date $reboot_time
        LVM use:        $LVM_activity
        Connections TCP:$active_con ESTABLISHED
        User log:       $users
        Network:        IP $IP ($MAC)
        Sudo:           $commands_sudo cmd"
