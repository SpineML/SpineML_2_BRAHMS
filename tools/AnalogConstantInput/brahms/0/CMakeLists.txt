add_library(AnalogConstantInput SHARED component.cpp)
# This required?:
# component_la_LDFLAGS = -module -avoid-version

set_target_properties(AnalogConstantInput PROPERTIES OUTPUT_NAME "component" PREFIX "")
if(APPLE)
  # Anything special required for Apple?
  #target_link_libraries(data_numeric brahms-engine brahms-engine-base)
endif(APPLE)

set(COMP_PATH ${LIB_DIR}/spineml-2-brahms/dev/SpineML/tools/AnalogConstantInput)
install(TARGETS AnalogConstantInput DESTINATION ${COMP_PATH}/brahms/0)
install(FILES release.xml DESTINATION ${COMP_PATH}/brahms/0)
