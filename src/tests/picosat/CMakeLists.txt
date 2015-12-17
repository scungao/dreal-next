add_executable(picosat_example_01 example_01.c)
target_link_libraries(picosat_example_01 dreal ${EXTRA_LIBS})
add_test(picosat_example_01 ${CMAKE_CURRENT_BINARY_DIR}/picosat_example_01)
