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

from cioc.core.i18n import gettext
from markupsafe import Markup
# from cioc.core.i18n import gettext as _

_info_icon_template = Markup(u'''<span class="ui-button-icon-primary ui-icon ui-icon-info" aria-hidden="true"></span>''')


def render_ui(request):
	if request.viewdata.dom.GoogleTranslateWidget:
		request.added_gtranslate = True
		if request.viewdata.dom.GoogleTranslateDisclaimer:
			about_gtranslate = gettext('About Google Translations', request)
			disclaimer = Markup('''<div id="google-translate-dialog" data-title="%s" data-modal="true" style="display: none;">%s</div>''' % (
				about_gtranslate, request.viewdata.dom.GoogleTranslateDisclaimer))
			disclaimer = Markup('''<button class="ui-corner-all ui-widget ui-state-default ui-button ui-button-text-icon-primary" data-toggle="dialog" data-target="#google-translate-dialog" role="button">%s <span class="ui-button-text">%s</span></button>%s''') % (
				_info_icon_template,
				about_gtranslate,
				disclaimer
			)
		else:
			disclaimer = ''
		return Markup('<div id="google-translate-element-parent" class="clearfix mb5" style="display:none;"><div class="browse-by-list"><div id="google-translate-element" class="mb5"></div>%s</div></div>') % disclaimer
	return ''


def render_script(request):
	if request.added_gtranslate:
		return Markup('''<script type="text/javascript" src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>''')
	return ''
