cmake_minimum_required(VERSION 3.8)

project(yarl)

file(GLOB HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h")
file(GLOB SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")

include_directories(${FastCG_INCLUDE_DIRS})

source_group("include" FILES ${HEADERS})
source_group("src" FILES ${SOURCES})

fastcg_add_executable(${PROJECT_NAME} ${HEADERS} ${SOURCES})
set_target_properties(${PROJECT_NAME} PROPERTIES 
    POSITION_INDEPENDENT_CODE CXX
    LINKER_LANGUAGE CXX
)