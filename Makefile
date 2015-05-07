APP := test
ROOT := $(NDK) 
INSTALL_DIR := /data/tmp
NDK_PLATFORM_VER := 14

ANDROID_NDK_ROOT := $(NDK)
ANDROID_NDK_HOST := darwin-x86_64
#ANDROID_SDK_ROOT := $(ANDROID_SDK_ROOT)
PREBUILD := $(ANDROID_NDK_ROOT)/toolchains/arm-linux-androideabi-4.9/prebuilt/$(ANDROID_NDK_HOST)
PREBUILD2 := $(ANDROID_NDK_ROOT)/prebuilt/android-arm

BIN := $(PREBUILD)/bin
LIB := $(ANDROID_NDK_ROOT)/platforms/android-$(NDK_PLATFORM_VER)/arch-arm/usr/lib
INCLUDE := $(ANDROID_NDK_ROOT)/platforms/android-$(NDK_PLATFORM_VER)/arch-arm/usr/include

CC := $(BIN)/arm-linux-androideabi-gcc
CXX := $(BIN)/arm-linux-androideabi-g++
GDB_CLIENT := $(BIN)/arm-linux-androideabi-gdb

LIBCRT := $(LIB)/crtbegin_dynamic.o $(LIB)/crtend_so.o
STL := $(ANDROID_NDK_ROOT)/sources/cxx-stl/gnu-libstdc++/4.9

LINKER := /system/bin/linker

DEBUG := -g

CFLAGS := $(DEBUG) -fno-short-enums -std=c++11 -I$(INCLUDE)
CFLAGS += -Wl,-rpath-link=$(LIB),-dynamic-linker=$(LINKER) -L$(LIB) -I$(STL)/include -L$(STL)/libs/armeabi -I$(STL)/libs/armeabi/include -L$(PREBUILD)/arm-linux-androideabi/lib/ 
CFLAGS += -nostdlib -lc -lgnustl_static -lgcc

all: $(APP)

$(APP): $(APP).cpp
		$(CXX) -o $@ $< $(CFLAGS) $(LIBCRT)

install: $(APP)
	$(ANDROID_SDK_ROOT)/platform-tools/adb push $(APP) $(INSTALL_DIR)/$(APP)
	$(ANDROID_SDK_ROOT)/platform-tools/adb shell chmod 777 $(INSTALL_DIR)/$(APP)

shell:
	$(ANDROID_SDK_ROOT)/platform-tools/adb shell

run:
	$(ANDROID_SDK_ROOT)/platform-tools/adb shell $(INSTALL_DIR)/$(APP)

debug-install:
	$(ANDROID_SDK_ROOT)/platform-tools/adb push $(PREBUILD2)/gdbserver/gdbserver $(INSTALL_DIR)/gdbserver
	$(ANDROID_SDK_ROOT)/platform-tools/adb shell chmod 777 $(INSTALL_DIR)/gdbserver

debug-go:
	$(ANDROID_SDK_ROOT)/platform-tools/adb forward tcp:1234: tcp:1234
	$(ANDROID_SDK_ROOT)/platform-tools/adb shell $(INSTALL_DIR)/gdbserver :1234 $(INSTALL_DIR)/$(APP)

debug:
	$(GDB_CLIENT) $(APP)

clean:
	@rm -f $(APP).o $(APP)
