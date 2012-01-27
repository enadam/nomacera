#
# nomacera Makefile -- generic, reusable Makefile
#
# All configuration goes to Makefile.vars.
#

# Defaults
CC	:= cc
CFLAGS	:= -Wall
PREFIX	:= usr

target_from_basename	= $(basename $(1))
target_from_firstword	= $(firstword $(subst ., ,$(1)))
target_from_underscored	= $(subst .,_,$(1))
fname_to_target		= $(target_from_firstword)

all:
include Makefile.vars
TARGETS	:= $(TARGET_LIBS) $(TARGET_BINS) $(TARGET_LNKS)

ifneq ($(filter debug,$(CONFIG)),)
CFLAGS	+= -g
else
CFLAGS	+= -O2
LDFLAGS	+= -s
endif

tvar = $($(1)_$(call fname_to_target,$(2)))
ddir = $(if $(DESTDIR),$(DESTDIR)/$(1),/$(1))

# Commands and rules
all: $(TARGETS)

install_%: %
	mkdir -p $(call ddir,$(call tvar,INSTDIR,$<));
	cp -a $< $(call ddir,$(call tvar,INSTDIR,$<));
ifneq ($(TARGET_LIBS),)
$(TARGET_LIBS):
	$(CC) -shared $(CFLAGS) -fPIC $(call tvar,CFLAGS,$@) $(LDFLAGS) $(call tvar,LDFLAGS,$@) $^ -o $@;
	chmod -x $@;
endif
ifneq ($(TARGET_BINS),)
$(TARGET_BINS):
	$(CC) $(CFLAGS) $(call tvar,CFLAGS,$@) $(LDFLAGS) $(call tvar,LDFLAGS,$@) $^ -o $@;
endif

ifneq ($(TARGET_LNKS),)
$(TARGET_LNKS):
	ln $(call tvar,LNFLAGS,$@) $@;
endif

install: $(patsubst %,install_%,$(TARGETS))

clean:
	rm -f $(TARGETS);

.PHONY: all install clean

# End of Makefile
