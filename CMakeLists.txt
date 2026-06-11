cmake_minimum_required(VERSION 3.16)

project(MachineVision VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)


find_package(Qt6 REQUIRED COMPONENTS Quick SerialBus)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appMachineVision
    main.cpp
)

qt_add_qml_module(appMachineVision
    URI MachineVision
    QML_FILES
        Main.qml
        QML_FILES qml/TopBar.qml
        RESOURCES res/res.qrc
        QML_FILES qml/MainContent.qml
        QML_FILES qml/ImageWindow.qml
        QML_FILES qml/RunView.qml
        QML_FILES qml/ConnectionView.qml
        QML_FILES qml/AlgoDialog.qml
        QML_FILES qml/BottomBar.qml
        QML_FILES qml/ConnectionSetting.qml
        QML_FILES qml/LayoutSetting.qml
        QML_FILES qml/GlobalScript.qml
        QML_FILES qml/GlobalVariable.qml
)

qt_add_qml_module(systemMonitor
    URI com.lcy.systemMonitor
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/com/lcy/systemMonitor
    SOURCES src/SystemMonitor.cpp src/SystemMonitor.h
)

target_include_directories(systemMonitor PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

qt_add_qml_module(ConnectionManager
    URI com.lcy.connectionManager
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/com/lcy/connectionManager
    SOURCES
    src/AbstractConnection.cpp src/AbstractConnection.h
    src/ModbusTcpClient.cpp src/ModbusTcpClient.h
    src/SerialConnection.cpp src/SerialConnection.h
    src/CameraConnection.cpp src/CameraConnection.h
    src/ConnectionManager.cpp src/ConnectionManager.h
)

target_include_directories(ConnectionManager PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(ConnectionManager
    PRIVATE Qt6::SerialBus Qt6::Gui
)

qt_add_qml_module(AlgorithmManager
    URI com.lcy.algorithmManager
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/com/lcy/algorithmManager
    SOURCES
    src/AbstractAlgorithm.cpp src/AbstractAlgorithm.h
    src/DefaultAlgorithm.cpp src/DefaultAlgorithm.h
    src/AlgorithmManager.cpp src/AlgorithmManager.h
    src/AlgorithmScriptEngine.cpp src/AlgorithmScriptEngine.h
    src/ScriptApi.h src/ScriptApi.cpp
    src/FileConfig.h src/FileConfig.cpp
    src/ScriptManager.h src/ScriptManager.cpp
    src/GlobalVariableManager.h src/GlobalVariableManager.cpp
    src/Logger.h src/Logger.cpp
)

target_include_directories(AlgorithmManager PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(AlgorithmManager
    PRIVATE Qt6::Gui
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appMachineVision PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appMachineVision
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appMachineVision
    PRIVATE Qt6::Quick systemMonitor ConnectionManager AlgorithmManager
)

include(GNUInstallDirs)
install(TARGETS appMachineVision
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
