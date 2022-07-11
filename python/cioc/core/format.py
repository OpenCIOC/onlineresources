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

# stdlib
import re

# 3rd party
from markupsafe import escape, Markup


_lots_of_html = re.compile(
    r"(<br>)|(<br ?/>)|(<p>)|(<a\s+href)|(<b>)|(<strong>)|(<i>)|(<em>)|(<li>)|(<img\s+)|(<table\s+)|(<table>)|(&nbsp;)|(&amp;)|(h[1-6]>)|(<span[\s>])|(<div[\s>])",
    re.I,
)
_html_line_breaks = re.compile(r"(<br>)|(<br ?/>)|(<p>)", re.I)


def textToHTML(strText):
    if not strText:
        return None

    br = Markup("&nbsp;<br>")
    if not _lots_of_html.search(strText):
        return escape(strText).replace("\r\n", br).replace("\n", br).replace("\r", br)

    elif not _html_line_breaks.search(strText):
        return Markup(strText).replace("\r\n", br).replace("\n", br).replace("\r", br)

    else:
        return Markup(strText)
