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

.. _dbconfiguration:

Database Configuration
======================


About the Databases
-------------------

There are 3 databases that make up a running CIOC application:

#. The Primary Application Database (SiteName_2010_11)

#. The Shared Library Database (cioc_shared)

#. The `AIRS/211 LA County Taxonomy of Human Services <http://211taxonomy.org>`_
   Updater Databse (tax_updater)

The last two are shared with all databases running on the box. ``cioc_shared``
is required to run the software and ``tax_updater`` is only required when
attempting to load a new version of the Taxonomy into the Primary Application
database.

There is often also a ``cioc_setup_source`` database which is used by tools as
a data source for new installs and upgrades. For instance the field option
updater scripts get source data from the ``cioc_setup_source`` database.

``DataLoader`` may also be present. This is used as a staging area for import
of member specific data.


About Database Roles (Security)
-------------------------------

There are 4 application defined Database Roles included in the Primary
Application Database:

#. ``cioc_login_role``

#. ``cioc_cic_search_role``

#. ``cioc_vol_search_role``

#. ``cioc_maintenance_role``

There are two application defined Database Role included in the cioc_shared
database:

#. ``cioc_login_role``

#. ``cioc_maintenance_role``

The tax_updater database only have one application defined Database Role, the
``tax_updater_role``.

Permissions to access the database structures has been granted to each of these
roles based on the intended use of the role. CIOC servers have 1 shared login
for all databases assigned to the ``cioc_maintenance`` role in cioc_shared and
the Primary Application Database.  A separate user is configured for each of the
other roles in each Primary Application database.

So if we had Primary Application Databases ``SiteName_2010_11`` and
``OtherSite_2010_11`` we would have the following configuration:

* ``SiteName_2010_11``
    * ``web_sitename``: ``cioc_login_role``
    * ``web_sitename_srch_cic``: ``cioc_cic_search_role``
    * ``web_sitename_srch_vol``: ``cioc_vol_search_role``
    * ``cioc_maintenance_user``: ``cioc_maintenance_role``
* ``OtherSite_2010_11``
    * ``web_othersite``: ``cioc_login_role``
    * ``web_othersite_srch_cic``: ``cioc_cic_search_role``
    * ``web_othersite_srch_vol``: ``cioc_vol_search_role``
    * ``cioc_maintenance_user``: ``cioc_maintenance_role``
* ``cioc_shared``
    * ``web_sitename``: ``cioc_login_role``
    * ``web_sitename_srch_cic``: ``cioc_login_role``
    * ``web_sitename_srch_vol``: ``cioc_login_role``
    * ``web_othersite``: ``cioc_login_role``
    * ``web_othersite_srch_cic``: ``cioc_login_role``
    * ``web_othersite_srch_vol``: ``cioc_login_role``
    * ``cioc_maintenance_user``: ``cioc_maintenance_role``, ``cioc_login_role``
* ``tax_updater``
    * ``web_sitename``: ``tax_updater_role``
    * ``web_othersite``: ``tax_updater_role``

No permissions should be given to anything but admistrative users (like ``sa``) for
``cioc_setup_source`` or ``DataLoader``.


Database Schemas & Tools
------------------------

The full schemas for the 3 databases mentioned above are kept in git based source control at
http://bitbucket.org/cioc/ciocsql. This location is user and password protected. The source
repository contains 3 folders, one for each of the databases:

* ``cic``
* ``cioc_shared``
* ``tax_updater``

Each of these directories has a ``schema`` folder which contains the output of
the `ScriptDB <https://github.com/lambacck/ScriptDB>`_ tool. See the
:ref:`generatingscripts` section for details on how to update the schema out of
a running database.

``cic`` and ``cioc_shared`` have an ``upgrade`` folder which contains tools and
scripts for general upgrades or a specific software version.

``cic`` also has a ``tools`` folder which is for tools not specifically related
to upgrades. For instance, at the time of this writing there is a tool to copy
design templates from one database to another.

