# Now replace the following:
add_library(allToAll SHARED component.cpp)
# This required?:
# component_la_LDFLAGS = -module -avoid-version

set_target_properties(allToAll PROPERTIES OUTPUT_NAME "component" PREFIX "")
if(APPLE)
  # Anything special required for Apple?
  #target_link_libraries(data_numeric brahms-engine brahms-engine-base)
endif(APPLE)

set(COMP_PATH ${LIB_DIR}/spineml-2-brahms/dev/SpineML/tools/allToAll)
install(TARGETS allToAll DESTINATION ${COMP_PATH}/brahms/0)
install(FILES release.xml DESTINATION ${COMP_PATH}/brahms/0)

# We don't really need to install build - that's just to rebuild the component.
#configure_file (build.in build)
#install(FILES build DESTINATION ${COMP_PATH}/brahms/0)