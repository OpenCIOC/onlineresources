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

.. _scheduledtasks:

Scheduled Task Configuration
============================

In addition to the core CIOC Online Resources software, there are a number of
tools that run as Scheduled Tasks which facilitate the operation and hosting of
the sites. These tools are found in the https://bitbucket.org/cioc/cioccronjobs
repository. These scripts depend on the ``lib`` directory from the
https://bitbucket.org/cioc/cioctools repository. On the CIOC server these
repositories are checked out to ``d:\tools`` as ``cioc`` and ``pycioc``
respectively. A virtualenv for running the ``cronjobscripts`` tools is installed
to ``d:\tools\toolspython`` and a ``pycioclib.pth`` file has been added to
``d:\tools\toolspython\lib\site-packages`` to ensure that
``d:\tools\pycioc\lib`` is added to the Python module path. See `Modifying
Python’s Search Path
<http://docs.python.org/2/install/index.html#modifying-python-s-search-path>`_
in the Python documentation for more information about .pth files.


The ``cioccronjobs`` repository has 3 subdirectories:

``cron``:
	includes most scheduled tasks each of which contains only 1 source file. See
	:ref:`cronscripts`.
``downloads``: 
	Generates the Access Download files. Also has the core configuration for
	per-database tasks. See :ref:`downloads`.
``volnotify``:
	Generates emails for Volunteer Profile matching email notifications. See
	:ref:`volnotify`.


Creating the Tools VirtualEnv
-----------------------------

These instructions assume that you have an already working Python installation
and have installed virtualenv for the main CIOC application.

#. Create a tools directory using a cmd.exe window:

	.. code-block:: text

		d:\> mkdir tools
		d:\> cd tools

#. Use virtualenv to make a workspace:

	.. code-block:: text

		d:\tools> c:\Python27\Scripts\virtualenv toolspython

#. Activate the virtualenv

	.. code-block:: text

		d:\tools> toolspython\Scripts\activate.bat

		(toolspython) d:\tools>

#. Add a .pth file to add pycioc/lib to toolspython virtualenv

	.. code-block:: text

		d:\tools> echo d:/tools/pycioc/lib > D:\tools\toolspython\Lib\site-packages\pycioclib.pth

#. clone common python tools shared library in git-bash

	.. code-block:: text

		$ cd /d/tools
		$ git clone git@bitbucket.org:cioc/cioctools.git pycioc
		$ git clone git@bitbucket.org:cioc/cioccronjobs.git cioc

#. also in git-bash download and extract 7za tool for downloads:

    .. code-block:: text
		
		$ mkdir -p /d/tools/bin
		$ cd /d/tools/bin
		$ curl -o 7za920.zip http://clientservices.kclsoftware.com/cioc/7za920.zip
		$ unzip 7za920.zip 7za.exe


Other Pre-Requisites And Configuration Options
----------------------------------------------

Some of the tools require a connection to a database. This connection uses the
cioc_maintenance_role role and is configured via the
``%CIOC_UDL_BASE%\DatabaseName\cron_job_runner.udl`` UDL file where DatabaseName matches
the name in the downloads\config.py file which should match the name of an
installed CIOC instance in d:\VirtualServers.

For running as scheduled tasks the scripts are executed using pythonw.exe
instead of python.exe. This makes it run without a console. The scripts detect
this and send email any errors instead of showing them on the console.

Scripts that opperate on a number of databases have an option to specifiy which
databases should be run by using one or more ``-a DatabaseName`` parameters.

There are some common environment variables that can configure standard locations:

``CIOC_TOOLS_PATH``:
	Location of CIOC tools and nightly task scripts. Defaults to ``d:\tools``.

``CIOC_VIRTUALSERVERS_BASE``:
	Location where CIOC web apps are installed. Defaults to ``d:\VirtualServers``.

``CIOC_TASK_NOTIFY_EMAIL``:
	Email to notify if something goes wrong with a nightly task. Only one email
	can be used because it is both a to and from. Multiple recipients can be
	configured by making the email a forwarding address with multiple
	recipients. Defaults to ``qw4afPcItA5KJ18NH4nV@cioc.ca``.

