cmake_minimum_required(VERSION 3.18)

if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.13.0")
  message(STATUS "Setting policy CMP0076 to use new behavior")
  cmake_policy(SET CMP0076 NEW)
endif()

# CMake 3.24 and above prefers to set the timestamps of all extracted contents to the time of the
# extraction.
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.24)
  cmake_policy(SET CMP0135 NEW)
endif()

set(GMV_VERSION "4.6.2")

# deduce GMV_SHORT_VERSION using regex
string(REGEX MATCH "^[0-9]+\.[0-9]+\.[0-9]+" GMV_SHORT_VERSION ${GMV_VERSION})
if("${GMV_SHORT_VERSION}" STREQUAL "")
  message(FATAL_ERROR "Unable to compute short version from GMV_VERSION=${GMV_VERSION}")
endif()

project(
  gmv
  VERSION ${GMV_SHORT_VERSION}
  LANGUAGES C)

# project_name in small caps
string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_SC)

#
# default local cmake macro repository
#
list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

#
# Prevent from build in source tree
#
include(cmake/prevent_build_in_source.cmake)
prevent_build_in_source()

#
# Init build type: Release, Debug, ... (default is Release)
#
include(cmake/initBuildType.cmake)

# always export compile commands database
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#
# gmv options
#
include(cmake/options.cmake)

#
# gmv developer settings
#

add_library(gmv_warnings INTERFACE)

include(cmake/CompilerWarnings.cmake)

if(GMV_ENABLE_WARNINGS)
  gmv_set_project_warnings(
    gmv_warnings
    ${GMV_ENABLE_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    ""
    "")
else()
  gmv_set_project_warnings(
    gmv_warnings
    ${GMV_ENABLE_WARNINGS_AS_ERRORS}
    CLANG_C_WARNINGS_DEFAULT
    CLANG_CXX_WARNINGS_DEFAULT
    GCC_C_WARNINGS_DEFAULT
    GCC_CXX_WARNINGS_DEFAULT
    CUDA_WARNINGS_DEFAULT)
endif()
add_library(gmv::warnings ALIAS gmv_warnings)

#
# Build or find nvtx3 ?
#
#include(cmake/build_or_find_nvtx3.cmake)

#
# check other dependencies
#
find_package(X11)
find_package(Motif)
find_package(Fontconfig)
find_package(Freetype)
find_package(JPEG)

# create missing alias targets
# Motif
add_library(motif_imported SHARED IMPORTED GLOBAL)
set_target_properties(motif_imported PROPERTIES IMPORTED_LOCATION "${MOTIF_LIBRARIES}"
  INTERFACE_INCLUDE_DIRECTORIES ${MOTIF_INCLUDE_DIR})
add_library(MOTIF::MOTIF ALIAS motif_imported)

#
# Generate gmv_config.h
#
include(cmake/generate_config_h.cmake)


# ##########################################################################################
# ##########################################################################################
# now we build gmv
# ##########################################################################################
# ##########################################################################################
set(GMV_SRCS
  main.c readgmv.c get_statistics.c initstuff.c gmvread.c
  init_motif.c callbacks.c drawit.c drawaxes.c savescreen.c cbtun.c
  drawpolygons.c drawpolylines.c drawnodepoints.c
  drawcellfaces.c drawcellhiddenedges.c drawvectors.c centerform.c
  subsetform.c matorderform.c snapshotform.c scaleaxisform.c
  polysubsetform.c isosurfform.c makeisosurf.c
  drawisosurface.c cutplaneform.c makecutplane.c
  drawcutplane.c coloreditform.c attributes.c writevars.c
  animationform.c polygonform.c drawcelledges.c nodeform.c
  cellform.c nodeselform.c cellselform.c cellexpform.c
  drawanimvelflow.c gridanalform.c traceform.c drawtracers.c
  icosadraw.c plotboxform.c imagestuff.c fieldlimform.c
  tracelimform.c drawcolorbar.c boundingboxform.c drawboundingbox.c
  drawsubsetbox.c animflyform.c vectbldform.c tfldcalcform.c
  cutlineform.c makecutline.c drawcutline.c fldcalcform.c
  queryform.c nfieldform.c cfieldform.c cfieldlimform.c
  cfldcalcform.c cvectbldform.c fldfiles_io.c isovolform.c
  makeisovol.c pntsizeform.c autordform.c readgmvamr.c gen_amr.c
  stereoform.c linesizeform.c fcoloreditform.c SciPlot.c
  cutsphereform.c makecutsphere.c backgrndform.c gmvrc_io.c
  vectorctlform.c surfform.c surfselform.c surfexpform.c
  svectbldform.c sfieldform.c sfieldlimform.c sfldcalcform.c
  drawsurfaces.c drawsurfedges.c rbzoomform.c nfldavgform.c
  cfldavgform.c drawelem.c misc_ctlform.c windowsizeform.c
  ffieldform.c ffieldlimform.c fvectbldform.c traceselform.c
  trfieldform.c readgmvray.c rayform.c drawrays.c raylimform.c
  concaveform.c readgmvinfo.c matcolorbarform.c readexodus.c
  readx3d.c x3dread.c Ball.c BallAux.c BallMath.c GLwDrawA.c GLwMDrawA.c)

add_library(gmv ${GMV_SRCS})
target_include_directories(
  gmv
  PUBLIC $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}> )
target_link_libraries(gmv PUBLIC X11::X11 MOTIF::MOTIF JPEG::JPEG)

# #################### PRINT CONFIGURE STATUS ######################
message("//===================================================")
message("// ${PROJECT_NAME} build configuration:")
message("//===================================================")
message("")
message("  CMake version          : ${CMAKE_VERSION}")
if(NOT CMAKE_BUILD_TYPE)
  message("  CMake build type       : NOT SET !")
else()
  message("  CMake build type       : ${CMAKE_BUILD_TYPE}")
endif()
message("  CMake install prefix   : ${CMAKE_INSTALL_PREFIX}")
message("  CMake system processor : ${CMAKE_SYSTEM_PROCESSOR}")
message("  CMake system name (OS) : ${CMAKE_SYSTEM_NAME}")
message("")
message("  C Compiler : ${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION}")
if(DEFINED CMAKE_C_COMPILER_WRAPPER)
  message("                 ${CMAKE_C_COMPILER_WRAPPER}")
endif()
message("                   ${CMAKE_C_COMPILER}")
message("  CMAKE_C_STANDARD : ${CMAKE_C_STANDARD}")
message("")

message("X11 version:   ${X11_VERSION}")
message("X11 include:   ${X11_INCLUDE_DIR}")
message("X11 libraries: ${X11_LIBRARIES}")
message("")
message("Motif version:   ${Motif_VERSION}")
message("Motif include:   ${MOTIF_INCLUDE_DIR}")
message("Motif libraries: ${MOTIF_LIBRARIES}")
message("")
message("Fontconfig version:         ${Fontconfig_VERSION}")
message("Fontconfig include:         ${Fontconfig_INCLUDE_DIRS}")
message("Fontconfig libraries:       ${Fontconfig_LIBRARIES}")
message("Fontconfig compile options: ${Fontconfig_COMPILE_OPTIONS}")
message("")
message("Freetype version:         ${FREETYPE_VERSION_STRING}")
message("Freetype include:         ${FREETYPE_INCLUDE_DIRS}")
message("Freetype libraries:       ${FREETYPE_LIBRARIES}")
message("")
message("JPEG version:   ${JPEG_VERSION}")
message("JPEG include:   ${JPEG_INCLUDE_DIRS}")
message("JPEG libraries: ${JPEG_LIBRARIES}")


message("")