In each folder is may be the ``create_db.sql`` and ``fullschema.sql`` scripts.
The create script is for creating a database with the correct settings while
the full schema has combined scripts from the ``schema`` directories. See the
:ref:`generatingscripts` section for details on how to generate the
``fullschema.sql`` scripts.

The ``cic`` directory also has a ``post_create.sql`` script. This script is for
tasks that are not included in the scripted data in contents of the ``schema``
directory. This gets included in the ``fullschema.sql`` file after the rest of
the schema.



Initalizing a New Database With Core Data
-----------------------------------------

There is no canonical source of the core data (checklist, drop down, etc.). A
template database should be created that can be used to quickly create a new
member database. There is a script in the http://bitbucket.org/cioc/ciocsql
repository in ``cic/tools`` that can be used to copy most of this information
from another member.


.. _generatingscripts:

Generating Scripts
------------------

The ``generate_scripts.py`` tool in the root of the
http://bitbucket.org/cioc/ciocsql repository can be used to call the `ScriptDB
<https://github.com/lambacck/ScriptDB>`_ tool to generate the schemas for the
3 databases used by the CIOC Online Resources application. It expects ScriptDB
to be in your windows path. The tool must be run from the command line, here are
the options and structure of the command:

   .. code-block:: text

    usage: generate_scripts.py [-h] [-c CONSTR] [-v] database

    positional arguments:
      database

    optional arguments:
      -h, --help            show this help message and exit
      -c CONSTR, --constr CONSTR
      -v, --verbose

The ``database`` positional requirement is required and is the name of the core
database to be used as the source for scripting. The ``-c CONSTR`` option can be
used to override the default connection string, which is
``server=(local);trusted_connection=yes``. For instance it could be changed to
``Server=myServerAddress;User Id=myUsername;Password=myPassword;`` to use the
named server ``myServerAddress`` and use the given username and password instead
of using the current windows login. The ``--verbose`` parameter can be used to
print out the names of the components as they are scripted. This produces a
large amount of output very quickly.

Once the ``generate_scripts.py`` tool has completed, it is possible to run the 
``builddbscript.bat`` tool that comes with ``ScriptDB`` to generate a
``fullschema.sql`` file for the ``cioc_shared`` or ``tax_updater`` databases:

    .. code-block:: text

        > cd cioc_shared
        > builddbscript schema > fullschema.sql

For the ``cic`` database, the ``genfullschema.bat`` tool:

    .. code-block:: text

        > cd cic
        > genfullschema.bat

Upgrades
--------

For very small upgrades and bug fixes, CIOC database software is upgraded using
change scripts on an existing database. For full upgrades a new database is
created and the data copied from the old database into the new database. This
transfer is handled by a combination of scripts in the ``cic/upgrade`` folder of
the http://bitbucket.org/cioc/ciocsql repository and :ref:`dbcopytool` from
the https://bitbucket.org/cioc/cioctools repository.

The process roughly follows these steps:

#. Create database using ``create_db.sql``. The target name must be changed for
   each database being upgraded. This script will put the database into the
   ``BULK_LOGGED`` recovery mode to facilitate fast transfer of the data from
   the source to the target databases. The recovery mode should be set to
   ``FULL`` after the transfer is complete. See below.
   once all the 
#. Populate the schema of the database using ``fullschema.sql``
#. Use the ``upgrade/2012-11-PreTransfer.sql`` script to copy basic required
   data from the source database to the target database. There should be an
   updated/new version of this for each release. Be sure to update the source
   database using search and replace for each database being upgraded before
   running the tool. See :ref:`pretransfertool`.
#. Copy data with :ref:`dbcopytool`. This tool needs to be update for each
   release.
#. While waiting for previous step, add logins to new database.
#. Use ``upgrade/2012-11-PostTransfer.sql`` tool to do finalization of core
   data. There should be an updated/new version of this for each release. Be
   sure to update the source database using search and replace for each database
   before running the tool.  See :ref:`posttransfertool`.
#. Run the ``upgrade/CIC_FieldOption_Updater.sql`` tool. See
   :ref:`fieldoptionupdaters`
#. Run the ``upgrade/VOL_FieldOption_Updater.sql`` tool. See
   :ref:`fieldoptionupdaters`
