configure_file(pantheon-calculator.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/pantheon-calculator.desktop)
configure_file_translation(${CMAKE_CURRENT_BINARY_DIR}/pantheon-calculator.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/pantheon-calculator.desktop ${CMAKE_SOURCE_DIR}/po/)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/pantheon-calculator.desktop DESTINATION share/applications)
install (FILES pantheon-calculator.appdata.xml DESTINATION share/appdata)
