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
<%!
from markupsafe import escape_silent as h, Markup
%>
<%namespace file="cioc.web.admin:templates/shown_cultures.mak" name="sc" />
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_socialmedia_index')}">${_('Return to Social Media Types')}</a> ]</p>
<p class="HideJs Alert">
	${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">
	<form method="post" action="${request.route_path('admin_socialmedia', action='edit')}" id="EntryForm" class="form">
		<div class="NotVisible">
			${request.passvars.cached_form_vals|n}
			%if not is_add:
			<input type="hidden" name="SM_ID" value="${SM_ID}">
			%endif
		</div>

		${sc.shown_cultures_ui()}

		<div class="panel panel-default max-width-lg">
			<div class="panel-heading">
				<a name="basic"></a>
				<h2>${_('Edit Social Media Type') if not is_add else _('Add Social Media Type')}</h2>
			</div>
			<div class="panel-body no-padding">
				<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
					%if not is_add and context.get('socialmedia') is not None:
					<tr>
						${self.fieldLabelCell(None,_('Status'),None,False)}
						<td>
							%if socialmedia.UsageCount:
							${_('This Social Media Type is <strong>being used</strong> by %d record(s).') % socialmedia.UsageCount |n} [ <a href="${request.passvars.makeLink('/results.asp',dict(Limit='EXISTS(SELECT * FROM GBL_BT_SM WHERE SM_ID=%d AND NUM=bt.NUM)' % socialmedia.SM_ID))}">${_('Search')}</a> ]
							<br>${_('Because this Social Media Type is being used, you cannot currently delete it.')}
							%else:
							${_('This Social Media Type is <strong>not</strong> being used by any records.')|n}
							<br>${_('Because this Social Media Type is not being used, you can delete it using the button at the bottom of the form.')}
							%endif
						</td>
					</tr>
					${self.makeMgmtInfo(socialmedia)}
					%endif
					<tr>
						${self.fieldLabelCell("socialmedia.DefaultName",_('Default Name'),None,True)}
						<td>
							${renderer.errorlist('socialmedia.DefaultName')}
							${renderer.text('socialmedia.DefaultName', maxlength=100, class_="form-control")}
							<div class="clear-line-above">${_('Default name for this Social Media type. May be overriden with a language-specific value.')}</div>
						</td>
					</tr>
					<tr>
						${self.fieldLabelCell(None,_('Name'),None,False)}
						<td>
							<div class="SmallNote clear-line-below">${_('Optional language-specific name of this Social Media Type.')}</div>
							%for culture in record_cultures:
							<% lang = culture_map[culture] %>
							<div ${sc.shown_cultures_attrs(culture)}>
								<div class="form-group row">
									${renderer.label("descriptions." +lang.FormCulture + ".Name", lang.LanguageName, class_='control-label col-xs-3')}
									<div class="col-xs-9">
										${renderer.errorlist("descriptions." +lang.FormCulture + ".Name")}
										${renderer.text("descriptions." +lang.FormCulture + ".Name", maxlength=100, class_=('form-control'))}
									</div>
								</div>
							</div>
							%endfor
						</td>
					</tr>
					<tr>
						<td class="FieldLabelLeft NoWrap"><label for="socialmedia.GeneralURL">${_('Info URL')}</label></td>
						<td>
							${renderer.errorlist('socialmedia.GeneralURL')}
							<div class="form-inline form-inline-always">
								<div class="input-group">
									<span class="input-group-addon">https://</span>
									${renderer.text('socialmedia.GeneralURL', maxlength=255, class_="form-control")}
								</div>
							</div>
							<div class="clear-line-above">${_('Main URL of the Social Media site (if applicable).')}</div>
						</td>
					</tr>
					<tr>
						${self.fieldLabelCell("socialmedia.IconURL16",_('16px Icon URL'),None,True)}
						<td>
							${renderer.errorlist('socialmedia.IconURL16')}
							<div class="form-inline form-inline-always">
								<div class="input-group">
									%if not is_add:
									<span class="input-group-addon"><img src="${socialmedia.IconURL16}" width="16" height="16"></span>
									%endif
									${renderer.proto_url('socialmedia.IconURL16', maxlength=255, class_="form-control")}
								</div>
							</div>
							<div class="clear-line-above">${_('URL of social media icon file. Icon must be 16px by 16px.')}</div>
						</td>
					</tr>
					<tr>
						${self.fieldLabelCell("socialmedia.IconURL24",_('24px Icon URL'),None,True)}
						<td>
							${renderer.errorlist('socialmedia.IconURL24')}
							<div class="form-inline form-inline-always">
								<div class="input-group">
									%if not is_add:
									<span class="input-group-addon"><img src="${socialmedia.IconURL24}" width="18" height="18"></span>
									%endif
									${renderer.proto_url('socialmedia.IconURL24', maxlength=255, class_="form-control")}
								</div>
							</div>
							<div class="clear-line-above">${_('URL of social media icon file. Icon must be 24px by 24px.')}</div>
						</td>
					</tr>
					<tr>
						<td class="FieldLabelLeft NoWrap">${_('Active')}</td>
						<td>
							${renderer.errorlist('socialmedia.Active')}
							${renderer.checkbox('socialmedia.Active', label=_('Make this Social Media type available on data entry forms.'))}
						</td>
					</tr>
				</table>
			</div>
		</div>
		<div class="clear-line-below">
			<input type="submit" name="Submit" value="${_('Submit Updates')}" class="btn btn-default">
			%if not is_add and context.get('socialmedia') is not None and not socialmedia.UsageCount:
			<input type="submit" name="Delete" value="${_('Delete')}" class="btn btn-default">
			%endif
			<input type="reset" value="${_('Reset Form')}" class="btn btn-default">
		</div>
	</form>
</div>


<%def name="bottomjs()">
${sc.shown_cultures_js()}
</%def>

