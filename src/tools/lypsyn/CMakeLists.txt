INCLUDE_DIRECTORIES(${DREAL_BINARY_DIR}/tools/lypsyn)

SET(LYPSYN_SRCS ${LYPSYN_SRCS}
  ${DREAL_BINARY_DIR}/tools/lypsyn/lypsynparser.cc
  ${DREAL_BINARY_DIR}/tools/lypsyn/lypsynlexer.cc
  PARENT_SCOPE)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-sign-compare")
if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-null-conversion -Wno-unneeded-internal-declaration -Wno-deprecated-register")
endif ()

SET(LYPSYN_SRCS "${LYPSYN_SRCS}"
  "${CMAKE_CURRENT_LIST_DIR}/config.cpp"
  "${CMAKE_CURRENT_LIST_DIR}/print.cpp"
  "${CMAKE_CURRENT_LIST_DIR}/lypsyn.cpp"
  "${CMAKE_CURRENT_LIST_DIR}/var_map.cpp"
  "${DREAL_BINARY_DIR}/tools/lypsyn/lypsynparser.cc"
  "${DREAL_BINARY_DIR}/tools/lypsyn/lypsynlexer.cc"
  PARENT_SCOPE)
