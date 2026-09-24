cmake_minimum_required(VERSION 3.21)
project(ohayess_hmi VERSION 0.1 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(OAS_SDK_PROTO_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../sdk/proto" CACHE PATH "Directory containing the OAS protobuf schema")
if(NOT EXISTS "${OAS_SDK_PROTO_DIR}/oas/vehicle/v1/vehicle.proto")
  message(FATAL_ERROR "Set OAS_SDK_PROTO_DIR to the SDK proto directory")
endif()

find_package(Protobuf CONFIG QUIET)
if(NOT TARGET protobuf::libprotobuf)
  find_package(Protobuf 3.20 REQUIRED)
endif()
find_package(Qt6 6.2 REQUIRED COMPONENTS Quick)
qt_standard_project_setup()

add_library(oas-vehicle-proto STATIC)
target_sources(oas-vehicle-proto PRIVATE "${OAS_SDK_PROTO_DIR}/oas/vehicle/v1/vehicle.proto")
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/generated")
protobuf_generate(TARGET oas-vehicle-proto LANGUAGE cpp PROTOC_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated" IMPORT_DIRS "${OAS_SDK_PROTO_DIR}")
target_include_directories(oas-vehicle-proto PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/generated")
target_link_libraries(oas-vehicle-proto PUBLIC protobuf::libprotobuf)

add_library(oas-hmi-bridge STATIC src/vehicle_state_bridge.cpp)
target_include_directories(oas-hmi-bridge PUBLIC src)
target_link_libraries(oas-hmi-bridge PUBLIC Qt6::Core oas-vehicle-proto)

qt_add_executable(ohayess-hmi src/main.cpp)

# Design system singletons: tokens, routes and domain providers.
set(OAS_QML_SINGLETONS qml/Tokens.qml qml/Nav.qml qml/Providers.qml)
set_source_files_properties(${OAS_QML_SINGLETONS} PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

set(OAS_QML_FOUNDATION
  qml/Icon.qml qml/Panel.qml qml/Caption.qml qml/Divider.qml qml/Readout.qml
  qml/StatusBadge.qml qml/EmptyState.qml)

set(OAS_QML_CONTROLS
  qml/OasButton.qml qml/OasIconButton.qml qml/OasToggle.qml qml/OasSlider.qml
  qml/OasSegmented.qml qml/OasStepper.qml)

set(OAS_QML_SHELL
  qml/StatusRail.qml qml/ControlDock.qml qml/SidePanel.qml qml/OasModal.qml
  qml/Toast.qml qml/NotificationItem.qml qml/CriticalOverlay.qml qml/CategoryTile.qml)

set(OAS_QML_DOMAIN
  qml/VehicleVisual.qml qml/VehicleStatusIndicator.qml qml/TempZone.qml
  qml/MediaMiniPlayer.qml qml/NavInstruction.qml qml/MapSurface.qml)

set(OAS_QML_SCREENS
  qml/ScreenHome.qml qml/ScreenNavigation.qml qml/ScreenClimate.qml qml/ScreenMedia.qml
  qml/ScreenPhone.qml qml/ScreenCamera.qml qml/ScreenVehicle.qml qml/ScreenSettings.qml
  qml/ScreenAdas.qml qml/ScreenEnergy.qml qml/ScreenSoftware.qml qml/ScreenDiagnostics.qml)

qt_add_qml_module(ohayess-hmi
  URI OAS.HMI
  VERSION 1.0
  RESOURCE_PREFIX /
  QML_FILES
    qml/Main.qml
    ${OAS_QML_SINGLETONS}
    ${OAS_QML_FOUNDATION}
    ${OAS_QML_CONTROLS}
    ${OAS_QML_SHELL}
    ${OAS_QML_DOMAIN}
    ${OAS_QML_SCREENS}
)
target_link_libraries(ohayess-hmi PRIVATE Qt6::Quick oas-hmi-bridge)
install(TARGETS ohayess-hmi)

include(CTest)
if(BUILD_TESTING)
  add_executable(vehicle-state-bridge-test tests/vehicle_state_bridge_test.cpp)
  target_link_libraries(vehicle-state-bridge-test PRIVATE Qt6::Core oas-hmi-bridge oas-vehicle-proto)
  add_test(NAME vehicle-state-bridge COMMAND vehicle-state-bridge-test)
  set(OAS_RENDER_GUARD "ReferenceError;TypeError;Unable to assign;failed to load;is not installed;does not support customization;Cannot assign;is not a type;Binding loop")

  # Vehicle state scenarios at the smallest supported display.
  foreach(scenario drive park waiting stale)
    add_test(NAME hmi-${scenario} COMMAND ohayess-hmi --demo --scenario ${scenario} --size 1280x720 --capture ${CMAKE_CURRENT_BINARY_DIR}/${scenario}.png)
  endforeach()
  add_test(NAME hmi-injected-park COMMAND ohayess-hmi --demo --scenario drive --demo-speed-kph 0 --demo-gear P --size 1280x720 --capture ${CMAKE_CURRENT_BINARY_DIR}/injected-park.png)
  add_test(NAME hmi-light COMMAND ohayess-hmi --demo --appearance light --size 1280x720 --capture ${CMAKE_CURRENT_BINARY_DIR}/light.png)

  # Every one of the twelve screens renders, in both themes for the busiest ones.
  foreach(page home navigation climate media phone camera vehicle settings adas energy software diagnostics)
    add_test(NAME hmi-${page} COMMAND ohayess-hmi --demo --scenario park --page ${page} --size 1920x1080 --capture ${CMAKE_CURRENT_BINARY_DIR}/${page}.png)
  endforeach()
  foreach(page home climate vehicle)
    add_test(NAME hmi-light-${page} COMMAND ohayess-hmi --demo --scenario park --page ${page} --appearance light --size 1920x1080 --capture ${CMAKE_CURRENT_BINARY_DIR}/light-${page}.png)
  endforeach()

  # Adaptive layout must hold at every supported display geometry.
  add_test(NAME hmi-compact-720p COMMAND ohayess-hmi --demo --scenario drive --page home --size 1280x720 --capture ${CMAKE_CURRENT_BINARY_DIR}/compact-720p.png)
  add_test(NAME hmi-regular-1080p COMMAND ohayess-hmi --demo --scenario drive --page home --size 1920x1080 --capture ${CMAKE_CURRENT_BINARY_DIR}/regular-1080p.png)
  add_test(NAME hmi-wide-1440p COMMAND ohayess-hmi --demo --scenario drive --page home --size 2560x1440 --capture ${CMAKE_CURRENT_BINARY_DIR}/wide-1440p.png)
  add_test(NAME hmi-ultrawide COMMAND ohayess-hmi --demo --scenario drive --page home --size 3840x1200 --capture ${CMAKE_CURRENT_BINARY_DIR}/ultrawide.png)

  # Reverse gear is the only automatic screen change in the system.
  add_test(NAME hmi-reverse-surfaces-camera COMMAND ohayess-hmi --demo --scenario park --demo-gear R --demo-speed-kph 2 --page home --expect-page camera --size 1920x1080 --capture ${CMAKE_CURRENT_BINARY_DIR}/reverse-camera.png)

  get_property(OAS_RENDER_TESTS DIRECTORY PROPERTY TESTS)
  foreach(test ${OAS_RENDER_TESTS})
    if(NOT test STREQUAL "vehicle-state-bridge")
      set_tests_properties(${test} PROPERTIES
        ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_BACKEND=software"
        TIMEOUT 30
        FAIL_REGULAR_EXPRESSION "${OAS_RENDER_GUARD}")
    endif()
  endforeach()
endif()
