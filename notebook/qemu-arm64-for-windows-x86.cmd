# Create Disk (qcow2 is recommanded)
qemu-img.exe create -f raw Kylin-Server-10-SP1-Release-Build20-20230607-arm64.img 100G
qemu-img.exe create -f qcow2 Kylin-Server-10-SP1-Release-Build20-20220812-arm64.img 100G

# Install OS
qemu-system-aarch64.exe -m 4G -cpu cortex-a72 --accel tcg,thread=multi -M virt -bios F:\VM\QEMU_EFI.fd -rtc base=localtime -display sdl -device VGA -device nec-usb-xhci -device usb-tablet -device usb-kbd -drive if=virtio,file=F:\VM\arm64\Kylin-Server-10-SP1-Release-Build20-20230607-arm64\Kylin-Server-10-SP1-Release-Build20-20230607-arm64.img,id=hd0,format=raw,media=disk -drive if=none,file=D:\abc_iso\Kylin-Server-10-SP1-Release-Build20-20230607-arm64.iso,id=cdrom,media=cdrom -device virtio-scsi-device -device scsi-cd,drive=cdrom 

# Run OS
qemu-system-aarch64.exe -m 4G -cpu cortex-a72 --accel tcg,thread=multi -M virt -bios F:\VM\QEMU_EFI.fd -rtc base=localtime -display sdl -device VGA -device nec-usb-xhci -device usb-tablet -device usb-kbd -drive if=virtio,file=F:\VM\arm64\Kylin-Server-10-SP1-Release-Build20-20230607-arm64\Kylin-Server-10-SP1-Release-Build20-20230607-arm64.img,id=hd0,format=raw,media=disk -net nic,model=virtio -net user,hostfwd=tcp::2222-:22

# Install OS
qemu-system-aarch64.exe -m 4G -cpu cortex-a72 --accel tcg,thread=multi -M virt -bios F:\VM\QEMU_EFI.fd -rtc base=localtime -display sdl -device VGA -device nec-usb-xhci -device usb-tablet -device usb-kbd -drive if=virtio,file=F:\VM\arm64\Kylin-Server-10-SP1-Release-Build20-20220812-arm64\Kylin-Server-10-SP1-Release-Build20-20220812-arm64.img,id=hd0,format=qcow2,media=disk -drive if=none,file=D:\abc_iso\Kylin-Server-10-SP1-Release-Build20-20220812-arm64.iso,id=cdrom,media=cdrom -device virtio-scsi-device -device scsi-cd,drive=cdrom 

# Run OS
qemu-system-aarch64.exe -m 4G -cpu cortex-a72 --accel tcg,thread=multi -M virt -bios F:\VM\QEMU_EFI.fd -rtc base=localtime -display sdl -device VGA -device nec-usb-xhci -device usb-tablet -device usb-kbd -drive if=virtio,file=F:\VM\arm64\Kylin-Server-10-SP1-Release-Build20-20220812-arm64\Kylin-Server-10-SP1-Release-Build20-20220812-arm64.img,id=hd0,format=qcow2,media=disk -net nic,model=virtio -net user,hostfwd=tcp::2222-:22
