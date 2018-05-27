###################################################
cmake_minimum_required(VERSION 3.7)
project(xlang VERSION 0.2 LANGUAGES CXX)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)
include(FindCurses)

set(LLVM_PATH /home/koshachok/ExternalLibs/llvm-3.8.1/)
set(LLVM_INCLUDE_DIRS ${LLVM_PATH}/include)
link_directories(${LLVM_PATH}/lib)

add_executable(xlang
        ${CMAKE_CURRENT_SOURCE_DIR}/src/ASTImplementation.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/ASTDeclaration.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/lexer.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/parser.cpp
        ${FLEX_lexer_OUTPUTS}
        ${BISON_parser_OUTPUTS})

target_include_directories(xlang
        PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${CMAKE_CURRENT_BINARY_DIR}
        ${LLVM_INCLUDE_DIRS})

set_target_properties(xlang PROPERTIES CXX_STANDARD 14)
set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -lfl -ltinfo -lpthread -ldl -w -Wno-deprecated -g")
set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} "rt")

target_link_libraries(xlang
        LLVMX86Disassembler LLVMX86AsmParser LLVMX86CodeGen LLVMGlobalISel
        LLVMSelectionDAG LLVMAsmPrinter LLVMDebugInfoCodeView LLVMDebugInfoMSF
        LLVMCodeGen LLVMScalarOpts LLVMInstCombine LLVMTransformUtils LLVMBitWriter
        LLVMX86Desc LLVMMCDisassembler LLVMX86Info LLVMX86AsmPrinter LLVMX86Utils
        LLVMMCJIT LLVMExecutionEngine LLVMTarget LLVMAnalysis LLVMProfileData
        LLVMRuntimeDyld LLVMObject LLVMMCParser LLVMBitReader LLVMMC LLVMCore
        LLVMSupport LLVMDemangle z m ${CURSES_LIBRARIES})