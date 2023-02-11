cmake_minimum_required(VERSION 3.25.2)

project(transpiler)

# generate lexer and parser using flex and bison
add_custom_command(OUTPUT parser.cpp
                   COMMAND bison main_cpp.y
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
add_custom_command(OUTPUT lexer.cpp
                   COMMAND flex main_cpp.l
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(prog ${CMAKE_CURRENT_SOURCE_DIR}/parser.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/lexer.cpp
  AST/AST.cpp AST/Program.cpp AST/ProgramBuilder.cpp
  AST/Types.cpp symtable/Symtable.cpp symtable/Symbol.cpp)
