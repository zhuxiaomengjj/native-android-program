# Native android runable cpp program
A hello world demo program to show you how to write native cpp program, and run it on android device
## Thanks
  From [here](http://stackoverflow.com/questions/9460251/how-do-i-build-a-native-command-line-executable-to-run-on-android) I find the solution, but it's c, not cpp.  
  In the cpp case, It's a lot of work, solving undefined references, find what lib must linked in, GOD, It's a nightmare. But it's done, you can pull and run.
## how to build and run
  make clean; make; make install; make run
  
## The origin author says:
files location:   
/home/dd/android/dev/native/test.c  
/home/dd/android/dev/native/Makefile  
The author then compiled and tested it with:
```bash
dd@abil:~/android/dev/native$ make clean; make; make install; make run
/home/dd/android/android-ndk-r5/toolchains/arm-eabi-4.4.0/prebuilt/linux-x86/bin//arm-eabi-gcc -c  -fno-short-enums -I/home/dd/android/android-ndk-r5/platforms/android-9/arch-arm/usr/include test.c -o test.o 
/home/dd/android/android-ndk-r5/toolchains/arm-eabi-4.4.0/prebuilt/linux-x86/bin//arm-eabi-g++ -Wl,--entry=main,-dynamic-linker=/system/bin/linker,-rpath-link=/home/dd/android/android-ndk-r5/platforms/android-9/arch-arm/usr/lib -L/home/dd/android/android-ndk-r5/platforms/android-9/arch-arm/usr/lib -nostdlib -lc -o test test.o
/home/dd/android/android-sdk-linux_86/platform-tools/adb push test /data/tmp/test 
45 KB/s (2545 bytes in 0.054s)
/home/dd/android/android-sdk-linux_86/platform-tools/adb shell chmod 777 /data/tmp/test
/home/dd/android/android-sdk-linux_86/platform-tools/adb shell /data/tmp/test
Hello, world (i=3)!
```
SDK and NDK used were:

source code: /home/dd/android/dev/native
android ndk: /home/dd/android/android-ndk-r5
android sdk: /home/dd/android/android-sdk-linux_86
However, the debug guide was the really good part ! Copy and pasted ...

Set the compile for enable debugging:
```
DEBUG = -g
CFLAGS := $(DEBUG) -fno-short-enums -I$(ANDROID_NDK_ROOT)/platforms/android-$(NDK_PLATFORM_VER)/arch-arm/usr/include
```
copy the gdbserver file ($(PREBUILD)/../gdbserver) to the emulator, add the target in Makefile than to make it easy:
```
debug-install:
        $(ANDROID_SDK_ROOT)/platform-tools/adb push $(PREBUILD)/../gdbserver $(INSTALL_DIR)/gdbserver
        $(ANDROID_SDK_ROOT)/platform-tools/adb shell chmod 777 $(INSTALL_DIR)/gdbserver
```
Now we will debug it @ port 1234:
```
debug-go:
        $(ANDROID_SDK_ROOT)/platform-tools/adb forward tcp:1234: tcp:1234
        $(ANDROID_SDK_ROOT)/platform-tools/adb shell $(INSTALL_DIR)/gdbserver :1234 $(INSTALL_DIR)/$(APP)
```
Then execute it:
```bash
dd@abil:~/android/dev/native$ make clean; make; make install; make debug-install; make debug-go
/home/dd/android/android-ndk-r5/toolchains/arm-eabi-4.4.0/prebuilt/linux-x86/bin//arm-eabi-gcc -c  -g -fno-short-enums -I/home/dd/android/android-ndk-r5/platforms/android-9/arch-arm/usr/include test.c -o test.o 
/home/dd/android/android-ndk-r5/toolchains/arm-eabi-4.4.0/prebuilt/linux-x86/bin//arm-eabi-g++ -Wl,--entry=main,-dynamic-linker=/system/bin/linker,-rpath-link=/home/dd/android/android-ndk-r5/platforms/android-9/arch-arm/usr/lib -L/home/dd/android/android-ndk-r5/platforms/android-9/arch-arm/usr/lib -nostdlib -lc -o test test.o
/home/dd/android/android-sdk-linux_86/platform-tools/adb push test /data/tmp/test 
71 KB/s (3761 bytes in 0.051s)
/home/dd/android/android-sdk-linux_86/platform-tools/adb shell chmod 777 /data/tmp/test
/home/dd/android/android-sdk-linux_86/platform-tools/adb push /home/dd/android/android-ndk-r5/toolchains/arm-eabi-4.4.0/prebuilt/linux-x86/../gdbserver /data/tmp/gdbserver
895 KB/s (118600 bytes in 0.129s)
/home/dd/android/android-sdk-linux_86/platform-tools/adb shell chmod 777 /data/tmp/gdbserver
/home/dd/android/android-sdk-linux_86/platform-tools/adb forward tcp:1234: tcp:1234
/home/dd/android/android-sdk-linux_86/platform-tools/adb shell /data/tmp/gdbserver :1234 /data/tmp/test
Process /data/tmp/test created; pid = 472
Listening on port 1234
```
Now open other console and execute the debugger:
```bash
dd@abil:~/android/dev/native$ make debug
/home/dd/android/android-ndk-r5/toolchains/arm-eabi-4.4.0/prebuilt/linux-x86/bin//arm-eabi-gdb test
GNU gdb 6.6
Copyright (C) 2006 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.
Type "show copying" to see the conditions.
There is absolutely no warranty for GDB.  Type "show warranty" for details.
This GDB was configured as "--host=x86_64-linux-gnu --target=arm-elf-linux"...
(gdb) target remote :1234
Remote debugging using :1234
warning: Unable to find dynamic linker breakpoint function.
GDB will be unable to debug shared library initializers
and track explicitly loaded dynamic code.
0xb0001000 in ?? ()
(gdb) b main
Breakpoint 1 at 0x82fc: file test.c, line 6.
(gdb) c
Continuing.
Error while mapping shared library sections:
/system/bin/linker: No such file or directory.
Error while mapping shared library sections:
libc.so: Success.

Breakpoint 1, main (argc=33512, argv=0x0) at test.c:6
6               int i = 1;
(gdb) n
7               i+=2;
(gdb) p i
$1 = 1
(gdb) n
9               printf("Hello, world (i=%d)!\n", i);
(gdb) p i
$2 = 3
(gdb) c
Continuing.

Program exited normally.
(gdb) quit
```
Well it is ok. And the other console will give additional output like so:
```bash
Remote debugging from host 127.0.0.1
gdb: Unable to get location for thread creation breakpoint: requested event is not supported
Hello, world (i=3)!

Child exited with retcode = 0 

Child exited with status 0
GDBserver exiting
```
