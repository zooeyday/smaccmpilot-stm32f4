# -*- Mode: makefile-gmake; indent-tabs-mode: t; tab-width: 8 -*-
#
# ivory.mk --- Compiling generated Ivory packages.
#
# Copyright (C) 2012, Galois, Inc.
# All Rights Reserved.
#
# This software is released under the "BSD3" license.  Read the file
# "LICENSE" for more information.
#
# Written by Lee Pike <leepike@galois.com>

# Model-check C code from C sources and headers.

# $(1) -- Image prefix (what you call image.mk with)
# $(2) -- Ivory package prefix (what you call ivory.mk with)

CBMC_EXEC     := $(addprefix $(CONFIG_CBMC_PREFIX)/, cbmc)
CBMC_REPORTER := $(addprefix $(CONFIG_CBMC_REPORT)/, cbmc-reporter)

define cbmc_pkg

# MAKEFILE_LIST is a built-in variable getting the names of included makefiles.
# This gets the most recent include.
$(1)_PREFIX       := $(dir $(lastword $(filter %/build.mk,$(MAKEFILE_LIST))))
$(1)_CBMC_DIR     := $$(CBMC_DIR)/$$($(1)_PREFIX)
$(1)_CBMC_MD      := $$($(1)_CBMC_DIR)/claims-table.md
$(1)_CBMC_HTML    := $$($(1)_CBMC_DIR)/claims-table.html
$(1)_CBMC_SRCS    := $$(patsubst %, --src=%, $$($(2)_SOURCES))
# $(2)_SYMS is generated by the XXX_GEN_SYMS target defined in ivory.mk.
$(1)_ENTRY_FUNCS  := $$(patsubst %, --function=%, $$($(2)_SYMS))
# XXX Hack because we have CFLAGS in our INCLUDES
$(1)_INCLS        := $$(filter -I%, $$($(1)_INCLUDES))

# All the CBMC HTML (the final output) targets
CBMC += $$($(1)_CBMC_HTML)

# May not exist, fails silently.  IVORY_PKG_$(1)_HEADERS, IVORY_PKG_$(1)_SOURCES
# defined here.
-include $$($(1)_DEP_FILE)

$$($(1)_CBMC_MD): $$($(2)_DEP_FILE)
	 $(CBMC_REPORTER) \
            --outfile=$$@ \
            --format=markdown \
	   --timeout=1 \
	   --no-asserts \
	   --threads=2 \
	   --sort=result \
	   --cbmc=$(CBMC_EXEC) \
           $$($(1)_INCLS) \
	   $$($(1)_CBMC_SRCS) \
	   $$($(1)_ENTRY_FUNCS) \
	   -- -D IVORY_CBMC


$$($(1)_CBMC_HTML): $$($(1)_CBMC_MD)
	# Now make an HTML table.
	pandoc -o $$@ $$<

endef

# vim: set ft=make noet ts=2:
