<%doc>
=========================================================================================
 Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
=========================================================================================
</%doc>


<%inherit file="cioc.web:templates/master.mak" />

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> ]</p>

<form action="${request.current_route_path()}" method="post">
<div class="hidden">
${request.passvars.getHTTPVals(bForm=True)}
</div>

	<p class="SmallNote">${_('<strong>"-- Database Default View --"</strong> represents whichever view is configured as the default view on the general setup page.')|n}</p>
	<p class="SmallNote">${_('<strong>*</strong> represents a non-public View. Only select a non-public View if you are planning to make it public in the future (e.g. for future site launch).')|n}</p>
	<table class="BasicBorder cell-padding-3">
	<tr>
		<th class="RevTitleBox">${_("Domain Name")}</th>
		<th class="RevTitleBox">${_("Default<br>Language")|n}</th>
		<th class="RevTitleBox">${_("View")}</th>
		<th class="RevTitleBox">${_("Secondary<br>Name")|n}</th>
		%if request.user.cic.SuperUser:
		<th class="RevTitleBox">${_("Google Maps (Community Information)")}</th>
		%endif
		%if request.user.vol.SuperUser:
		<th class="RevTitleBox">${_("Google Maps (Volunteer)")}</th>
		%endif
		<th class="RevTitleBox">${_('SSL Compatible')}</th>
	</tr>
	<% languages = [(x, culture_map[x].LanguageName) for x in active_cultures] %>
	%for i,domain in enumerate(model_state.value('domain')):
	<tr>
		<% prefix = 'domain-%d.' %i %>
		<% domain_name = domain_names.get(str(model_state.value(prefix + 'DMAP_ID'))) %>
		<td>
		${domain_name}
		${renderer.errorlist(prefix + 'DMAP_ID')}
		${renderer.hidden(prefix + 'DMAP_ID')}
		</td>
		<td>
		${renderer.errorlist(prefix + 'DefaultCulture')}
		${renderer.select(prefix + 'DefaultCulture', languages, title=domain_name + _(': Default Language'))}
		</td>
		<td>
			<table class="NoBorder cell-padding-2">
			%if request.user.cic.SuperUser:
			<tr>
				<td class="FieldLabelLeftClr">${_('Community Information:')}</td>
			</tr>
			<tr>
				<td>
				${renderer.errorlist(prefix + 'CICViewType')}
				${renderer.select(prefix + 'CICViewType', [('',_('-- Database Default View --'))]+list(map(tuple,cic_views)), title=domain_name + _(': Community Information View'))}
				</td>
			</tr>
			%endif
			%if request.user.vol.SuperUser:
			<tr>
				<td class="FieldLabelLeftClr">${_('Volunteer:')}</td>
			</tr>
			<tr>
				<td>
				${renderer.errorlist(prefix + 'VOLViewType')}
				${renderer.select(prefix + 'VOLViewType', [('',_('-- Database Default View --'))]+list(map(tuple,vol_views)), title=domain_name + _(': Volunteer View'))}
				</td>
			</tr>
			%endif
			</table>
		</td>
		<td style="text-align: center;">
		${renderer.errorlist(prefix + 'SecondaryName')}
		${renderer.checkbox(prefix + 'SecondaryName', title=domain_name + _(' is a secondary name'))}
		</td>
		%if request.user.cic.SuperUser:
		<td>
			<table class="NoBorder cell-padding-2">
			<tr>
				<td class="FieldLabelLeftClr"><label for="${prefix + 'GoogleMapsAPIKeyCIC'}">${_('API Key:')}</label></td>
			</tr>
			<tr>
				<td>
				${renderer.errorlist(prefix + 'GoogleMapsAPIKeyCIC')}
				${renderer.text(prefix + 'GoogleMapsAPIKeyCIC', maxlength=100, size=43)}
				</td>
			</tr>
			<tr>
				<td class="FieldLabelLeftClr"><label for="${prefix + 'GoogleMapsClientIDCIC'}">${_('Enterprise Client ID:')}</label></td>
			</tr>
			<tr>
				<td>
				${renderer.errorlist(prefix + 'GoogleMapsClientIDCIC')}
				${renderer.text(prefix + 'GoogleMapsClientIDCIC', maxlength=100, size=43)}
				</td>
			</tr>
			<tr>
				<td class="FieldLabelLeftClr"><label for="${prefix + 'GoogleMapsChannelCIC'}">${_('Exterprise Channel:')}</label></td>
			</tr>
			<tr>
				<td>
				${renderer.errorlist(prefix + 'GoogleMapsChannelCIC')}
				${renderer.text(prefix + 'GoogleMapsChannelCIC', maxlength=100, size=43)}
				</td>
			</tr>
			</table>
		</td>
		%endif
		%if request.user.vol.SuperUser:
		<td>
			<table class="NoBorder cell-padding-2">
			<tr>
				<td class="FieldLabelLeftClr"><label for="${prefix + 'GoogleMapsAPIKeyVOL'}">${_('API Key:')}</label></td>
			</tr>
			<tr>
				<td>
				${renderer.errorlist(prefix + 'GoogleMapsAPIKeyVOL')}
				${renderer.text(prefix + 'GoogleMapsAPIKeyVOL', maxlength=100, size=43)}
				</td>
			</tr>
			<tr>
				<td class="FieldLabelLeftClr"><label for="${prefix + 'GoogleMapsClientIDVOL'}">${_('Enterprise Client ID:')}</label></td>
			</tr>
			<tr>
				<td>
				${renderer.errorlist(prefix + 'GoogleMapsClientIDVOL')}
				${renderer.text(prefix + 'GoogleMapsClientIDVOL', maxlength=100, size=43)}
				</td>
			</tr>
			<tr>
				<td class="FieldLabelLeftClr"><label for="${prefix + 'GoogleMapsChannelVOL'}">${_('Exterprise Channel:')}</label></td>
			</tr>
			<tr>
				<td>
				${renderer.errorlist(prefix + 'GoogleMapsChannelVOL')}
				${renderer.text(prefix + 'GoogleMapsChannelVOL', maxlength=100, size=43)}
				</td>
			</tr>
			</table>
		</td>
		%endif
		<td style="text-align: center;">
		${renderer.errorlist(prefix + 'FullSSLCompatible')}
		${renderer.checkbox(prefix + 'FullSSLCompatible', title=domain_name + _(': SSL compatible'))}
		</td>
	</tr>
	%endfor
	<tr>
	<td colspan="6">
		<input type="submit" value="${_('Submit')}">
		<input type="reset" value="${_('Reset')}">
	</td>
	</tr>
	</table>
</form>
