configure_file(pantheon-calculator.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/pantheon-calculator.desktop)
configure_file(pantheon-calculator.appdata.xml.in ${CMAKE_CURRENT_BINARY_DIR}/pantheon-calculator.appdata.xml)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/pantheon-calculator.desktop DESTINATION share/applications)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/pantheon-calculator.appdata.xml DESTINATION share/appdata)
