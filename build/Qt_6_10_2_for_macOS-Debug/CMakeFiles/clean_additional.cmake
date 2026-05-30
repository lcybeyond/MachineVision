# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/appMachineVision_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/appMachineVision_autogen.dir/ParseCache.txt"
  "CMakeFiles/systemMonitor_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/systemMonitor_autogen.dir/ParseCache.txt"
  "CMakeFiles/systemMonitorplugin_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/systemMonitorplugin_autogen.dir/ParseCache.txt"
  "appMachineVision_autogen"
  "systemMonitor_autogen"
  "systemMonitorplugin_autogen"
  )
endif()
