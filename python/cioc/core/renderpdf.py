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

import pdfkit


def render_to_pdf(request, html, footer_file):
    wkhtmltopdfpath = request.config.get(
        "wkhtmltopdfpath", r"c:\Program Files (x86)\wkhtmltopdf\bin\wkhtmltopdf.exe"
    )
    config = pdfkit.configuration(wkhtmltopdf=wkhtmltopdfpath)
    if isinstance(html, bytes):
        html = html.decode("utf-8")
    return pdfkit.from_string(
        html,
        False,
        configuration=config,
        options={
            "footer-html": footer_file,
            "margin-bottom": request.viewdata.dom.PDFBottomMargin,
            "page-size": "letter",
            "disable-javascript": None,
            "print-media-type": None,
            "quiet": None,
            "load-error-handling": "ignore",
            "load-media-error-handling": "ignore",
        },
    )
