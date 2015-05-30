
.PHONY: kernel

all: kernel package

kernel:
	mkdir -p kernel/lib
	cp SEF/libbinio.lua kernel/lib
	cp SEF/libsef.lua kernel/lib
	cd kernel && lua ../SEF/makesef.lua

bootloader:
	moon makeloader.moon

package:
	mkdir -p package
	cp kernel/out.sef package/silcom
	cp compiled_bootloader.lua package/init.lua

clean:
	rm -rf kernel/lib
	rm compiled_bootloader.lua
	rm kernel/out.sef
	rm -rf package
