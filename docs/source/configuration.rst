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

.. _softwareconfiguration:

Front-End Configuration
=======================

About Where to Files Are Kept
-----------------------------

The CIOC online resources software locates its `virtualenv
<http://www.virtualenv.org>`_ and configuration file relative to the application
installation. CIOC puts sites, tools and configuration on the d: drive in the
following layout:

   .. code-block:: text
      
      d:\
      + --> d:\ciocenv31\
      + --> d:\config\
      |     + --> d:\config\SiteName.ini
      |     + --> d:\config\site2.ini
      + --> d:\Logs\
            + --> d:\Logs\SiteName\
            + --> d:\Logs\site2\
      + --> d:\tools\
      + --> d:\VirtualServers\
            + --> d:\VirtualServers\SiteName\
            + --> d:\VirtualServers\site2\

The ``.ini`` files must match the name under ``d:\VirtualServers\`` and CIOC has
this name match the name of the dated database that goes with this site. For
instance, in the above example there would be a databases named
``SiteName`` and ``site2_2010_11`` where ``_2010_11`` refers to the release
date. Upgrades are performed by creating a new dated database and copying the
data, so the date extension will always refer to the release of the software the
site is running.

Note that ``VirtualServers`` is available to the web server which is why ``ciocenv31``,
``config``, ``Logs`` and ``tools`` are not in ``VirtualServers``.

Installing Redis
----------------

There are only production ready builds of Redis that run on Linux. CIOC does
not have a Linux server. Instead, Ubuntu and Redis are running in a VirtualBox
virtual machine on the web server box. In practice this adds minimal load to
the server. In development and for Ontario CIOC, Redis is run on an external
Linux box with no issues.

For CIOC default Ubuntu configuration is used except for ``maxmemory-policy``
which is set to ``allkeys-lru`` and ``maxmemory`` which is set according to the
load expected for the box. CIOC production uses ``1gb``. 


Installing Apache
-----------------

CIOC uses the latest 2.2 version of the `Apache Lounge
<http://www.apachelounge.com/download>`_ build of Apache. Configuration files are
available from https://thatsmymeatball.com/svn/cioc/servers/trunk/apache.

