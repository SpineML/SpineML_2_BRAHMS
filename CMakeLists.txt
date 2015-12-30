cmake_minimum_required(VERSION 2.8.6)
project(SpineML_2_BRAHMS)

message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "  (This can be changed with `cmake -DCMAKE_INSTALL_PREFIX=/some/place`")

# Set up some directory variables
set(DATA_DIR ${CMAKE_INSTALL_PREFIX}/share/spineml-2-brahms)
set(INCLUDE_DIR ${CMAKE_INSTALL_PREFIX}/include)
set(MAN_DIR ${CMAKE_INSTALL_PREFIX}/share/man)
set(BIN_DIR ${CMAKE_INSTALL_PREFIX}/bin)
set(LIB_DIR ${CMAKE_INSTALL_PREFIX}/lib)

# From CMAKE_SYSTEM work out which of __OSX__, __GLN__, __NIX__ or
# __WIN__ are required
message(STATUS "Operating system: " ${CMAKE_SYSTEM})
if(CMAKE_SYSTEM MATCHES Linux.*)
  set(BRAHMS_HOST_DEFINITION "-D__GLN__")
elseif(CMAKE_SYSTEM MATCHES BSD.*)
  set(BRAHMS_HOST_DEFINITION "-D__NIX__")
elseif(APPLE)
  set(BRAHMS_HOST_DEFINITION "-D__OSX__")
elseif(CMAKE_SYSTEM MATCHES Win.*)
  set(BRAHMS_HOST_DEFINITION "-D__WIN__")
else()
  message(ERROR "Operating system not supported: " ${CMAKE_SYSTEM})
endif()

# CMake configuration header
configure_file (
  "${PROJECT_SOURCE_DIR}/spineml-2-brahmsConfig.h.in"
  "${PROJECT_BINARY_DIR}/spineml-2-brahmsConfig.h"
)

# So that spineml-2-brahmsConfig.h gets included during build
include_directories ("${CMAKE_BINARY_DIR}")

# Ensure the spineml-2-brahmsConfig.h header gets installed
install(FILES ${CMAKE_BINARY_DIR}/spineml-2-brahmsConfig.h DESTINATION ${INCLUDE_DIR})

# Options.
option(WARNINGS_ARE_ERRORS "whether gcc should treat all warnings as errors" ON)
if(WARNINGS_ARE_ERRORS)
  set(BRAHMS_WARNING_CPPFLAGS "-Wall -Werror")
  message(STATUS "Adding -Wall -Werror to g++ to treat all warnings as errors")
  message(STATUS "  (This can be disabled with `cmake -DWARNINGS_ARE_ERRORS=OFF`")
else()
  set(BRAHMS_WARNING_CPPFLAGS "")
endif(WARNINGS_ARE_ERRORS)

# brahms headers, libs and namespace locations
set(BRAHMS_INCLUDE_DIR "/usr/include"
  CACHE STRING "Location of the BRAHMS headers (brahms-1199.h etc).")
message(STATUS "BRAHMS include directory (for brahms-1199.h etc) set to ${BRAHMS_INCLUDE_DIR}")
message(STATUS "  (This can be changed with `cmake -DBRAHMS_INCLUDE_DIR:STRING=/path/to/include`")
set(BRAHMS_NAMESPACE_DIR "/var/lib/SystemML/Namespace"
  CACHE STRING "Location of the BRAHMS Namespace.")
message(STATUS "BRAHMS Namespace directory set to ${BRAHMS_NAMESPACE_DIR}")
message(STATUS "  (This can be changed with `cmake -DBRAHMS_NAMESPACE_DIR:STRING=/path/to/SystemML/Namespace`")

# Set CFLAGS etc
set(CMAKE_CXX_FLAGS "${BRAHMS_WARNING_CPPFLAGS} ${BRAHMS_HOST_DEFINITION}")
set(CMAKE_C_FLAGS "${BRAHMS_WARNING_CPPFLAGS} ${BRAHMS_HOST_DEFINITION}")

# rng.h and impulse.h are in an include directory
include_directories (${PROJECT_SOURCE_DIR}/include ${BRAHMS_INCLUDE_DIR} ${BRAHMS_NAMESPACE_DIR})

# There are files to install in xsl:
add_subdirectory(xsl)
# The "standard" components are compiled in tools (this is quite optional):
add_subdirectory(tools)
# We need to install rng.h etc too, so:
add_subdirectory(include)

# Install files in the root directory:
install(FILES errorMsgLookup.txt DESTINATION ${DATA_DIR})
install(PROGRAMS convert_script_s2b DESTINATION ${BIN_DIR})
install(FILES convert_script_s2b.1 DESTINATION ${MAN_DIR}/man1)

# For debugging of variables:
set(DEBUG_VARIABLES OFF)
if(DEBUG_VARIABLES)
  get_cmake_property(_variableNames VARIABLES)
  foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
  endforeach()
endif(DEBUG_VARIABLES)