``CIOC_LOG_ROOT``:
	Location that CIOC logs are located. Each CIOC instance has its own
	directory under ``CIOC_LOG_ROOT`` and Apache logs are the first level,
	there are subdirectories for Python app and IIS logs. Defaults to
	``d:\logs``.

``CIOC_MAIL_HOST``:
	Server to connect to send email. Defaults to ``127.0.0.1``.

``CIOC_MAIL_USERNAME``:
	The username to use to connect to the mail server. Defaults to no username used.

``CIOC_MAil_PASSWORD``:
	The password to use to connect to the mail server. Defaults to no password used.

``CIOC_MAIL_USE_SSL``:
	Connect to the mail server using SSL. Defaults to not use SSL. Any
	non-empty value will enable SSL.

``CIOC_MAIL_PORT``:
	Connect to the mail server using the given port. Defaults to 465 if SSL is
	enabled, otherwise the default is port 25.

``CIOC_UDL_BASE``:
	Location that UDL files are stored. Each CIOC instance has its own
	directory under this with a ``cron_job_runner.udl`` file. Defaults to ``d:\UDLs``.


.. _cronscripts:

Cron Scripts
------------

The following scripts are included in the ``cron`` directory.

``cic_changes_for_vol.py``: 
	Emails Volunteer record owners when significant changes happen to the CIC
	record attached to their records. Runs nightly. This script support selecting
	databases to run agains using the ``-a DatabaseName`` parameter.

	.. code-block:: text

		D:\tools\toolspython\Scripts\pythonw.exe D:\tools\cioc\cron\cic_changes_for_vol.py

``compress_old_logs.py``:
	Puts log files that we modified more than 6 days ago in a dated zip file
	archive. Runs nightly.

	.. code-block:: text

		D:\tools\toolspython\Scripts\pythonw.exe d:\tools\cioc\cron\compress_old_logs.py

``cull_old_exports.py``:
	Clear out old files from the download directories of the Online Resources
	Software. Runs nightly.

	.. code-block:: text

		D:\tools\toolspython\Scripts\pythonw.exe d:\tools\cioc\cron\cull_old_exports.py

``geoip_download.py``:
	Downloads updated `Maxmind GeoLite Databases
	<http://dev.maxmind.com/geoip/geolite>`_ monthly.

	.. code-block:: text

		D:\tools\toolspython\Scripts\pythonw.exe D:\tools\cioc\cron\geoip_download.py

``getinvolvedapi.py``:
	Synchronises volunteer opportunities to getinvolved.ca twice weekly. This
	script support selecting databases to run agains using the ``-a
	DatabaseName`` parameter.

	.. code-block:: text

		D:\tools\toolspython\Scripts\pythonw.exe D:\tools\cioc\cron\getinvolvedapi.py

``nightly_db_maintenance.py``:
	Run the nightly tasks stored proceedure on all the database. Runs nightly.
	This script support selecting databases to run agains using the ``-a
	DatabaseName`` parameter.

	.. code-block:: text

		D:\tools\toolspython\Scripts\pythonw.exe D:\tools\cioc\cron\getinvolvedapi.py

``process_logged_errors.py``:
	Looks for errors in the server logs and emails them to
	qw4afPcItA5KJ18NH4nV@cioc.ca. Runs every 15 minutes.

	.. code-block:: text

		D:\tools\toolspython\Scripts\pythonw.exe d:\tools\cioc\cron\process_logged_errors.py

``process_logs.py``:
	Runs the awstats tool on the logs nightly.

	.. code-block:: text

		D:\tools\toolspython\Scripts\pythonw.exe d:\tools\cioc\cron\process_logs.py -c

``update_offline_tools_map.py``:
	Updates the mapping of database domain names to ssl compatible names that
	can be used for the offline tools. Runs nightly.
	This script support selecting databases to run agains using the ``-a
	DatabaseName`` parameter.

	.. code-block:: text

		D:\tools\toolspython\Scripts\pythonw.exe D:\tools\cioc\cron\update_offline_tools_map.py
	

.. _downloads:

Downloads
---------

The Downloads tool generates CIC and VOL Access record downloads Tue-Sat @
3:00am and the CIC and VOL Stats downloads Sun @ 3:00am. It depends on the `7za
7-Zip command line version <http://www.7-zip.org/download.html>`_ being in the
``%CIOC_TOOLS_PATH%\bin``.

