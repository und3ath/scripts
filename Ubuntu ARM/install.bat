@echo off


echo 'Download Ubuntu Net install files.'
powershell -command "& { iwr http://ports.ubuntu.com/ubuntu-ports/dists/xenial-updates/main/installer-armhf/current/images/generic-lpae/netboot/initrd.gz -Outfile install-initrd.gz }"
powershell -command "& { iwr http://ports.ubuntu.com/ubuntu-ports/dists/xenial-updates/main/installer-armhf/current/images/generic-lpae/netboot/vmlinuz -Outfile install-vmlinuz }"

echo 'Create the hdd (16Gb)'

qemu-img create -f raw ubuntu.img 16G

echo 'The installation process will start'
echo 'Please connect vnc client to localhost to open kvm console'
echo 'alt+ctrl+[1,2,3] to switch qemu console input [serial should be 2]'
echo 'When installation is finished, close quemu and run postinstall.bat script'
echo 'to extract vmlinuz and initrd.gz file.'


qemu-system-arm.exe -M virt -m 2048M^
	-kernel install-vmlinuz^
	-initrd install-initrd.gz^
	-drive if=none,file=ubuntu.img,id=hd,format=raw^
	-device virtio-blk-device,drive=hd^
	-netdev user,id=mynet^
	-device virtio-net-device,netdev=mynet^
	-vnc :0 -k fr^
	-no-reboot
	
	

