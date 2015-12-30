add_library(readOutputFile SHARED component.cpp)
# This required?:
# component_la_LDFLAGS = -module -avoid-version

set_target_properties(readOutputFile PROPERTIES OUTPUT_NAME "component" PREFIX "")
if(APPLE)
  # Anything special required for Apple?
  #target_link_libraries(data_numeric brahms-engine brahms-engine-base)
endif(APPLE)

set(COMP_PATH ${LIB_DIR}/spineml-2-brahms/dev/SpineML/tools/readOutputFile)
install(TARGETS readOutputFile DESTINATION ${COMP_PATH}/brahms/0)
install(FILES release.xml DESTINATION ${COMP_PATH}/brahms/0)
