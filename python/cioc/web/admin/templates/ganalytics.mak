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

	<table class="BasicBorder cell-padding-3">
	<tr>
		<th class="RevTitleBox">${_("Domain Name")}</th>
		<th class="RevTitleBox">${_("Code")}</th>
		<th class="RevTitleBox">${_('Google Universal Analytics Code:')}</th>
		<th class="RevTitleBox">${_('Agency Dimension')}</th>
		<th class="RevTitleBox">${_('Language Dimension')}</th>
		<th class="RevTitleBox">${_('View Dimension')}</th>
		<th class="RevTitleBox">${_('Result Count Dimension')}</th>
	</tr>
	<% languages = [(x, culture_map[x].LanguageName) for x in active_cultures] %>
	%for i,domain in enumerate(model_state.value('domain')):
		<% prefix = 'domain-%d.' %i %>
		<% domain_name = domain_names.get(str(model_state.value(prefix + 'DMAP_ID'))) %>
		%for field_prefix, number in [('', '1'), ('Second', '2')]:
	<tr>
		<td>
		${domain_name}
		%if not field_prefix:
		${renderer.errorlist(prefix + 'DMAP_ID')}
		${renderer.hidden(prefix + 'DMAP_ID')}
		%endif
		</td>
		<td>
		${number}
		</td>
		<td>
			${renderer.errorlist(prefix + field_prefix + 'GoogleAnalyticsCode')}
			${renderer.text(prefix + field_prefix + 'GoogleAnalyticsCode', maxlength=50, size=15, title=domain_name + _(': Google Universal Analytics Code'))}
		</td>
		<td>
			${renderer.errorlist(prefix + field_prefix + 'GoogleAnalyticsAgencyDimension')}
			${renderer.text(prefix + field_prefix + 'GoogleAnalyticsAgencyDimension', maxlength=2, size=2, title=domain_name + _(': Google Universal Analytics Agency Dimension'))}
		</td>
		<td>
			${renderer.errorlist(prefix + field_prefix + 'GoogleAnalyticsLanguageDimension')}
			${renderer.text(prefix + field_prefix + 'GoogleAnalyticsLanguageDimension', maxlength=2, size=2, title=domain_name + _(': Google Universal Analytics Language Dimension'))}
		</td>
		<td>
			${renderer.errorlist(prefix + field_prefix + 'GoogleAnalyticsDomainDimension')}
			${renderer.text(prefix + field_prefix + 'GoogleAnalyticsDomainDimension', maxlength=2, size=2, title=domain_name + _(': Google Universal Analytics View Dimension'))}
		</td>
		<td>
			${renderer.errorlist(prefix + field_prefix + 'GoogleAnalyticsResultsCountMetric')}
			${renderer.text(prefix + field_prefix + 'GoogleAnalyticsResultsCountMetric', maxlength=2, size=2, title=domain_name + _(': Google Universal Analytics Results Count Metric'))}
		</td>
	</tr>
	%endfor
	%endfor
	<tr>
	<td colspan="6">
		<input type="submit" value="${_('Submit')}">
		<input type="reset" value="${_('Reset')}">
	</td>
	</tr>
	</table>
</form>
