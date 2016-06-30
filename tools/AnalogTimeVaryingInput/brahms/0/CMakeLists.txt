# Now replace the following:
add_library(AnalogTimeVaryingInput SHARED component.cpp)
# This required?:
# component_la_LDFLAGS = -module -avoid-version

set_target_properties(AnalogTimeVaryingInput PROPERTIES OUTPUT_NAME "component" PREFIX "")
if(APPLE)
  # On MacOS, we need to inform clang that some symbols will not be available until runtime
  set_target_properties (AnalogTimeVaryingInput PROPERTIES LINK_FLAGS "-Wl,-undefined,dynamic_lookup")
endif(APPLE)

set(COMP_PATH ${LIB_DIR}/spineml-2-brahms/dev/SpineML/tools/AnalogTimeVaryingInput)
install(TARGETS AnalogTimeVaryingInput DESTINATION ${COMP_PATH}/brahms/0)
install(FILES release.xml DESTINATION ${COMP_PATH}/brahms/0)
