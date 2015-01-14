configure_file(pantheon-calculator.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/pantheon-calculator.desktop)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/pantheon-calculator.desktop DESTINATION share/applications)
