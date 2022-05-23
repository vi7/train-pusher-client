#
# This is a project Makefile. It is assumed the directory this Makefile resides in is a
# project subdirectory.
#

PROJECT_NAME := train-pusher-client
ESPPORT := $(shell ls -1 /dev/cu.usbserial*)

include $(IDF_PATH)/make/project.mk