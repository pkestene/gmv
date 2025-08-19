#
# Generate gmv_config.h
#
set(GMV_HAS_GIT_INFO "TRUE")

find_package(Git QUIET)

if(GIT_FOUND)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} describe --abbrev=0 --match=v[0-9]*
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE GMV_GIT_TAG
    RESULT_VARIABLE GMV_GIT_TAG_FOUND
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  if(GMV_GIT_TAG_FOUND EQUAL 0)
    execute_process(
      COMMAND ${GIT_EXECUTABLE} reflog -1 "--format=%H"
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      OUTPUT_VARIABLE GMV_GIT_HASH
      OUTPUT_STRIP_TRAILING_WHITESPACE)

    execute_process(
      COMMAND ${GIT_EXECUTABLE} symbolic-ref HEAD
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      OUTPUT_VARIABLE GMV_GIT_HEAD
      OUTPUT_STRIP_TRAILING_WHITESPACE)

    execute_process(
      COMMAND ${GIT_EXECUTABLE} diff-index --quiet HEAD
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      RESULT_VARIABLE GMV_GIT_DIFF_STATE
      OUTPUT_STRIP_TRAILING_WHITESPACE)

    if(GMV_GIT_DIFF_STATE EQUAL 0)
      set(GMV_GIT_HAS_LOCAL_CHANGES "CLEAN")
      set(GMV_GIT_IS_CLEAN true)
    else()
      set(GMV_GIT_IS_CLEAN false)
      set(GMV_GIT_HAS_LOCAL_CHANGES "DIRTY")
    endif()

    execute_process(
      COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      OUTPUT_VARIABLE GMV_GIT_BRANCH
      OUTPUT_STRIP_TRAILING_WHITESPACE)

    execute_process(
      COMMAND ${GIT_EXECUTABLE} config --get branch.${GIT_BRANCH}.remote
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      OUTPUT_VARIABLE GMV_GIT_REMOTE
      OUTPUT_STRIP_TRAILING_WHITESPACE)

    execute_process(
      COMMAND ${GIT_EXECUTABLE} config --get remote.${GIT_REMOTE}.url
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      OUTPUT_VARIABLE GMV_GIT_REMOTE_URL
      OUTPUT_STRIP_TRAILING_WHITESPACE)
  else()
    unset(GMV_HAS_GIT_INFO)
  endif()
else()
  unset(GMV_HAS_GIT_INFO)
endif()

execute_process(
  COMMAND date "+%d/%m/%y"
  OUTPUT_VARIABLE GMV_COMPILE_DATE
  OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process(
  COMMAND date "+%H:%M:%S"
  OUTPUT_VARIABLE GMV_COMPILE_TIME
  OUTPUT_STRIP_TRAILING_WHITESPACE)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
  set(RELEASE_BUILD True)
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(GMV_ENABLE_DEBUG 1)
endif()

message("Generating gmv_version.h")
configure_file(${PROJECT_SOURCE_DIR}/gmv_version.h.in
               ${PROJECT_BINARY_DIR}/gmv_version.h)

message("Generating gmv_config.h")
configure_file(${PROJECT_SOURCE_DIR}/gmv_config.h.cmake.in
               ${PROJECT_BINARY_DIR}/gmv_config.h @ONLY)
