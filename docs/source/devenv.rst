..  =========================================================================================
	  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
	
	  Licensed under the Apache License, Version 2.0 (the "License");
	  you may not use this file except in compliance with the License.
	  You may obtain a copy of the License at
	
	      http://www.apache.org/licenses/LICENSE-2.0
	
	  Unless required by applicable law or agreed to in writing, software
	  distributed under the License is distributed on an "AS IS" BASIS,
	  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	  See the License for the specific language governing permissions and
	  limitations under the License.
	=========================================================================================

Development Environment
=======================

Build Tools Required
---------------------

CIOC only uses build tools for combining and minifying Javascript files for 
production use. This build is performed on a windows computer with a Makefile
(GNU flavour) and `The Google Closure Javascript Compiler
<http://code.google.com/closure/compiler/>`_. Any recent version Make of should
be suitable but, the developers have used Cygwin, MSys or gnuwin32 as the
source of this tool. The build process also requires ``cat``, ``unix2dos``,
``Python``, and the Closure Compiler depends on ``java``.

The makefile assumes that the Closure Compiler's ``compiler.jar`` file is
installed to ``c:\bin`` and that the other tools are in your ``PATH``.

To perform the build:

#. Change to the scripts directory:
	
	.. code-block:: text
	
		d:\> cd VirtualServers\SiteName\scripts

#. Run Make:

	.. code-block:: text

		d:\VirtualServers\SiteName\scripts> make



