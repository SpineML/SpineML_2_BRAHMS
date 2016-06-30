add_library(AnalogConstantInput SHARED component.cpp)
# This required?:
# component_la_LDFLAGS = -module -avoid-version

set_target_properties(AnalogConstantInput PROPERTIES OUTPUT_NAME "component" PREFIX "")
if(APPLE)
  # On MacOS, we need to inform clang that some symbols will not be available until runtime
  set_target_properties (AnalogConstantInput PROPERTIES LINK_FLAGS "-Wl,-undefined,dynamic_lookup")
endif(APPLE)

set(COMP_PATH ${LIB_DIR}/spineml-2-brahms/dev/SpineML/tools/AnalogConstantInput)
install(TARGETS AnalogConstantInput DESTINATION ${COMP_PATH}/brahms/0)
install(FILES release.xml DESTINATION ${COMP_PATH}/brahms/0)