The downloads tool is made up of:

``newdownloads.py``:
	The core application for processing databases and members, calls into the
	``dbcopy.py`` file to do the actual copying and ``ziptool.py`` to compress
	the resulting Access database. It uses the contents of ``config.py`` to know
	which databases have which modules.
	This script support selecting databases to run agains using the ``-a
	DatabaseName`` parameter.

``dbcopy.py``:
	The core engine for dumping a set of tables to an Access database. This is
	also used by the Client Tracker downloads.

``ziptool.py``:
	Wraps up calling 7za with a zip password.

``db``:
	Location of empty template database and filled databases.

``zips``:
	Temporary location for storing zipped Access database before they get copied
	over the old zip in the ``download`` folder.

``config.py``:
	This contains the description of the databases, modules and tables that are
	to be added to the downloads. See the :ref:`downloadconfig` section.

.. _downloadconfig:

Downloads Configuration File
****************************

The ``config.py`` file exposes several variables that are used to control which
databases, software modules, tables and even records and fields are copied to
an access database download.

The following variables are exported:

``dbdir``:
	The path to the folder that containes the database files.
``zipdir``:
	The path to the folder that contains the zipped database files.
``zipprg``:
	The path to the program to generated the zip files
``zipargs``:
	The template for the arguments to be passed to the zip program.
``finalzip``:
	The template for the path to the final location for the zip file. i.e. the
	online resources software download directory.
``srcdts``:
	template for the connection dts for the source database.
``dbinfo``:
	A ``list`` of ``DBInfo`` ``namedtuples``. There is one tuple for each
	database to run downloads for. The tuple values are, in order, ``dbname``,
	``flavours``, and ``skip``.
``old_sites``:
	A dictionary of database names to password dictionaries for the CLBC
	databases that have not upgraded past Online Resources software version 3.5.
``skip_tables``:
	A dictionary of download type to list of patterns for tables to skip.
``skip_columns``:
	A dictionary of download types to dictionary of patterns for tables to list
	of patterns of column names to skip.
``conditions``:
	A list of tuples where the first element is a pattern to match a table name
	and the second element is a method of determining the criteria to select
	only the records that belong to a particular membership in the database.
	The second element could be ``None``, indicating take all records, a string,
	to be used as the condition (this may include joining with other tables), or
	a heuristic function that is passed the db_copier instance, the list of
	names of all tables in the database and the name of the current table.

In the previous list a "pattern" is a valid `fnmatch
<http://docs.python.org/2/library/fnmatch.html>`_ pattern. The ``skip_tables``
and ``skip_columns`` variable are derrived from the following variables:

``daily_skip_tables``:
	List of patterns for tables to skip when doing daily record downloads.
``cic_skip_tables``:
	List of patterns for tables to skip when doing CIC downloads.
``vol_skip_tables``:
	List of patterns for tables to skip when doing VOL downloads.

Downloads Scheduled Tasks
+++++++++++++++++++++++++

- Weekdays for record data

	.. code-block:: text

		D:\tools\toolspython\Scripts\pythonw.exe D:\tools\cioc\downloads\newdownloads.py

- Weekly for stats data

	.. code-block:: text

		D:\tools\toolspython\Scripts\pythonw.exe D:\tools\cioc\downloads\newdownloads.py -s


.. _volnotify:

Volunteer Profile Notifications
-------------------------------

The volunteer profile notification run twice weekely to send emails to volunteer
matching profile users who have requested to have emails about new or updated
postions. The emails are sent according to their search criteria.

``volnotify.py``:
	Generates emails for positions that are new or changed according to
	Volunteer Matching Profile user settings.
	This script support selecting databases to run agains using the ``-a
	DatabaseName`` parameter.
``test_volnotify``:
	Tests to ensure that predicates used in ``volnotify.py`` are working
	correctly.
``emailtmpl_en_CA.txt``, ``emailtmpl_fr_CA.txt``:
	Templates for the core part of the sent email in French (fr) and English
	(en).
``linktmpl_en_CA.txt``, ``linktmpl_fr_CA.txt``:
	Templates for the individual links to be send in the email in French (fr)
	and English (en).
