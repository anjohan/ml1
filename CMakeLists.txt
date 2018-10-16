cmake_minimum_required(VERSION 3.9)
project(1)
enable_language(Fortran)

find_package(LAPACK REQUIRED)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

find_package(OpenMP)
if(OpenMP_Fortran_FOUND)
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${OpenMP_Fortran_FLAGS}")
endif()

if(CMAKE_Fortran_COMPILER_ID MATCHES GNU)
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -Wall -Wextra")
    set(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG} -fcheck=all")
    set(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE} -march=native")
endif()

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/regression)

file(GLOB prog_files ${CMAKE_CURRENT_SOURCE_DIR}/programs/*.f90)
foreach(prog_file ${prog_files})
    get_filename_component(prog_name ${prog_file} NAME_WE)
    add_executable(${prog_name} ${prog_file})
    target_link_libraries(${prog_name} regression)
endforeach(prog_file)
