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
from __future__ import absolute_import
import json
import os

# 3rd party
import markupsafe

# this app
import cioc.core.constants as const

_version_file = os.path.join(os.path.dirname(__file__), 'assetversions.json')
_last_load = None
_assetversions = None


def _get_asset_versions():
	global _last_load, _assetversions
	mtime = os.stat(_version_file).st_mtime
	if not _last_load or _last_load < mtime:
		_last_load = mtime
		_assetversions = json.load(open(_version_file, 'r'))

	return _assetversions


class AssetManager(object):
	def __init__(self, request):
		self.request = request
		self.assetversions = _get_asset_versions()
		self.scripts_included = set()

	def makeAssetVer(self, script_name):
		if self.request.params.get('Debug') or script_name not in self.assetversions:
			return script_name

		parts = script_name.split('.')

		additions = [parts[-2]]
		if script_name.endswith('.js'):
			additions.append('.min')

		if self.request.passvars.record_root:
			additions.append('_v')
			additions.append(self.assetversions[script_name])

		parts[-2] = ''.join(additions)

		return '.'.join(parts)

	def JSVerScriptTagSingleton(self, script_name):
		if script_name not in self.scripts_included:
			self.scripts_included.add(script_name)
			return self.JSVerScriptTag(script_name)

		return ''

	def JSVerScriptTag(self, script_name):
		return markupsafe.Markup('<script type="text/javascript" src="%s%s"></script>') % (markupsafe.escape(self.request.pageinfo.PathToStart), markupsafe.escape(self.makeAssetVer(script_name)))

	def makeSingletonScriptTag(self, script_name):
		if script_name.startswith('http://ajax.googleapis.com/'):
			# fix it to be protocl independent (i.e. will get http or https as needed
			script_name = script_name[5:]

		if script_name not in self.scripts_included:
			self.scripts_included.add(script_name)
			return markupsafe.Markup('<script type="text/javascript" src="%s"></script>') % markupsafe.escape(script_name)

		return ''

	def makeJQueryScriptTags(self):
		if 'jquery' in self.scripts_included:
			return ''

		self.scripts_included.add('jquery')
		if hasattr(self.request, 'template_values') and self.request.template_values['UseFullCIOCBootstrap']:
			bootstrap = markupsafe.Markup(u'''
				<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js" integrity="sha256-Sk3nkD6mLTMOF0EOpNtsIry+s1CsaqQC1rVLTAy+0yc= sha512-K1qjQ+NcF2TYO/eI3M6v8EiNYZfA95pQumfvcVrTHtwQVDG+aHRqLi/ETn2uB+1JqwYqVG3LIvdm9lj6imS/pQ==" crossorigin="anonymous"></script>
				<script src="https://cdn.jsdelivr.net/bootstrap.jasny/3.13/js/jasny-bootstrap.min.js"></script>
			''')
		else:
			bootstrap = ''

		html = markupsafe.Markup(
			u'''
				<script src="//ajax.googleapis.com/ajax/libs/jquery/%(jquery_version)s/jquery.min.js"></script>
				<script src="//code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
				<script src="//ajax.googleapis.com/ajax/libs/jqueryui/%(jquery_ui_version)s/jquery-ui.min.js"></script>
				<script type="text/javascript">$.widget.bridge("uibutton", jQuery.ui.button);$.widget.bridge("uitooltip", jQuery.ui.tooltip);</script>
				%(bootstrap)s
			'''
		) % {
			'root': self.request.pageinfo.PathToStart,
			'jquery_version': const.JQUERY_VERSION,
			'jquery_ui_version': const.JQUERY_UI_VERSION,
			'bootstrap': bootstrap
		}
		return html
