configure_file(calculus.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/calculus.desktop)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/calculus.desktop DESTINATION share/applications)
