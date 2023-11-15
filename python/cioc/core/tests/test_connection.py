# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

import os


from unittest import mock


from cioc.core import connection, syslanguage, config, constants as const


app_path = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
app_name = os.path.split(app_path)[1]
real_config_location = os.path.join(app_path, "..", "..", "config", app_name + ".ini")


class DummyObject:
    pass


fake_settings = {"server": "server", "database": "database"}
permissions = ["cic", "vol", "admin"]
settings = ["uid", "pwd"]
fake_settings.update(
    ["_".join((perm, setting))] * 2 for perm in permissions for setting in settings
)


class Test_ConnectionMgr:
    @classmethod
    def setUpAll(self):
        self.request = DummyObject()

        self.culture_list_before = syslanguage._culture_list
        syslanguage.update_cultures(
            x._replace(Active=True)._asdict() for x in syslanguage._culture_list
        )

        self.request.language = syslanguage.SystemLanguage()

    @classmethod
    def tearDownAll(self):
        syslanguage._culture_list = self.culture_list_before
        syslanguage.update_culture_map()

    def test_connection_mgr(self):
        cnnmgr = connection.ConnectionManager(self.request, fake_settings.copy())
        cnstr_base = "Server=server;Database=database;UID=%(perm)s_uid;PWD=%(perm)s_pwd"

        def run_test(perm):
            base = cnstr_base % {"perm": perm}
            assert cnnmgr.get_connection_string_base(perm) == base
            assert cnnmgr.get_connection_string(perm) == (
                "Driver={ODBC Driver 17 for SQL Server};" + base
            )

        for p in permissions:
            yield run_test, p

    def test_get_connection(self):
        cnnmgr = connection.ConnectionManager(self.request, fake_settings.copy())

        mocked_connection = mock.Mock()
        mocked_connect = mock.Mock()
        mocked_connect.return_value = mocked_connection

        @mock.patch("pyodbc.connect", mocked_connect)
        def run_test(kw, expected_perm, expected_language):
            mocked_connect.reset_mock()
            mocked_connection.reset_mock()

            conn = cnnmgr.get_connection(**kw)

            connection_string = cnnmgr.get_connection_string(expected_perm)
            mocked_connect.assert_called_once_with(connection_string, autocommit=True)

            conn.execute.assert_called_once_with(
                "SET LANGUAGE '" + expected_language + "'"
            )

        yield run_test, {}, "cic", "English"

        for language, expected_ln in [("a", "a"), (None, "English")]:
            for perm in ("cic", "vol", "admin"):
                yield run_test, {"perm": perm, "language": language}, perm, expected_ln

        pageinfo = self.request.pageinfo = DummyObject()

        for DM, perm in [
            (const.DM_CIC, "cic"),
            (const.DM_VOL, "vol"),
            (const.DM_GLOBAL, "cic"),
        ]:
            pageinfo.DbArea = DM
            yield run_test, {}, perm, "English"
