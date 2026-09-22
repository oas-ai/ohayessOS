cmake_minimum_required(VERSION 3.21)
project(ohayess_hmi VERSION 0.1 LANGUAGES CXX)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick)
qt_standard_project_setup()

qt_add_executable(ohayess-hmi src/main.cpp)
qt_add_qml_module(ohayess-hmi
  URI OAS.HMI
  VERSION 1.0
  QML_FILES qml/Main.qml
)
target_link_libraries(ohayess-hmi PRIVATE Qt6::Quick)
install(TARGETS ohayess-hmi)
