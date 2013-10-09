# -*- Mode: makefile-gmake; indent-tabs-mode: t; tab-width: 2 -*-
#
# build.mk --- Build rules for the smaccmpilot library.
#
# Copyright (C) 2012, Galois, Inc.
# All Rights Reserved.
#
# This software is released under the "BSD3" license.  Read the file
# "LICENSE" for more information.
#
# Written by Pat Hickey <pat@galois.com>, 17 Jan 2013
#

FLIGHT_PLATFORMS_FREERTOS := px4fmu17_ioar_freertos px4fmu17_bare_freertos
FLIGHT_PLATFORMS_AADL := px4fmu17_ioar_aadl

IVORY_PKG_FLIGHT_GEN_SYMS    := true

$(eval $(call when_platforms, $(FLIGHT_PLATFORMS_FREERTOS) $(FLIGHT_PLATFORMS_AADL) \
				,tower_pkg,IVORY_PKG_FLIGHT,flight-gen))

FLIGHT_IMG       := flight

FLIGHT_INCLUDES  += $(HWF4_INCLUDES)
FLIGHT_INCLUDES  += -I$(TOP)/src/standalone_apahrs
FLIGHT_INCLUDES  += -I$(TOP)/src/apwrapper/include
FLIGHT_INCLUDES  += $(FREERTOS_CFLAGS)
FLIGHT_INCLUDES  += $(IVORY_PKG_FLIGHT_CFLAGS)

# For the cryto lib
FLIGHT_INCLUDES  += -I$(TOP)/src/crypto/include
FLIGHT_INCLUDES  += -DARM

FLIGHT_CFLAGS    += $(FLIGHT_INCLUDES)
FLIGHT_CFLAGS    += -DIVORY_TEST

FLIGHT_CXXFLAGS  += $(FLIGHT_INCLUDES)
FLIGHT_CXXFLAGS  += -Wno-psabi

FLIGHT_OBJECTS := main.o

FLIGHT_REAL_OBJECTS += $(IVORY_PKG_FLIGHT_OBJECTS)

FLIGHT_LIBRARIES    += libapwrapper.a
FLIGHT_LIBRARIES    += libstandalone-apahrs.a
FLIGHT_LIBRARIES    += libstandalone-aphal.a
FLIGHT_LIBRARIES    += libhwf4-nouart.a
FLIGHT_LIBRARIES    += libFreeRTOS.a
FLIGHT_LIBRARIES    += commsec.a
FLIGHT_LIBS         += -lm

$(eval $(call when_platforms,$(FLIGHT_PLATFORMS_FREERTOS) \
				,cbmc_pkg,FLIGHT,IVORY_PKG_FLIGHT))

$(eval $(call when_platforms,$(FLIGHT_PLATFORMS_FREERTOS) \
				,image,FLIGHT))

# ------------------------------------------------------------------------------
# AADL Build
# ------------------------------------------------------------------------------

LIB_FLIGHT_LIB          := libflight.a
LIB_FLIGHT_INCLUDES     += $(HWF4_INCLUDES)
LIB_FLIGHT_INCLUDES     += -I$(TOP)/src/standalone_apahrs
LIB_FLIGHT_INCLUDES     += -I$(TOP)/src/crypto/include
LIB_FLIGHT_INCLUDES     += -DARM
LIB_FLIGHT_INCLUDES     += -I$(TOP)/src/apwrapper/include
LIB_FLIGHT_REAL_OBJECTS += $(call filteroutstring,tower_task_loop_, \
                                      $(IVORY_PKG_FLIGHT_OBJECTS))
LIB_FLIGHT_CFLAGS       += $(LIB_FLIGHT_INCLUDES)
LIB_FLIGHT_CFLAGS       += $(IVORY_PKG_FLIGHT_CFLAGS)
LIB_FLIGHT_CFLAGS       += -DIVORY_DEPLOY

$(eval $(call when_platforms,$(FLIGHT_PLATFORMS_AADL),library,LIB_FLIGHT))

# vim: set ft=make noet ts=2:
