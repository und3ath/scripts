@echo off

echo 'Mouting /boot/ partition ...' 

"%cd%\osfmount\osfmount.com" -a -t file -f "%cd%\ubuntu.img" -m "X:"

if not exist X:\ (
	echo 'Unable to mount, maybe Z: is already used ?'
	quit
)


echo 'Copy initrd.gz and vmlinuz ..'

xcopy X:\vmlinuz-* "%cd%\"
xcopy X:\initrd.img-* "%cd%\"

echo 'Unmouning ..'

"%cd%\osfmount\osfmount.com" -D -m X:


