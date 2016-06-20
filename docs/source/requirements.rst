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

.. _requirements:

Software Requirements
=====================

CIOC System configuration consists of 2 boxes, a database box and a
web/application box.


Database Box
------------

* Windows Server 2003 R2 or later. [#actualwindb]_
* SQL Server 2008 R2. [#actualsqldb]_

Hardware requirements should follow those of Windows Server and SQL Server.
Actual operational requirement will depend on the size and number of sites
deployed as well as traffic to those sites. 

CIOC currently has two database boxes. The sites are distributed between the
boxes and the hardware consists of:

1. CIOC_SQL_DB
    * Intel XEON 2x Quad Core CPU
    * 32GB RAM
    * 10x 146GB Hard drives arranged into 5 logical RAID mirrored drives
2. CIOC_SQL_DB2
    * Intel XEON 2x Hex Core CPU
    * 72GB RAM
    * 4x 146GB and 6x 600GB Hard drives, arranged into 5 logical RAID mirrored drives


Application Box
---------------

* Windows Server 2003 R2 or later running IIS. [#actualwinweb]_

Hardware requirements will depend on the size and number of sites deployed and
the traffic to those sites.

CIOC Currently has one web server/application box deployed:

1. CIOC_VS_HOST
   * Intex XEON 2x Quad Core CPU
   * 16GB RAM
   * 4x 146GB Hard drives arranged into 2 locical RAID mirrored drives


.. _app_software_dependencies:

Application Software Dependencies
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

CIOC Software uses both Classic ASP and Python to provide the full Online
Resources Application URL hierarchy. The `Apache Web Server
<http://httpd.apache.org>`_ in a `reverse proxy configuration
<http://httpd.apache.org/docs/2.2/mod/mod_proxy.html#forwardreverse>`_ is used
to unify the hierarchy.

Some Python libraries are written in C and don't work correctly inside IIS
without being rebuilt with a `small modification to the Python standard library
distutils tool
<http://groups.google.com/group/isapi_wsgi-dev/msg/aa11ed3058e73660>`_
[#pywin32manifest]_. Rebuilt libraries are available from
http://clientservices.kclsoftware.com/cioc/basket.

CIOC sofware uses the following software and libraries:

* Apache 2.2 [#apachelounge]_
   * mod_log_rotate 1.00a
   * ApacheStats (for monitoring to MRTG) `from the Apache Lounge download
     page`_ with the Memory Add on.
* Python 2.7 Win32
   * setuptools or distribute
   * virtualenv 
   * Python for Windows Extensions (to allow embedding of Python into ASP pages)
     `version 216 <https://sourceforge.net/projects/pywin32/files/pywin32/>`_
   * pyodbc 2.1.9 (rebuilt with patched Python)
   * Pyramid 1.3 and its dependencies
   * lxml 2.3 (rebuilt with patched Python)
   * mako 0.3.6
   * pycrypto 2.3 (rebuilt with pached Python)
   * Babel 0.9.5
   * elementtree 1.2.7
   * pyramid_simpleform 0.6.1
   * pyramid_handlers 0.1
   * formencode 1.2.3
   * isodate 0.4.4
   * python_memcached 1.47
   * beaker 1.6dev
   * beaker_extensions 0.1.2dev
   * backports.ssl_match_hostname 3.2a3
   * redis 2.4.11
* Redis 2.2 or later [#actualredis]_

.. _from the Apache Lounge download page: http://www.apachelounge.com/download/



.. rubric:: Footnotes

.. [#actualwindb] Currently one DB box uses Windows Server 2003 R2 Standard and one uses
   Windows Server 2008 R2 Enterprise. Enterprise is being used to allow access
   to more memory.

.. [#actualsqldb] Edition does not matter. CIOC servers use SQL Server 2008 R2
   Standard

.. [#actualwinweb] Edition does not matter. CIOC servers use SQL Server 2003 R2
   Standard. Development happens on Windows 7 with IIS 7 (not suitable for
   deployment) so front end software should run on Windows Server 2008.

.. [#apachelounge] CIOC uses the windows build of apache and add on modules from
   `Apache Lounge <http://www.apachelounge.com/download/>`_

.. [#pywin32manifest] A request has been made to Python For Windows project to
   see if there is a better way of solving the problem.

.. [#actualredis] CIOC uses Redis 2.2 running on Ubuntu in a VirtualBox
	headless instance on the web server.
