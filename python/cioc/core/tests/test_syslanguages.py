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

from __future__ import absolute_import
from cioc.core import syslanguage


def test_active_cultures():
    assert not syslanguage.is_active_culture("en-CA")

    ac = syslanguage.active_cultures()
    assert len(ac) == 0

    ac = [x._replace(Active=True) for x in syslanguage._culture_list]

    syslanguage.update_cultures([x._asdict() for x in ac])

    new_ac = syslanguage.active_cultures()

    assert len(new_ac) == 2

    assert set(new_ac) == set(x.Culture for x in ac)

    assert syslanguage.is_active_culture("en-CA")
    assert not syslanguage.is_active_culture("blah")


def test_SystemLanguage():
    sl = syslanguage.SystemLanguage()

    def callback_fr(culture_description):
        assert culture_description.Culture == "fr-CA"

    sl.addListener(callback_fr)

    sl.setSystemLanguage("fr-CA")

    assert sl.LocaleID == 4105, "French LCID"

    def callback_en(culture_description):
        assert culture_description.Culture == "en-CA"

    sl = syslanguage.SystemLanguage()
    sl.addListener(callback_en)

    # invalid culture
    sl.setSystemLanguage("blah")
    assert sl.Culture == "en-CA"
