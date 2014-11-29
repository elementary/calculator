project (calculus)

cmake_minimum_required (VERSION 2.8)

# tell cmake where its modules can be found in our project directory
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/calculus")
set (GETTEXT_PACKAGE "calculus")
set (EXEC_NAME "calculus")
set (GETTEXT_PACKAGE "calculus")
set (RELEASE_NAME "An elementary app for simple calculation.")
set (VERSION "0.1")
set (VERSION_INFO "Alpha")
set (DOLLAR "$")

configure_file (${CMAKE_SOURCE_DIR}/config.h.cmake ${CMAKE_BINARY_DIR}/config.h)
add_definitions (-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")


# we're about to use pkgconfig to make sure dependencies are installed so let's find pkgconfig first
find_package(PkgConfig)

# now let's actually check for the required dependencies
pkg_check_modules(DEPS REQUIRED 
    gtk+-3.0 
    granite
)
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

# make sure we have vala
find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.22" MINIMUM)

# files we want to compile
include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
    src/Calculus.vala 
    src/widgets/WidgetStack.vala
    src/widgets/Toolbar.vala
    src/widgets/StandardWidget.vala
    src/widgets/ConversionWidget.vala
    src/core/Stack.vala
    src/core/Token.vala
    src/core/TokenQueue.vala
    src/core/utils/Entry.vala
    src/core/methods/CoreMethods.vala
PACKAGES
    gtk+-3.0
    granite
CUSTOM_VAPIS
    vapi/config.vapi
OPTIONS
    --vapidir=${CMAKE_CURRENT_SOURCE_DIR}/vapi/
)


# tell cmake what to call the executable we just made
add_executable(${EXEC_NAME} ${VALA_C})
add_subdirectory (po)

# install the binaries we just made
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

# install our .desktop file so the Applications menu will see it
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/calculus.desktop DESTINATION ${DATADIR}/applications/)
