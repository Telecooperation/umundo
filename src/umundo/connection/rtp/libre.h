/**
 *  @file
 *  @author     2013 Thilo Molitor (thilo@eightysoft.de)
 *  @author     2013 Stefan Radomski (stefan.radomski@cs.tu-darmstadt.de)
 *  @copyright  Simplified BSD
 *
 *  @cond
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the FreeBSD license as published by the FreeBSD
 *  project.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the FreeBSD license along with this
 *  program. If not, see <http://www.opensource.org/licenses/bsd-license>.
 *  @endcond
 */

//we want libre in its own namespace
#ifndef LIBRE_H_HAPJWLQR
#define LIBRE_H_HAPJWLQR

//this is needed for libre to function in its namespace
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

//datatype sizes seem to depend on this define
//in the libre makefile this define is always on --> we do the same here
#define HAVE_INET6

// not sure why we need it here, it's from re_types.h and required for MSVC16
#ifdef HAVE_STDBOOL_H
# include <stdbool.h>
#else
# ifndef HAVE__BOOL
#  ifdef __cplusplus
typedef bool _Bool;
#  else
#   define _Bool signed char
#  endif
# endif
# define bool _Bool
# define false 0
# define true 1
# define __bool_true_false_are_defined 1
#endif

namespace libre {
#include <re.h>
}

//these libre makros infere with some stdlib templates, undefine them here
#undef MAX
#undef max
#undef MIN
#undef min

#endif /* end of include guard: LIBRE_H_HAPJWLQR */
