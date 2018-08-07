THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
ARCHS = armv7
TARGET = iphone:latest:8.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HaLuoTweakProject
HaLuoTweakProject_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 EasyBike"


clean::
		rm -rf ./packages/*
		rm -rf ./obj/*
