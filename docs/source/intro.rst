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

Introduction
============

CIOC Software is written for the Microsoft Windows Operating System and SQL
Server database engine.

The software was originally written for Classic ASP in VB Script. Because this
is now an under-supported platform, efforts have been made to transition to
`Python <http://python.org>`_ on the `Pyramid Web Framework
<http://www.pylonsproject.org/>`_. Details of the requirements are included in
the :ref:`requirements` section.

The transition away from Classic ASP is not complete, therefore extra web
server configuration is required to merge the two web application URL
hierarchies. In the CIOC deployed software this is accomplished using the `Apache
Web Server <http://httpd.apache.org>`_ in a `reverse proxy configuration
<http://httpd.apache.org/docs/2.2/mod/mod_proxy.html#forwardreverse>`_ in front
of the Python Application server and IIS. Further details about configuration of 
Apache, IIS and the Python environment are covered in the
:ref:`softwareconfiguration` section. 

Redis is used to provide an external transient data store for sessions
shared between Python and Classic ASP. Installation instructions are also found
in the :ref:`softwareconfiguration` section. 

Several Databases work in conjuction with one another in order to present the
final site. Information about these databases and the required security access
configuration is found in the :ref:`dbconfiguration` section.
