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

import pyodbc
import typing as t

import cioc.core.constants as const

if t.TYPE_CHECKING:
    from .syslanguage import SystemLanguage
    from .pageinfo import PageInfo

PERMISSION_ADMIN = "admin"
PERMISSION_CIC = "cic"
PERMISSION_VOL = "vol"

PermType = t.Literal[PERMISSION_ADMIN, PERMISSION_CIC, PERMISSION_VOL]


class ConnectionError(Exception):
    pass


class SupportsConfigLanguageAndPageinfo(t.Protocol):
    config: dict
    language: "SystemLanguage"
    pageinfo: t.Optional["PageInfo"]


class ConnectionManager:
    def __init__(self, request: SupportsConfigLanguageAndPageinfo):
        self.request = request
        self.config = request.config

    def get_connection_string_base(self, perm: PermType) -> str:
        config = self.config
        settings = [
            ("Server", config["server"]),
            ("Database", config["database"]),
            ("UID", config[perm + "_uid"]),
            ("PWD", config[perm + "_pwd"]),
        ]

        return ";".join("=".join(x) for x in settings)

    def get_connection_string(self, perm: PermType) -> str:
        driver = self.config.get("driver", "ODBC Driver 18 for SQL Server")
        return ";".join(
            [
                f"Driver={driver}",
                self.get_connection_string_base(perm),
                "Encrypt=Optional",
            ]
        )

    def get_asp_connection_string(self, perm: PermType, language: str) -> str:
        settings = [
            ("Provider", self.config.get("provider", "MSOLEDBSQL.19")),
            ("DataTypeCompatibility", "80"),
            ("Persist Security Info", "True"),
            ("Current Language", language),
            ("Encrypt", "Optional"),
        ]

        settings = ";".join("=".join(x) for x in settings)
        return ";".join([settings, self.get_connection_string_base(perm)])

    def get_connection(
        self, perm: t.Optional[PermType] = None, language: t.Optional[str] = None
    ) -> pyodbc.Connection:
        if not language:
            language = self.request.language.LanguageAlias

        if not perm:
            pageinfo = getattr(self.request, "pageinfo", None)
            if pageinfo and pageinfo.DbArea == const.DM_VOL:
                perm = PERMISSION_VOL
            else:
                perm = PERMISSION_CIC

        try:
            conn = pyodbc.connect(
                self.get_connection_string(perm), autocommit=True, unicode_results=True
            )
            conn.execute("SET LANGUAGE '" + language + "'")
        except pyodbc.Error as e:
            raise ConnectionError(e)

        return conn
