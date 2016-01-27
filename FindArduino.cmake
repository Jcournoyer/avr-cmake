set(Arduino_FOUND False)

# find root path
if(NOT "${Arduino_ROOT_DIR}")
	if(IS_DIRECTORY /usr/share/arduino)
		set(Arduino_ROOT_DIR /usr/share/arduino CACHE PATH "Arduino root directory")
	else(IS_DIRECTORY /usr/share/arduino)
		if(IS_DIRECTORY /usr/local/share/arduino)
			set(Arduino_ROOT_DIR /usr/local/share/arduino CACHE PATH "Arduino root directory")
		else(IS_DIRECTORY /usr/local/share/arduino)
			set(Arduino_ROOT_DIR NOTFOUND CACHE PATH "Arduino root directory")
		endif(IS_DIRECTORY /usr/local/share/arduino)
	endif(IS_DIRECTORY /usr/share/arduino)
endif(NOT "${Arduino_ROOT_DIR}")

# default component (arduino core)
if(NOT "${Arduino_FIND_COMPONENTS}")
	set(Arduino_FIND_COMPONENTS core_arduino)
endif(NOT "${Arduino_FIND_COMPONENTS}")

# default variant
if(NOT "${Arduino_VARIANT}")
	set(Arduino_VARIANT standard CACHE STRING "Arduino variant (see ${Arduino_ROOT}/hardware/arduino/variants)")
endif(NOT "${Arduino_VARIANT}")

# check if all component are founds
set(Arduino_FOUND True)
set(Arduino_INCLUDE_DIRS "")
set(Arduino_LIBRARIES "")
foreach(COMPONENT ${Arduino_FIND_COMPONENTS})
	if(${COMPONENT} MATCHES core_.*)
		string(REGEX REPLACE core_ "" Arduino_CORE_NAME ${COMPONENT})
		if(IS_DIRECTORY ${Arduino_ROOT_DIR}/hardware/arduino/cores/${Arduino_CORE_NAME})
			set(Arduino_FOUND_${COMPONENT} True)
			set(Arduino_CORE_ROOT_DIR ${Arduino_ROOT_DIR}/hardware/arduino/cores/${Arduino_CORE_NAME})
			set(Arduino_INCLUDE_DIRS ${Arduino_INCLUDE_DIRS} "${Arduino_ROOT_DIR}/hardware/arduino/cores/${Arduino_CORE_NAME}")
			set(Arduino_LIBRARIES ${Arduino_LIBRARIES} "${COMPONENT}")
		else(IS_DIRECTORY ${Arduino_ROOT_DIR}/hardware/arduino/cores/${Arduino_CORE_NAME})
			set(Arduino_FOUND_${COMPONENT} False)
		endif(IS_DIRECTORY ${Arduino_ROOT_DIR}/hardware/arduino/cores/${Arduino_CORE_NAME})
	else(${COMPONENT} MATCHES core_.*)
		if(IS_DIRECTORY ${Arduino_ROOT_DIR}/libraries/${COMPONENT})
			set(Arduino_FOUND_${COMPONENT} True)
			set(Arduino_${COMPONENT}_ROOT_DIR ${Arduino_ROOT_DIR}/libraries/${COMPONENT})
			set(Arduino_INCLUDE_DIRS ${Arduino_INCLUDE_DIRS} "${Arduino_ROOT_DIR}/libraries/${COMPONENT}")
			set(Arduino_LIBRARIES ${Arduino_LIBRARIES} "${COMPONENT}")
		else(IS_DIRECTORY ${Arduino_ROOT_DIR}/libraries/${COMPONENT})
			set(Arduino_FOUND_${COMPONENT} False)
		endif(IS_DIRECTORY ${Arduino_ROOT_DIR}/libraries/${COMPONENT})
	endif(${COMPONENT} MATCHES core_.*)
	
	if(NOT ${Arduino_FOUND_${COMPONENT}})
		if(${Arduino_FIND_REQUIRED_${COMPONENT}})
			set(Arduino_FOUND False)
		else(${Arduino_FIND_REQUIRED_${COMPONENT}})
			message(WARNING "Arduino optional component ${COMPONENT} not found")
		endif(${Arduino_FIND_REQUIRED_${COMPONENT}})
	endif(NOT ${Arduino_FOUND_${COMPONENT}})
endforeach(COMPONENT)
if(NOT IS_DIRECTORY ${Arduino_ROOT_DIR}/hardware/arduino/variants/${Arduino_VARIANT})
	set(Arduino_FOUND False)
endif(NOT IS_DIRECTORY ${Arduino_ROOT_DIR}/hardware/arduino/variants/${Arduino_VARIANT})

if(${Arduino_FOUND})
	set(Arduino_VARIANT_DIR ${Arduino_ROOT_DIR}/hardware/arduino/variants/${Arduino_VARIANT})
	set(Arduino_INCLUDE_DIRS ${Arduino_INCLUDE_DIRS} "${Arduino_VARIANT_DIR}")
	set(Arduino_LIBRARIES_ROOT_DIR ${Arduino_ROOT_DIR}/libraries)
	foreach(COMPONENT ${Arduino_FIND_COMPONENTS})
		if(${COMPONENT} MATCHES core_.*)
			file(GLOB SOURCE ${Arduino_CORE_ROOT_DIR}/*.c ${Arduino_CORE_ROOT_DIR}/*.cpp)
			avr_add_library(${COMPONENT} ${SOURCE})
			target_include_directories(${COMPONENT} 
				PUBLIC ${Arduino_CORE_ROOT_DIR} 
				PRIVATE ${Arduino_VARIANT_DIR})
		else(${COMPONENT} MATCHES core_.*)
			file(GLOB SOURCE ${Arduino_${COMPONENT}_ROOT_DIR}/*.c ${Arduino_${COMPONENT}_ROOT_DIR}/*.cpp)
			avr_add_library(${COMPONENT} ${SOURCE})
			target_include_directories(${COMPONENT} 
				PUBLIC ${Arduino_${COMPONENT}_ROOT_DIR} 
				PRIVATE ${Arduino_CORE_ROOT_DIR} ${Arduino_VARIANT_DIR} ${Arduino_LIBRARIES_ROOT_DIR})
		endif(${COMPONENT} MATCHES core_.*)
	endforeach(COMPONENT)
else(${Arduino_FOUND})
	if(${Arduino_FIND_REQUIRED})
		message(FATAL_ERROR "Arduino libraries not found")
	else(${Arduino_FIND_REQUIRED})
		if(NOT {Arduino_FIND_QUIETLY})
			message(WARNING "Arduino libraries not found")
		endif(NOT {Arduino_FIND_QUIETLY})
	endif(${Arduino_FIND_REQUIRED})
endif(${Arduino_FOUND})
