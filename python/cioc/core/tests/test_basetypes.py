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


from cioc.core.basetypes import IsIDType


def test_is_id_type():
    def do_test(val, expect):
        assert bool(IsIDType(val)) == expect

    tests = [
        (0, False),
        (1, True),
        (-1, False),
        (2147483647, True),
        (2147483648, False),
        ("a", False),
        ("0xCD", False),
    ]
    for val, expect in tests:
        yield do_test, val, expect
