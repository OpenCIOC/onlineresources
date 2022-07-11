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

import logging

from itertools import groupby
from operator import attrgetter

from markupsafe import Markup, escape

from cioc.core.i18n import gettext as _

log = logging.getLogger(__name__)


def link_code(request, link_text, naics_codes, link_page=None):
    if not request.viewdata.PrintMode and link_page:
        return Markup('<a href="%s">%s</a>') % (
            request.passvars.makeLink(link_page, {"NAICS": naics_codes}),
            link_text,
        )

    return escape(link_text)


def get_exclusions(request, naics_code, link_page=None, all_langs=False):
    with request.connmgr.get_connection() as conn:
        cursor = conn.execute(
            "EXEC dbo.sp_NAICS_Exclusion_l ?,?", str(naics_code), all_langs
        )
        exclusions = cursor.fetchall()

        cursor.nextset()

        uses = cursor.fetchall()

        cursor.close()

    uses = {k: list(v) for k, v in groupby(uses, attrgetter("Exclusion_ID"))}

    output = []
    for establishment, exclusions in groupby(exclusions, attrgetter("Establishment")):
        if establishment:
            output.extend(
                [
                    Markup("<p>"),
                    _("Establishments primarily engaged in:", request),
                    Markup("</p>"),
                ]
            )

        output.append(Markup("<ul>"))
        for exclusion in exclusions:
            use_instead = "; ".join(
                link_code(request, x.Code, x.Code, link_page)
                + " "
                + escape(x.Classification)
                for x in (uses.get(exclusion.Exclusion_ID) or [])
            )
            if use_instead:
                use_instead = use_instead.join([" (", ")"])

            output.extend(
                [
                    Markup("<li>"),
                    escape(exclusion.Description),
                    use_instead,
                    Markup("</li>"),
                ]
            )

        output.append(Markup("</ul>"))

    return Markup("".join(output))


def get_examples(request, naics_code, all_langs=False):
    with request.connmgr.get_connection() as conn:
        examples = conn.execute(
            "EXEC dbo.sp_NAICS_Example_l ?,?", str(naics_code), all_langs
        ).fetchall()

    li_tmpl = Markup("<li>%s</li>")
    retval = "".join(li_tmpl % x.Description for x in examples)
    if retval:
        return Markup("<ul>" + retval + "</ul>")

    return retval
