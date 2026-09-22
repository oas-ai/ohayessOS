cmake_minimum_required(VERSION 3.21)
project(ohayess_hmi VERSION 0.1 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(OAS_SDK_PROTO_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../sdk/proto" CACHE PATH "Directory containing the OAS protobuf schema")
if(NOT EXISTS "${OAS_SDK_PROTO_DIR}/oas/vehicle/v1/vehicle.proto")
  message(FATAL_ERROR "Set OAS_SDK_PROTO_DIR to the SDK proto directory")
endif()

find_package(Protobuf 3.20 REQUIRED)
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
qt_add_qml_module(ohayess-hmi
  URI OAS.HMI
  VERSION 1.0
  QML_FILES qml/Main.qml
)
target_link_libraries(ohayess-hmi PRIVATE Qt6::Quick oas-hmi-bridge)
install(TARGETS ohayess-hmi)

include(CTest)
if(BUILD_TESTING)
  add_executable(vehicle-state-bridge-test tests/vehicle_state_bridge_test.cpp)
  target_link_libraries(vehicle-state-bridge-test PRIVATE Qt6::Core oas-hmi-bridge oas-vehicle-proto)
  add_test(NAME vehicle-state-bridge COMMAND vehicle-state-bridge-test)
endif()
