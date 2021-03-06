# Copyright © 2015 Intel Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice (including the next
# paragraph) shall be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

# Note: To build and use libepoxy for Visual Studio prior to Visual Studio 2013,
#       you need to ensure that you have stdint.h, inttypes.h and stdbool.h
#       that will work for your installation of Visual Studio, which can be
#       found by the compiler.  One possibility would be to use msinttypes
#       and adapting gnulib's stdbool.h.in for your use.

# Adjust this to where your Python interpretor resides in
PYTHONDIR=$(PYTHON_DIR)

# Choose whether libtool-style DLL names are desired (set as 1)
LIBTOOL_DLL_NAMING = 0

# Please don't change the following lines
EPOXY_BASENAME = epoxy

!if "$(LIBTOOL_DLL_NAMING)" == "1"
EPOXY_DLL_BASENAME = lib$(EPOXY_BASENAME)-0
!else
EPOXY_DLL_BASENAME = $(EPOXY_BASENAME)
!endif

!include .\msvc-120\detectenv-msvc.mak
!include Makefile.sources

all: $(EPOXY_DLL_BASENAME).dll

$(EPOXY_DLL_BASENAME).dll: ../$(GL_GEN_HEADER) ../$(WGL_GEN_HEADER) $(GENERATED_GL_SOURCE) $(GENERATED_WGL_SOURCE) $(EPOXY_WGL_C_SRC) $(EPOXY_C_SRC)
	$(CC) $(CFLAGS_ADD) $(CFLAGS_C99_COMPAT) $(EPOXY_C_SRC) $(EPOXY_WGL_C_SRC) $(GENERATED_GL_SOURCE) $(GENERATED_WGL_SOURCE)	\
	/link /DLL /DEBUG $(EXTRA_LDFLAGS) /pdb:$(EPOXY_DLL_BASENAME).pdb /out:$@ /implib:$(EPOXY_BASENAME).dll.lib
	@if exist $@.manifest mt /manifest $@.manifest /outputresource:$@;2

..\$(WGL_GEN_HEADER) $(GENERATED_WGL_SOURCE): gen_dispatch.py
	$(PYTHONDIR)\python.exe gen_dispatch.py --dir .. ..\registry\wgl.xml

..\$(GL_GEN_HEADER) $(GENERATED_GL_SOURCE): gen_dispatch.py
	$(PYTHONDIR)\python.exe gen_dispatch.py --dir .. ..\registry\gl.xml

clean:
	@-del *.lib
	@-del *.exp
	@-del *.dll
	@-del *.idb
	@-if exist *.dll.manifest del *.dll.manifest
	@-del *.ilk
	@-del *.pdb
	@-del *.obj
	@-del ..\include\epoxy\*generated.h
	@-del $(GENERATED_GL_SOURCE)
	@-del $(GENERATED_WGL_SOURCE)
