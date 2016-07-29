# see: http://www.vtk.org/Wiki/CMake:CPackConfiguration

########################################################################################
# gather host-native libraries
################################################################################

# these are all the host-native libraries plus
file(GLOB_RECURSE PLATFORM_LIBS
	${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/*.a
	${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/*.so
	${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/*.lib
	${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/*.dylib
	${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/*.jnilib
	${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/*.dll
	${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/*.pdb
	${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/*.jar
#	${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/*.exp
)

# sort host-native libraries into installation components
foreach(PLATFORM_LIB ${PLATFORM_LIBS})
	if (OFF)
	elseif (PLATFORM_LIB MATCHES ".*umundo.*ative.*ava.*")
		install(FILES ${PLATFORM_LIB} DESTINATION share/umundo/bindings/java COMPONENT librarySwigJava)
		# message("${PLATFORM_LIB} -> librarySwig: share/umundo/bindings/java")
		list (APPEND UMUNDO_CPACK_COMPONENTS "librarySwigJava")

	elseif (PLATFORM_LIB MATCHES ".*umundo.jar")
		install(FILES ${PLATFORM_LIB} DESTINATION share/umundo/bindings COMPONENT librarySwigJava)
		# message("${PLATFORM_LIB} -> librarySwig: share/umundo/bindings/java")
		list (APPEND UMUNDO_CPACK_COMPONENTS "librarySwigJava")
		
	elseif (PLATFORM_LIB MATCHES "csharp64.*umundo.*ative.*harp.*")
		install(FILES ${PLATFORM_LIB} DESTINATION share/umundo/bindings/csharp64 COMPONENT librarySwigCSharp)
		# message("${PLATFORM_LIB} -> librarySwig: share/umundo/bindings/csharp64")
		list (APPEND UMUNDO_CPACK_COMPONENTS "librarySwigCSharp")
		
	elseif (PLATFORM_LIB MATCHES "csharp.*umundo.*ative.*harp.*")
		install(FILES ${PLATFORM_LIB} DESTINATION share/umundo/bindings/csharp COMPONENT librarySwigCSharp)
		# message("${PLATFORM_LIB} -> librarySwig: share/umundo/bindings/csharp")
		list (APPEND UMUNDO_CPACK_COMPONENTS "librarySwigCSharp")
		
	elseif (PLATFORM_LIB MATCHES ".*umundo.*harp.*")
		install(FILES ${PLATFORM_LIB} DESTINATION share/umundo/bindings COMPONENT librarySwigCSharp)
		# message("${PLATFORM_LIB} -> librarySwig: share/umundo/bindings")
		list (APPEND UMUNDO_CPACK_COMPONENTS "librarySwigCSharp")
				
	elseif (PLATFORM_LIB MATCHES ".*umundo-.*\\.lib")
		# .lib files from the binaries on windows -> ignore
		# message("${PLATFORM_LIB} -> IGNORED!")
		
	elseif (PLATFORM_LIB MATCHES ".*umundo.*")
		# rest into lib directory
		install(FILES ${PLATFORM_LIB} DESTINATION lib COMPONENT library)
		# message("${PLATFORM_LIB} -> library: lib")
		list (APPEND UMUNDO_CPACK_COMPONENTS "library")
		
	else()
		# message(STATUS "PACKAGE RELEASE UNK ${PLATFORM_LIB} - not packaging")
	endif()
endforeach()

# file(GLOB_RECURSE PLATFORM_BINS ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
# foreach(PLATFORM_BIN ${PLATFORM_BINS})
# 	if (OFF)
# 	elseif (PLATFORM_BIN MATCHES ".*\\.lib")
# 	elseif (PLATFORM_BIN MATCHES ".*\\.exp")
# 	else()
# 		install(FILES ${PLATFORM_LIB} DESTINATION share/umundo/bindings COMPONENT tools)
# 	endif()
# endforeach()
# 

########################################
# Pre-built libraries for host platform
########################################

# do follow symlinks with GLOB_RECURSE
#cmake_policy(SET CMP0009 OLD)

file(GLOB_RECURSE PREBUILT_LIBS FOLLOW_SYMLINKS
	${UMUNDO_PREBUILT_LIBRARY_PATH}/lib/*.a
	${UMUNDO_PREBUILT_LIBRARY_PATH}/lib/*.so
	${UMUNDO_PREBUILT_LIBRARY_PATH}/lib/*.dylib
	${UMUNDO_PREBUILT_LIBRARY_PATH}/lib/*.lib
	${UMUNDO_PREBUILT_LIBRARY_PATH}/lib/*.dll
	${UMUNDO_PREBUILT_LIBRARY_PATH}/lib/*.pdb
)

#message("UMUNDO_PREBUILT_LIBRARY_PATH: ${UMUNDO_PREBUILT_LIBRARY_PATH}")

foreach(PREBUILT_LIB ${PREBUILT_LIBS})
#	message("PREBUILT_LIB: ${PREBUILT_LIB}")
	# string(REGEX MATCH "prebuilt/[^//]+/[^//]+" CURR_PLATFORM ${PREBUILT_LIB})
	# message("CURR_PLATFORM: ${CURR_PLATFORM}")
	# install(FILES ${PREBUILT_LIB} DESTINATION share/umundo/${CURR_PLATFORM} COMPONENT libraryPrebuilt)
	install(FILES ${PREBUILT_LIB} DESTINATION share/umundo/deps COMPONENT libraryPrebuilt)
	# message("${PREBUILT_LIB} -> libraryPrebuilt: share/umundo/deps")
	list (APPEND UMUNDO_CPACK_COMPONENTS "libraryPrebuilt")
endforeach()

########################################
# Include documentation
########################################

# file(GLOB_RECURSE HTML_DOCS ${PROJECT_SOURCE_DIR}/docs/html/*)
# foreach(HTML_DOC ${HTML_DOCS})
# 	STRING(REGEX REPLACE "${PROJECT_SOURCE_DIR}/" "" HTML_PATH ${HTML_DOC})
# 	STRING(REGEX MATCH "(.*)[/\\]" HTML_PATH ${HTML_PATH})
# 	install(FILES ${HTML_DOC} DESTINATION share/umundo/${HTML_PATH} COMPONENT docs)
# 	list (APPEND UMUNDO_CPACK_COMPONENTS "docs")
# #	message(STATUS ${HTML_PATH})
# endforeach()

########################################
# CMake Modules for clients
########################################

install(FILES ${PROJECT_SOURCE_DIR}/contrib/cmake/FindUMUNDO.cmake DESTINATION share/umundo/cmake COMPONENT library)
install(FILES ${PROJECT_SOURCE_DIR}/contrib/cmake/UseUMUNDO.cmake DESTINATION share/umundo/cmake COMPONENT library)

########################################
# Target languages
########################################

GET_TARGET_PROPERTY(UMUNDONATIVEJAVA_LOCATION umundoNativeJava LOCATION)
if (DIST_PREPARE)
	if (EXISTS "${PROJECT_SOURCE_DIR}/package/umundo.jar")
		install(FILES ${PROJECT_SOURCE_DIR}/package/umundo.jar DESTINATION share/umundo/bindings COMPONENT librarySwigJava)
		list (APPEND UMUNDO_CPACK_COMPONENTS "librarySwigJava")
	endif()
else()
	if (UMUNDONATIVEJAVA_LOCATION)
		install(FILES ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/umundo.jar DESTINATION share/umundo/bindings COMPONENT librarySwigJava OPTIONAL)
		list (APPEND UMUNDO_CPACK_COMPONENTS "librarySwigJava")
	endif()
endif()

# copy over 64 and 32 bit for native part of csharp bindings
if (DIST_PREPARE AND NOT APPLE)
	# we built the csharp bindings, try to find the other bit-depth one
	if (WIN32)
		if (HOST_64BIT)
			set(CSHARP_OTHER_INSTALL_PATH "${PROJECT_SOURCE_DIR}/package/windows-x86-msvc${MSVC_VERSION}/lib")
			set(CSHARP_OTHER_DESTINATION "share/umundo/bindings/csharp")
		else()
			set(CSHARP_OTHER_INSTALL_PATH "${PROJECT_SOURCE_DIR}/package/windows-x86_64-msvc${MSVC_VERSION}/lib")
			set(CSHARP_OTHER_DESTINATION "share/umundo/bindings/csharp64")
		endif()
	elseif(UNIX)
		if (HOST_64BIT)
			set(CSHARP_OTHER_INSTALL_PATH "${PROJECT_SOURCE_DIR}/package/linux-x86-gnu/lib")
			set(CSHARP_OTHER_DESTINATION "share/umundo/bindings/csharp")
		else()
			set(CSHARP_OTHER_INSTALL_PATH "${PROJECT_SOURCE_DIR}/package/linux-x86_64-gnu/lib")
			set(CSHARP_OTHER_DESTINATION "share/umundo/bindings/csharp64")
		endif()
	endif()
	
	if (CSHARP_OTHER_INSTALL_PATH)
		file(GLOB_RECURSE CSHARP_OTHER_LIBS
			${CSHARP_OTHER_INSTALL_PATH}/*umundoNativeCSharp*.a
			${CSHARP_OTHER_INSTALL_PATH}/*umundoNativeCSharp*.so
			${CSHARP_OTHER_INSTALL_PATH}/*umundoNativeCSharp*.lib
			${CSHARP_OTHER_INSTALL_PATH}/*umundoNativeCSharp*.dylib
			${CSHARP_OTHER_INSTALL_PATH}/*umundoNativeCSharp*.jnilib
			${CSHARP_OTHER_INSTALL_PATH}/*umundoNativeCSharp*.dll
			${CSHARP_OTHER_INSTALL_PATH}/*umundoNativeCSharp*.pdb
		)
	
		foreach(CSHARP_OTHER_LIB ${CSHARP_OTHER_LIBS})
			# message("CSHARP_OTHER_LIB: ${CSHARP_OTHER_LIB} -> share/umundo/bindings/${LAST_PATH_COMPONENT}")
			STRING(REGEX REPLACE "${CSHARP_OTHER_INSTALL_PATH}/" "" CSHARP_OTHER_LIB_REL ${CSHARP_OTHER_LIB})
			STRING(REGEX MATCH "[^/\\](.*)[/\\]" LAST_PATH_COMPONENT ${CSHARP_OTHER_LIB_REL})
			install(FILES "${CSHARP_OTHER_LIB}" DESTINATION share/umundo/bindings/${LAST_PATH_COMPONENT} COMPONENT librarySwigCSharp OPTIONAL)
		endforeach()
	endif()
endif()

################################################################################
# Cross Compiled binaries
################################################################################

########################################
# Android
########################################

if (NOT ENV{UMUNDO_PACKAGE_CURR_ARCH_ONLY})
	file(GLOB_RECURSE ANDROID_LIBS ${PROJECT_SOURCE_DIR}/package/cross-compiled/android/*)
	foreach(ANDROID_LIB ${ANDROID_LIBS})
		# do not pack static libraries
	#	if (NOT ANDROID_LIB MATCHES ".*\\.a" AND NOT ANDROID_LIB MATCHES "\\..*")
		if (NOT ANDROID_LIB MATCHES ".*\\.a")
			# remove weird double slashes
			STRING(REGEX REPLACE "//" "/" ANDROID_LIB ${ANDROID_LIB})
			# take relative path
			STRING(REGEX REPLACE "${PROJECT_SOURCE_DIR}/package/cross-compiled/" "" ANDROID_PATH ${ANDROID_LIB})
	    # only take first two path elements
			STRING(REGEX MATCH "[^/]*/[^/]*" ANDROID_PATH ${ANDROID_PATH})
			# but remove umundo.jar from path in any case
			STRING(REGEX REPLACE "/umundo.jar" "" ANDROID_PATH ${ANDROID_PATH})
	    #message(STATUS "ANDROID_PATH: ${ANDROID_PATH}")
	    #message(STATUS "ANDROID_LIB: ${ANDROID_LIB}")
			install(FILES ${ANDROID_LIB} DESTINATION share/umundo/${ANDROID_PATH} COMPONENT libraryAndroid)
			list (APPEND UMUNDO_CPACK_COMPONENTS "libraryAndroid")
		endif()
	endforeach()

# list(FIND UMUNDO_CPACK_COMPONENTS "libraryAndroid" FOUND_ITEM)
# if (FOUND_ITEM GREATER -1)
# 	file(GLOB_RECURSE ANDROID_PREBUILT_LIBS ${PROJECT_SOURCE_DIR}/contrib/prebuilt/android*/*)
# 	foreach(ANDROID_PREBUILT_LIB ${ANDROID_PREBUILT_LIBS})
# 		STRING(REGEX REPLACE "//" "/" ANDROID_PREBUILT_LIB ${ANDROID_PREBUILT_LIB})
# 		STRING(REGEX MATCH "prebuilt/[^//]+/[^//]+" ANDROID_PLATFORM ${ANDROID_PREBUILT_LIB})
# 		message("ANDROID_PREBUILT_LIB: ${ANDROID_PREBUILT_LIB}")
# 		message("ANDROID_PLATFORM: ${ANDROID_PLATFORM}")
# 		install(FILES ${ANDROID_PREBUILT_LIB} DESTINATION share/umundo/${ANDROID_PLATFORM} COMPONENT libraryPrebuilt)
# 	endforeach()
# endif()

########################################
# iOS
########################################
	if (APPLE)
		file(GLOB_RECURSE IOS_LIBS ${PROJECT_SOURCE_DIR}/package/cross-compiled/ios/*.a)
		foreach(IOS_LIB ${IOS_LIBS})
			# match ios-5.0
			# STRING(REGEX REPLACE "//" "/" IOS_LIB ${IOS_LIB})
			# STRING(REGEX REPLACE "${PROJECT_SOURCE_DIR}/package/cross-compiled/" "" IOS_PATH ${IOS_LIB})
			# STRING(REGEX MATCH "[^/]*" IOS_PATH ${IOS_PATH})
			# message(STATUS "IOS_LIB:  ${IOS_LIB}")
			# message(STATUS "IOS_PATH: ${IOS_PATH}")
			# install(FILES ${IOS_LIB} DESTINATION share/umundo/${IOS_PATH} COMPONENT libraryIOS)
			install(FILES ${IOS_LIB} DESTINATION share/umundo/ios COMPONENT libraryIOS)
			list (APPEND UMUNDO_CPACK_COMPONENTS "libraryIOS")
		endforeach()

		list(FIND UMUNDO_CPACK_COMPONENTS "libraryIOS" FOUND_ITEM)
		if (FOUND_ITEM GREATER -1)
			file(GLOB_RECURSE IOS_PREBUILT_LIBS ${PROJECT_SOURCE_DIR}/contrib/prebuilt/ios/*.a)
			foreach(IOS_PREBUILT_LIB ${IOS_PREBUILT_LIBS})
				if(NOT EXISTS "${IOS_PREBUILT_LIB}/")
					# STRING(REGEX REPLACE "//" "/" IOS_PREBUILT_LIB ${IOS_PREBUILT_LIB})
					# STRING(REGEX MATCH "ios/[^//]+" IOS_PLATFORM ${IOS_PREBUILT_LIB})
					# message("IOS_PLATFORM: ${IOS_PLATFORM}")
					# message("IOS_PREBUILT_LIB: ${IOS_PREBUILT_LIB}")
					# install(FILES ${IOS_PREBUILT_LIB} DESTINATION share/umundo/deps/${IOS_PLATFORM} COMPONENT libraryPrebuilt)
					install(FILES ${IOS_PREBUILT_LIB} DESTINATION share/umundo/deps/ios COMPONENT libraryPrebuilt)
				endif()
			endforeach()
		endif()
	endif()
endif()

################################################################################
# Sample projects
################################################################################

if (DIST_PREPARE)
	# umundo-pingpong: XCode for iOS
	if (APPLE)
		file(GLOB_RECURSE IOS_PINGPONG_SAMPLE ${PROJECT_SOURCE_DIR}/examples/ios/umundo-pingpong*/*)
		foreach(IOS_PINGPONG_SAMPLE_FILE ${IOS_PINGPONG_SAMPLE})
			# strip root
			STRING(REGEX REPLACE "${PROJECT_SOURCE_DIR}/examples" "" REL_PATH ${IOS_PINGPONG_SAMPLE_FILE})
			get_filename_component(REL_PATH ${REL_PATH} PATH)
	#		message("Installing ${IOS_PINGPONG_SAMPLE_FILE} in share/umundo/samples/${REL_PATH}")
			install(FILES ${IOS_PINGPONG_SAMPLE_FILE} DESTINATION share/umundo/samples/${REL_PATH} COMPONENT samples)
		endforeach()
		list (APPEND UMUNDO_CPACK_COMPONENTS "samples")
	endif()

	# umundo-pingpong: Eclipse for Android
	file(GLOB_RECURSE ANDROID_PINGPONG_SAMPLE ${PROJECT_SOURCE_DIR}/examples/android/*)

	foreach(ANDROID_PINGPONG_SAMPLE_FILE ${ANDROID_PINGPONG_SAMPLE})
	#	message("ANDROID_PINGPONG_SAMPLE_FILE: ${ANDROID_PINGPONG_SAMPLE_FILE}")
		IF(NOT ${ANDROID_PINGPONG_SAMPLE_FILE} MATCHES "class$")
			# make sure no .class files creep in
			STRING(REGEX REPLACE "${PROJECT_SOURCE_DIR}/examples" "" REL_PATH ${ANDROID_PINGPONG_SAMPLE_FILE})
			get_filename_component(REL_PATH ${REL_PATH} PATH)
			# message("ANDROID_PINGPONG_SAMPLE_FILE: share/umundo/samples/${REL_PATH}")
			install(FILES ${ANDROID_PINGPONG_SAMPLE_FILE} DESTINATION share/umundo/samples/${REL_PATH} COMPONENT samples)
		endif()
	endforeach()
	list (APPEND UMUNDO_CPACK_COMPONENTS "samples")

	# umundo-pingpong: Visual Studio for CSharp
	if (NOT APPLE)
		file(GLOB_RECURSE CSHARP_PINGPONG_SAMPLE ${PROJECT_SOURCE_DIR}/examples/csharp/*)
		foreach(CSHARP_PINGPONG_SAMPLE_FILE ${CSHARP_PINGPONG_SAMPLE})
			STRING(REGEX REPLACE "${PROJECT_SOURCE_DIR}/examples" "" REL_PATH ${CSHARP_PINGPONG_SAMPLE_FILE})
			get_filename_component(REL_PATH ${REL_PATH} PATH)
			# message("CSHARP_PINGPONG_SAMPLE_FILE: share/umundo/samples/${REL_PATH}")
			install(FILES ${CSHARP_PINGPONG_SAMPLE_FILE} DESTINATION share/umundo/samples/${REL_PATH} COMPONENT samples)
		endforeach()
		list (APPEND UMUNDO_CPACK_COMPONENTS "samples")
	endif()

	# All the java samples
	file(GLOB_RECURSE JAVA_SAMPLES ${PROJECT_SOURCE_DIR}/examples/java/*)
	foreach(JAVA_SAMPLES_FILE ${JAVA_SAMPLES})
		IF(NOT ${JAVA_SAMPLES_FILE} MATCHES "class$")
			# make sure no .class files creep in
			STRING(REGEX REPLACE "${PROJECT_SOURCE_DIR}/examples" "" REL_PATH ${JAVA_SAMPLES_FILE})
			get_filename_component(REL_PATH ${REL_PATH} PATH)
			# message("JAVA_SAMPLES_FILE: share/umundo/samples/${REL_PATH}")
			install(FILES ${JAVA_SAMPLES_FILE} DESTINATION share/umundo/samples/${REL_PATH} COMPONENT samples)
		endif()
	endforeach()

	# All the cpp samples
	file(GLOB_RECURSE CPP_SAMPLES ${PROJECT_SOURCE_DIR}/examples/cpp/*)
	foreach(CPP_SAMPLES_FILE ${CPP_SAMPLES})
		STRING(REGEX REPLACE "${PROJECT_SOURCE_DIR}/examples" "" REL_PATH ${CPP_SAMPLES_FILE})
		get_filename_component(REL_PATH ${REL_PATH} PATH)
		install(FILES ${CPP_SAMPLES_FILE} DESTINATION share/umundo/samples/${REL_PATH} COMPONENT samples)
	endforeach()

	list (APPEND UMUNDO_CPACK_COMPONENTS "samples")
endif()

########################################
# House keeping
########################################

list (APPEND UMUNDO_CPACK_COMPONENTS "headers")

if (NOT CMAKE_CROSS_COMPILING)
	list (APPEND UMUNDO_CPACK_COMPONENTS "tools")
endif()
list (REMOVE_DUPLICATES UMUNDO_CPACK_COMPONENTS)
#message("UMUNDO_CPACK_COMPONENTS: ${UMUNDO_CPACK_COMPONENTS}")

########################################
# Configure packagers
########################################

if (UNIX)
	if (APPLE)
		set(CPACK_GENERATOR "PackageMaker;TGZ")
		# set(CPACK_GENERATOR "ZIP")
	else()
		set(CPACK_GENERATOR "DEB;RPM;TGZ")
	endif()
	set(CPACK_PACKAGING_INSTALL_PREFIX "/usr/local")
endif()
if (WIN32)
	set(CPACK_GENERATOR "NSIS;ZIP")
	#set(CPACK_GENERATOR "ZIP")
	set(CPACK_PACKAGE_INSTALL_DIRECTORY "uMundo")
	# pairs of executables and labels for start menu
	set(CPACK_NSIS_MENU_LINKS
		" ;uMundo SDK"
		"bin\\\\umundo-pingpong.exe;uMundo Ping-Pong"
		"bin\\\\umundo-monitor.exe;uMundo Monitor")

endif()

set(CPACK_PACKAGE_NAME "umundo")
set(CPACK_PACKAGE_VENDOR "Telecooperation Group - TU Darmstadt")
set(CPACK_PACKAGE_CONTACT "radomski@tk.informatik.tu-darmstadt.de")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "uMundo - publish/subscribe since 2012")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${PROJECT_SOURCE_DIR}/installer/description.txt")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/installer/license.txt")

set(CPACK_PACKAGE_VERSION "${UMUNDO_VERSION_MAJOR}.${UMUNDO_VERSION_MINOR}.${UMUNDO_VERSION_PATCH}")
set(CPACK_PACKAGE_VERSION_MAJOR ${UMUNDO_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${UMUNDO_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${UMUNDO_VERSION_PATCH})

if(MSVC_VERSION LESS 1800)
	set(MSVC_NAME msvc2010)
else()
	set(MSVC_NAME msvc2013)
endif()

if (WIN32)
	if (HOST_64BIT)
		set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CMAKE_SYSTEM_NAME_LC}-${CMAKE_SYSTEM_PROCESSOR}_64-${MSVC_NAME}-${CPACK_PACKAGE_VERSION}")
		set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64")
	else()
		set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CMAKE_SYSTEM_NAME_LC}-${CMAKE_SYSTEM_PROCESSOR}-${MSVC_NAME}-${CPACK_PACKAGE_VERSION}")
    set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES")
	endif()
elseif(APPLE)
	if (MACOSX_VERSION VERSION_LESS 10.9)
		set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CMAKE_SYSTEM_NAME_LC}-libstdc++-universal-${CPACK_PACKAGE_VERSION}")
	else()
		# mavericks forces libc++, compatible with 10.7
		set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CMAKE_SYSTEM_NAME_LC}-libc++-universal-${CPACK_PACKAGE_VERSION}")
	endif()
else()
	set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CMAKE_SYSTEM_NAME_LC}-${CMAKE_SYSTEM_PROCESSOR}${64BIT_SUFFIX}-${CPACK_PACKAGE_VERSION}")
endif()

# message(FATAL_ERROR "CPACK_PACKAGE_FILE_NAME: ${CPACK_PACKAGE_FILE_NAME}")

########################################
# MSVC Redistributable
########################################

if (WIN32)
	SET(MSVC_REDIST_PATH "")
	if (HOST_64BIT)
		set(MSVC_REDIST_PATH "${PROJECT_SOURCE_DIR}/package/vcredist_${MSVC_NAME}_x64.exe")
	else()
		set(MSVC_REDIST_PATH "${PROJECT_SOURCE_DIR}/package/vcredist_${MSVC_NAME}_x86.exe")
	endif()
	if (EXISTS ${MSVC_REDIST_PATH})
		install(FILES ${MSVC_REDIST_PATH} DESTINATION contrib COMPONENT msredist)
		get_filename_component(REDIST_FILENAME ${MSVC_REDIST_PATH} NAME)
		# message(STATUS "ADDING REDIST ${REDIST_FILENAME}")
		list(APPEND CPACK_NSIS_EXTRA_INSTALL_COMMANDS "ExecWait '$INSTDIR\\\\contrib\\\\${REDIST_FILENAME}'")
		list (APPEND UMUNDO_CPACK_COMPONENTS "msredist")
	endif()
endif()



###
# Configuration for NSIS installer on Win32
#
# pairs of executables and labels for start menu
#CPACK_PACKAGE_EXECUTABLES
set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "umundo.telecooperation.tu-darmstadt")
if (WIN32)
	set(CPACK_PACKAGE_ICON "${PROJECT_SOURCE_DIR}\\\\installer\\\\nsis\\\\umundo-logo.bmp")
else()
	set(CPACK_PACKAGE_ICON "${PROJECT_SOURCE_DIR}/installer/nsis/umundo-logo.bmp")
endif()

###
# Configuration for PackageMaker on MacOSX
#
set(CPACK_RESOURCE_FILE_README "${PROJECT_SOURCE_DIR}/installer/packageMaker/readme.txt")
set(CPACK_RESOURCE_FILE_WELCOME "${PROJECT_SOURCE_DIR}/installer/packageMaker/welcome.txt")

###
# Configuration for debian packages
#
set(CPACK_DEBIAN_PACKAGE_NAME "umundo")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libavahi-client3, libpcre3")
set(CPACK_DEBIAN_PACKAGE_RECOMMENDS "protobuf-compiler, libprotobuf7")
SET(CPACK_DEBIAN_PACKAGE_MAINTAINER, "Stefan Radomski")


###
# Configuration for RPM packages
#
set(CPACK_RPM_PACKAGE_NAME "umundo")
set(CPACK_RPM_PACKAGE_LICENSE "Simplified BSD")


########################################
# Describe layout of package
########################################

set(CPACK_COMPONENTS_ALL
	${UMUNDO_CPACK_COMPONENTS}
)

###
# Description of components
#

list(FIND UMUNDO_CPACK_COMPONENTS "tools" FOUND_ITEM)
if (FOUND_ITEM GREATER -1)
	set(CPACK_COMPONENT_TOOLS_DISPLAY_NAME "Command-line Tools")
	set(CPACK_COMPONENT_TOOLS_DESCRIPTION "Command-line tools to debug and monitor a umundo network.")
endif()

list(FIND UMUNDO_CPACK_COMPONENTS "samples" FOUND_ITEM)
if (FOUND_ITEM GREATER -1)
	set(CPACK_COMPONENT_SAMPLES_DISPLAY_NAME "IDE Templates and sample programs")
	set(CPACK_COMPONENT_SAMPLES_DESCRIPTION
  		"Templates for Xcode, Visual Studio and Eclipse with sample programs.")
endif()

list(FIND UMUNDO_CPACK_COMPONENTS "docs" FOUND_ITEM)
if (FOUND_ITEM GREATER -1)
	set(CPACK_COMPONENT_DOCS_DISPLAY_NAME "Documentation")
	set(CPACK_COMPONENT_DOCS_DESCRIPTION "Auto-generated documentation.")
endif()

list(FIND UMUNDO_CPACK_COMPONENTS "librarySwigJava" FOUND_ITEM)
if (FOUND_ITEM GREATER -1)
	set(CPACK_COMPONENT_LIBRARYSWIGJAVA_DISPLAY_NAME "Java interface")
	set(CPACK_COMPONENT_LIBRARYSWIGJAVA_DESCRIPTION "umundo.core library wrapped for Java per native interfaces. This will install the actual library and the JAR archive.")
	set(CPACK_COMPONENT_LIBRARYSWIGJAVA_GROUP "Development")
endif()

list(FIND UMUNDO_CPACK_COMPONENTS "librarySwigCSharp" FOUND_ITEM)
if (FOUND_ITEM GREATER -1)
	set(CPACK_COMPONENT_LIBRARYSWIGCSHARP_DISPLAY_NAME "CSharp interface")
	set(CPACK_COMPONENT_LIBRARYSWIGCSHARP_DESCRIPTION "umundo.core library wrapped for CSharp per native interfaces. This will install the actual library and the managed-code DLL archive.")
	set(CPACK_COMPONENT_LIBRARYSWIGCSHARP_GROUP "Development")
endif()

list(FIND UMUNDO_CPACK_COMPONENTS "libraryPrebuilt" FOUND_ITEM)
if (FOUND_ITEM GREATER -1)
	set(CPACK_COMPONENT_LIBRARYPREBUILT_DISPLAY_NAME "C++ dependent libraries")
	set(CPACK_COMPONENT_LIBRARYPREBUILT_DESCRIPTION "Prebuilt libraries for this host and the cross-compile targets")
	set(CPACK_COMPONENT_LIBRARYPREBUILT_GROUP "Development")
endif()

list(FIND UMUNDO_CPACK_COMPONENTS "libraryAndroid" FOUND_ITEM)
if (FOUND_ITEM GREATER -1)
	set(CPACK_COMPONENT_LIBRARYANDROID_DISPLAY_NAME "Android libraries")
	set(CPACK_COMPONENT_LIBRARYANDROID_DESCRIPTION "umundo.core cross compiled for Android devices.")
	set(CPACK_COMPONENT_LIBRARYANDROID_GROUP "Development")
endif()

list(FIND UMUNDO_CPACK_COMPONENTS "libraryIOS" FOUND_ITEM)
if (FOUND_ITEM GREATER -1)
	set(CPACK_COMPONENT_LIBRARYIOS_DISPLAY_NAME "iOS libraries")
	set(CPACK_COMPONENT_LIBRARYIOS_DESCRIPTION "umundo.core cross compiled for iOS devices (universal libraries).")
	set(CPACK_COMPONENT_LIBRARYIOS_GROUP "Development")
	set(CPACK_COMPONENT_LIBRARYIOS_DEPENDS headers)
	set(CPACK_COMPONENT_LIBRARYIOS_DEPENDS libraryPrebuilt)
endif()

list(FIND UMUNDO_CPACK_COMPONENTS "library" FOUND_ITEM)
if (FOUND_ITEM GREATER -1)
	# define header description here as well
	set(CPACK_COMPONENT_HEADERS_DISPLAY_NAME "C++ headers ")
	set(CPACK_COMPONENT_HEADERS_DESCRIPTION "C++ header files for umundo and all its components.")
	set(CPACK_COMPONENT_HEADERS_GROUP "Development")

	set(CPACK_COMPONENT_LIBRARY_DISPLAY_NAME "C++ umundo libraries")
	set(CPACK_COMPONENT_LIBRARY_DESCRIPTION "Static libraries of the umundo components for C++ development.")
	set(CPACK_COMPONENT_LIBRARY_GROUP "Development")
	set(CPACK_COMPONENT_LIBRARY_DEPENDS headers)
	set(CPACK_COMPONENT_LIBRARY_DEPENDS libraryPrebuilt)
endif()

list(FIND UMUNDO_CPACK_COMPONENTS "msredist" FOUND_ITEM)
if (FOUND_ITEM GREATER -1)
	set(CPACK_COMPONENT_MSREDIST_DISPLAY_NAME "MS VC++ Redistributable Package")
	set(CPACK_COMPONENT_MSREDIST_DESCRIPTION "Microsoft Visual C++ compiler runtime libraries. Required if you do not have the respective Visual Studio installed.")
endif()

set(CPACK_COMPONENT_GROUP_DEVELOPMENT_DESCRIPTION "Libraries and Headers for umundo.")
