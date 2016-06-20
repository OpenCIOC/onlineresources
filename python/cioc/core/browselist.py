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

# std library
import string
from cgi import escape

# 3rd party

# this app
import cioc.core.i18n as i18n

_ = i18n.gettext


def makeAlphaListItems(include_nums, link_url, request):
	letters = string.uppercase
	if include_nums:
		letters = ['0-9'] + list(letters)

	makeLink = request.passvars.makeLink
	letters = ((escape(makeLink(link_url, {'Let': l}), True), l) for l in letters)

	return ({'LINK': l, 'DISPLAY': d} for l, d in letters)


def makeAlphaList(include_nums, link_url, href_class, request):
	templ = '<a class="%s" href="%%(LINK)s">%%(DISPLAY)s</a>' % href_class
	letters = (templ % l for l in makeAlphaListItems(include_nums, link_url, request))
	return '''<div class="browse-by-list">%s<br>%s</div>''' % (_('Select Letter', request), '&nbsp;&nbsp;'.join(letters))