#. Run the ``upgrade/GBL_PageInfo_Updater.sql`` tool. See :ref:`pageinfoupdater`.
#. Run the ``upgrade/CopyFieldHistory.sql`` tool. The source database must be
   updated on this tool before every upgraded database. See
   :ref:`copyfieldhistory`.
#. Run the ``upgrade/CopyStats.sql`` tool. The source database must be
   updated on this tool before every upgraded database. This can be run more
   than once provided front end has not been directed at new database. See
   :ref:`copystats`.
#. Set database recovery mode to ``FULL``.
#. Update front end software and direct connections to the new database.

Prior to an upgrade, :ref:`pretransfertool` and :ref:`posttransfertool` SQL
Scripts need to be upgraded along with :ref:`dbcopytool`. 

.. _pretransfertool:

The Pre-Transfer Tool
*********************

The Pre-Transfer Tool transfers data that would be difficult to transfer with
the dbcopy tool. As of this writing it transfers:

* ``STP_Language``: First it inserts all current values, then copies the
  ``Active`` and ``ActiveRecord`` values from the source database. Insert
  statements for current software version can be gerated by
  :ref:`spgenerateinserts`.

* ``GBL_PageInfo``: Insert statements for the current software version can be
  generated by :ref:`spgenerateinserts`.

* ``GBL_PageInfo_Description``: First it inserts all the current values, then it
  copies the ``TitleOverride`` value from the source database. Insert statements
  for teh current software version can be generated by :ref:`spgenerateinserts`.

* ``GBL_Template_Layout``: Copied from the source database except that
  ``MemberID`` and ``Owner`` are set to ``NULL`` and ``SystemLayout`` is set to
  1 for *all* layouts. This is because we *must* have a template for a member
  and a layout for a template and ``MemberID`` can only be null if
  ``SystemLayout`` is ``1``. The correct values for ``MemberID``, ``Owner`` and
  ``SystemLayout`` will be set in :ref:`posttransfertool`.

* ``GBL_Template``: Copied from the source database except that ``MemberID`` and
  ``Owner`` are set to ``NULL`` and ``SystemTemplate`` is set to 1 for *all*
  templates. This is because we *must* have a template for a member and a layout
  for a template and ``MemberID`` can only be null if ``SystemTemplate`` is ``1``.
  The correct values for ``MemberID``, ``Owner`` and ``SystemTemplate`` will be
  set in :ref:`posttransfertool`.

* Sometimes new core data is required and it is often convienient to generate
  inserts using :ref:`spgenerateinserts`. For instance in the 3.5 release
  (2012-11) the ``GBL_ExternalAPI`` and ``GBL_ExternalAPI_Description`` tables
  were initially populated using the :ref:`pretransfertool`.


.. _dbcopytool:

The DB Copy Tool
****************

The DB Copy Tool is used to transfer the bulk of the data during an upgrade. It
consists of a core engine for transfering data between SQL Server databases and
configuration files that describe how to transfer the data. The tool is also
used in upgrading the Client Tracker software. The tool can be found as part of
the `cioctools <https://bitbucket.org/cioc/cioctools>`_ repository in the
``dbcopy`` directory. It depends on `pywin32
<http://sourceforge.net/projects/pywin32/>`_ and the ``lib`` directory of the
cioctools repo. The tool will try to add the ``lib`` directory to the python
path if it can't import ``cioc.db.adohelper``.

The tool consists of ``copydb.py`` (the core transfer engine), ``setup.py``
(python packaging configuration to generate a py2exe based executable) and a set
of ``table_order*.py`` files. There are multiple ``table_order*.py`` files to
support upgrading different CIOC databases (like the Online Resources Software
and the Client Tracker). There is also the ``table_order*_same_version.py``
variants which allow for transfer of data within the same version of the
software. Generally the ``same_version.py`` are only updated when they are
needed and the other ones are upgraded with each realease of the particular
software they target.

