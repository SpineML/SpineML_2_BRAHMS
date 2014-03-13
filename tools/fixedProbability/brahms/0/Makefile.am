CLEANFILES = *~
AM_CPPFLAGS = $(BRAHMS_WARNING_CPPFLAGS) $(BRAHMS_HOST_DEFINITION) $(BRAHMS_CFLAGS) \
              -I$(top_srcdir) -I$(top_srcdir)/include \
              -I$(BRAHMS_INCLUDE_DIR) -I$(BRAHMS_NAMESPACE_DIR)

# This sets the path into which component.so etc will be installed
libdir=@libdir@/spineml-2-brahms/fixedProbability/brahms/0

lib_LTLIBRARIES = component.la
component_la_SOURCES = component.cpp
component_la_LDFLAGS = -module -avoid-version

EXTRA_DIST = release.xml
xmldir=@libdir@/spineml-2-brahms/fixedProbability/brahms/0
xml_DATA = $(EXTRA_DIST)