#. download and extract the latest 2.2 version of Apache to ``c:\``
   [#apacheextract]_.

#. Checkout https://thatsmymeatball.com/svn/cioc/servers/trunk/apache to
   ``c:\Apache2\conf`` [#apacheconf]_

#. Create Apache service:

   .. code-block:: text

      c:\Apache2\bin> httpd -k install

#. Download and extract latest version of mod_log_rotate from `Apache Lounge
   <http://www.apachelounge.com/download>` to ``c:\Apache2\modules``

#. Add shortcut to ``c:\Apache2\bin\ApacheMonitor.exe`` to Startup folder

#. Run Apache Monitor

#. Use Apache Monitor to start the httpd service if not started (you may need to
   disable sites listening on port 80 or 443 in IIS).

Apache Site Configuration
-------------------------

Sites are configured in Apache by adding a new file for the site to
``c:\Apache2\conf\sites``. The site file looks like: [#apachesiteformat]_

   .. literalinclude:: site.conf
      :language: apacheconf



Getting the Application
-----------------------

The CIOC Online Resources Software is managed using git and latest
development versions are available from http://bitbucket.org/cioc/ciocweb. The
latest development version is in the branch ``master`` release versions are in
branches per release. These locations are user and password protected, so you
may have limited access or you may have been provided with the source as a zip
file.

Checkout or extract the Site to ``d:\VirtualServers\SiteName``.

Installing Python and Creating A VirtualEnv
-------------------------------------------

.. note::

   CIOC Requires Python 2.7. It does not work with versions before Python
   2.7 or after 3.0.


#. Install, or find `Python 2.7
   <http://python.org/download/releases/2.7.2/>`_ for your system.

#. Install the `Python for Windows extensions
   <http://sourceforge.net/projects/pywin32/files/>`_.  Make sure to
   pick the right download for Python 2.7 and install it using the
   same Python installation from the previous step.

#. Install latest `distribute <http://packages.python.org/distribute/>`_
   distribution into the Python you obtained/installed/found in the step above:
   download `distribute_setup.py <http://python-distribute.org/distribute_setup.py>`_ and
   run it using the ``python`` interpreter of your Python 2.7 installation
   using a command prompt:

   .. code-block:: text

      d:\> c:\Python27\python distribute_setup.py

#. Use that Python's `bin/easy_install` to install `virtualenv`:

   .. code-block:: text

      d:\> c:\Python27\Scripts\easy_install virtualenv

#. Use that Python's virtualenv to make a workspace:

   .. code-block:: text

      d:\> c:\Python27\Scripts\virtualenv ciocenv31

#. Activate ``ciocenv31``:

   .. code-block:: text

      d:\> ciovenv\Scripts\activate.bat

      (ciocenv31) d:\>


Installing Compiled Python Dependencies
---------------------------------------

There is a problem with loading some Python C extensions into Classic ASP this
issue is worked around by modifying the installed python's distutils and rebuilding the 
extensions. CIOC provides a script to get these dependencies from KCL's
servers. You can also point it to a local disk cache if you have been provided
with this.


#. Navigate to the python directory of the CIOC distribution:

   .. code-block:: text

      (ciocenv31) d:\> cd VirtualServers\SiteName\python

#. Run the buildenv.py script to install the compiled dependencies into your activated virtualenv

   .. code-block:: text
      
      (ciocenv31) d:\VirtualServers\SiteName\python> python buildenv.py

If neccessary you can change the location to look for the packages using the `--root` option.


Installing Other Python Dependencies
------------------------------------

The remaining dependencies are described in a pip requirements file. Run pip to
install the remaining dependencies:

   .. code-block:: text

      (ciocenv31) d:\VirtualServers\SiteName\python> pip install -r stable-reqs.txt


Configuring the Database Connection
-----------------------------------

The site gets its database configuration from an ``.ini`` that matches the file in the 
Create ``d:\config\SiteName.ini`` with the contents like:

   .. code-block:: ini
      
      [global]
      server=10.10.10.16
      database=SiteName_2010_11
      session.type=redis
      session.url=10.10.10.10:6379
      cache.type=redis
      cache.url=10.10.10.10:6379
      
      ; admin user has write permissions
      admin_uid=web_sitename
      admin_pwd=thepassword

      ; limited user for CIC search and public stuff
      cic_uid=web_sitename_srch_cic
      cic_pwd=anotherpassword

      ; limited user for VOL search and public stuff
      vol_uid=web_sitename_srch_vol
      vol_pwd=password3


Installing the Python Service
-----------------------------

The python process runs as a windows service. The service can be installed
using the ``install_svc.py`` tool which like the ``buildenv.py`` tool is
located in the python directory of the CIOC application.

#. Navigate to the python directory of the CIOC distribution:

   .. code-block:: text

      (ciocenv31) d:\> cd VirtualServers\SiteName\python

#. Run the install_svc.py script to install the windows service and have it
listen to the specified port. This port needs to match the port configured for
the PYTHON_PORT in the apache configuration.

   .. code-block:: text
      
      (ciocenv31) d:\VirtualServers\SiteName\python> python install_svc.py 6543


This will create the PyCiocSiteName service with a description of "CIOC
SiteName" and configure it to automatically start at system boot.


Upgrades, Conflicting Package Versions and virtualenv
-----------------------------------------------------

The advantage of ``virtualenv`` is that it allows us to have two installations
of Python with a different set of package dependancies installed. If an upgrade
requires conflicting package versions, then ``ciocenv31`` environment should be
changed to a different name. Note that ``includes\core\incInitPython.asp``, and
the ``install_svc.py`` tool need to be updated to reflect the new environment
name. This should be done as part of a new release. Also, the ``update_svc.py``
tool located in the same directory as the ``install_svc.py`` tool should also
be updated with the current environment name and used to change the
configuration settings during upgrade time.



.. rubric:: Footnotes

.. [#apacheextract] the Apache2 directory is included in the zip file so Apache
   will be installed to ``c:\Apache2``

.. [#apacheconf] For dev box use
   https://thatsmymeatball.com/svn/cioc/servers/trunk/dev_apache instead. For
   Ontario CIOC use
   https://thatsmymeatball.com/svn/cioc/servers/trunk/ontario_apache instead.

.. [#apachesiteformat] Omit the ``<VirtualHost *:443>`` and``notssl.conf`` include if not using SSL.
 