The tool must be run from the command line, here are the options and structure
of the command:

   .. code-block:: text

        Usage: dbcopy.py [options]

        Options:
          -h, --help            show this help message and exit
          -s SRCDB, --srcdb=SRCDB
                                Source Database
          -d DSTDB, --dstdb=DSTDB
                                Destination Database
          -S SRCSVR, --srcsvr=SRCSVR
                                Source Server
          -D DSTSVR, --dstsvr=DSTSVR
                                Destination Server
          -u SRCUSER, --srcuser=SRCUSER
                                Source Username
          -U DSTUSER, --dstuser=DSTUSER
                                Destination Username
          -p SRCPASS, --srcpass=SRCPASS
                                Source Password
          -P DSTPASS, --dstpass=DSTPASS
                                Destination Password
          -V, --same-version    Same Version
          -b, --basic-setup     Basic Setup
          -c, --client-tracker  Client Tracker

The tool defaults to the Online Resources Software and as of this writing *must*
use SQL Server logins (i.e. not domain logins). ``-s``, ``-d``, ``-u``, and
``-p`` are required parameters. ``-S`` and ``-D`` default to the local server.
``-U`` and ``-P`` default to the values given for ``-u`` and ``-p``
respectively. ``--client-tracker`` selects the ``table_order_ct`` variant of the
table order description for use with the Client Tracker software.
``--same-version`` picks the ``table_order*_same_version.py`` table order
variant for either the Online Resources or Client Tracker software depending on
the absense or presence of the ``--client-tracker`` option, respectively.

Each table_order module must expose the ``tables`` and ``special_tables``
variables which specify the order in which to copy the tables and any data
transformations that must occur in order to transfer between the two database
versions. ``special_tables`` allows the transfer of data that includes a
reference cycle (it references itself either directly like in ``GBL_Community``
or indirectly like with ``GBL_Agency`` and ``GBL_BaseTable``). The tables in the
``special_tables`` variable are transferred first while keeping data to be
updated after the tables described in the ``tables`` variable have been
transferred. After all the tables in the ``special_tables`` and ``tables``
variables have transferred, the cached data is applied to the tables from
``special_tables``.

The format of the ``special_tables`` variable is a Python ``list`` of
``tuples``. The order of the items in the list is the order of transfer. The
items in the tuple in order are:

#. The name of the target table
#. A tuple of column names that are used as a key to reference a row in the
   database and perform an update
#. A tuple of column names that are to be cached and updated after all other
   data is transferred.
#. A string to be used to select the data to go into this table or ``None`` to
   have the system generate a default select statement.
#. A tuple of column names to skip when attempting to insert the data in the
   target system.

The format of the ``tables`` variable is a Python ``list`` of ``lists`` of
``tuples``. The items in the tuple in order are:

#. The name of the target table
#. A string to be used to select the data to go into this table or ``None`` to
   use the default select statement.
#. A tuple of columns to skip during insert.
#. (optional) a boolean value indicating if ``IDENTITY_INSERT`` should be disabled.

For the select string, a ``%s`` in the table will be substituted with the name
of the current target table. This is useful when a similar transfermation must
be made on a number of tables since the same select string can then be used. The
default select string is ``select * from %s``.

Strategies for updating the DB Copy Tool
++++++++++++++++++++++++++++++++++++++++

The Online Resource Software has a lot of tables. Determining what tables have
changed or what tables need to be added can be tricky. This section will discuss
strategies for updating a new ``table_order.py`` file.

First, assume the order in the ``table_order.py`` file is correct and set
all the select strings and skip tuples to ``None`` in all the tuples in the
lists in the tables list.

Next extract all the table names from from this file by copying it to another
file an using regular expressions remove everything but the table names. Sort
the list of tables alphabetically.

Generate a second file containing all the names of the tables in the current
version of the software. You can get this information out of SQL Server
Management Studio by running ``SELECT name FROM sys.tables ORDER BY name``.

Diffing the two files will give you a list of the new tables that need to be
added to the ``table_order.py`` file. These should be inserted into the order 
such that relationships are satisfied. If you know of tables that have changed
their structure or source from two tables or were split into two tables, you can
set the SELECT strings for these tables now.

