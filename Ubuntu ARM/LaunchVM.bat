@echo off


SET kernel=vmlinuz-4.4.0-72-generic-lpae
SET initrd=initrd.img-4.4.0-72-generic-lpae
SET hdd=ubuntu.img



qemu-system-arm.exe -M virt -m 2048M^
	-kernel %kernel%^
	-initrd %initrd%^
	-drive if=none,file=%hdd%,id=hd^
	-device virtio-blk-device,drive=hd^
	-netdev user,id=mynet^
	-device virtio-net-device,netdev=mynet^
	-vnc :0 -k fr^

	
	