The next step is to try running the tool to upgrade a site. This will probably
fail, but it will give you an error about what failed and why. Alter the select
string for the table and do this step again until the full transfer works.

.. _posttransfertool:

The Post-Transfer Tool
**********************

The Post-Transfer tool is used to clean up any transfer items that may not be
totally correct after a transfer. Mostly this copies data from
:ref:`pretransfertool` that can't be copied until depedencies are met or updates
cached values that were not properly copied in previous steps. In the 3.5
(2012-11) release ``GBL_Template`` and ``GBL_Template_Layout`` were updated with
the correct values for the ``MemberID``, ``Owner`` and
``SystemTemplate``/``SystemLayout`` fields. It also updated the new
``INTERNAL_MEMO`` caches for the CIC and VOL modules. Finally it ran 
``sp_STP_RegenerateUserFields`` to update the user added fields (extra and
publication) the Field Options table.

.. _fieldoptionupdaters:

The Field Option Updater Tools
******************************

The field option updaters for CIC and VOL can be found in the
http://bitbucket.org/cioc/ciocsql repository as
``upgrade/CIC_FieldOption_Updater.sql`` and
``upgrade/VOL_FieldOption_Updater.sql`` respectively. Both tools source
canonical data from the ``cioc_setup_source`` database. The data is transferred
to the ``cioc_setup_source`` datatase from the deleveloper's server using the SSMS
import/export data tool. This is a direct copy of the ``GBL_FieldOption*`` and
``VOL_FieldOption*`` tables from the developers version of the software. The
tool is run in SSMS in a target database. It will provide information about new
and updated fields. It also lists fields that were not matched. By default these
fields are not deleted, but if the ``@ClearUnmatchedFields`` variable is set to
1 then the tool will delete unmatached fields.

.. _pageinfoupdater:

The Page Info Updater
*********************

The page info updater can be found in the http://bitbucket.org/cioc/ciocsql
repository as ``upgrade/GBL_PageInfo_Updater.sql``.  The tools sources canonical
data from the ``cioc_setup_source`` database. The data is transferred to the
``cioc_setup_source`` datatase from the deleveloper's server using the SSMS
import/export data tool. This is a direct copy of the ``GBL_PageInfo*`` tables
from the developers version of the software. The tool is run in SSMS in a target
database. It will provide information about new and updated pages. This is
generally used for subsequent data updates, for instance once page help has been
written/updated, rather than during the upgrade.

.. _copyfieldhistory:

The Copy History Tool
*********************

There can be a lot of data in the ``GBL_BaseTable_History`` and
``VOL_Opportunity_History`` tables, the Copy History Tool copies this data in a
safe and efficient manner without making the transaction log too big. The
performance of this tool is improved when the recovery mode of the database is
set to ``BULK_LOGGED``. This tool is also designed to be interrupted and
restarted. The Copy History Tool can be found in the
http://bitbucket.org/cioc/ciocsql repository as
``upgrade/CopyFieldHistory.sql``,

.. _copystats:

The Copy Stats Tool
*******************

There can be a lot of data in the ``CIC_Stats_RSN`` and
``VOL_Stats_OPID`` tables, the Copy Stats Tool copies this data in a
safe and efficient manner without making the transaction log too big. The
performance of this tool is improved when the recovery mode of the database is
set to ``BULK_LOGGED``. This tool is also designed to be interrupted and
restarted. The Copy History Tool can be found in the
http://bitbucket.org/cioc/ciocsql repository as
``upgrade/CopyStats.sql``,

.. _spgenerateinserts:

The sp_generate_inserts tool
****************************

:ref:`pretransfertool` uses the output of the `sp_generate_inserts
<https://github.com/lambacck/generate_inserts>`_ tool for basic data that all
sites require (like the contents of ``STP_Language``). A comment is placed
before each of these blocks in previous versions of :ref:`pretransfertool` which
includes the command to execute. For instance the command to generate the insert
statements for the ``GBL_PageInfo`` table is:

   .. code-block:: sql

    EXEC sp_generate_inserts 'GBL_PageInfo', @cols_to_exclude='''Notes'',''PageHelpVerified'''
