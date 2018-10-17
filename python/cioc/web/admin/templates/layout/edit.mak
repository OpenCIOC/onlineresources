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
<%! from operator import itemgetter %>
<%
is_add = action == 'add'
%>
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp' if request.user.SuperUser else 'setup_webdev.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_template_layout_index')}">${_('Template Layout')}</a> ]</p>
<form method="post" action="${request.route_path('admin_template_layout', action=action)}" class="form-horizontal">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
%if not is_add:
<input type="hidden" name="LayoutID" value="${LayoutID}">
%endif	
</div>
<div class="panel panel-default max-width-lg">
	<div class="panel-heading">
		<h2>${_('Add Template Layout') if action=='add' else _('Edit Template Layout')}</h2>
	</div>
	<div class="panel-body no-padding">
		<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
			%if not is_add and context.get('layout') is not None:
			<tr>
				<td class="field-label-cell">${_('Status')}</td>
				<td class="field-data-cell">
					%if templates:
					${_('This layout is <strong>being used</strong> by the following templates:')|n} ${', '.join(templates) |n}
					%if not layout.SystemLayout:
					<br>${_('Because this layout is being used, you cannot currently delete it.')}
					%endif
					%else:
					${_('This layout is <strong>not</strong> being used by any templates.')|n}
					%if not layout.SystemLayout:
					<br>${_('Because this layout is not being used, you can delete it using the button at the bottom of the form.')}
					%endif
					%endif
					%if layout.SystemLayout:
					<br>${_("This layout is provided with the software. You can view and copy it, but you can't edit or delete it.")}
					%endif
				</td>
			</tr>
			%endif
			%if not is_add and context.get('layout') is not None:
			${self.makeMgmtInfo(layout)}
			%endif
			%if not layout or not layout.SystemLayout:
			<tr>
				<td class="field-label-cell">${_('Record Owner')}</td>
				<td class="field-data-cell">
					${renderer.errorlist("layout.Owner")}
					${renderer.checkbox("layout.Owner", request.user.Agency, label= " " + _('Setup of this item is exclusively controlled by the Agency: ') + (request.user.Agency if is_add or not layout.ReadOnlyLayoutOwner else layout.ReadOnlyLayoutOwner))}
				</td>
			</tr>
			%endif
			<tr>
				<td class="field-label-cell">${_('HTML Standards Mode')}</td>
				<td class="field-data-cell">
					%if not is_add and layout.SystemLayout:
					${_('This layout requires backwards compatible mode.') if layout.AlmostStandardsMode else _('This layout can run in HTML 5 mode.')}
					%else:
					${renderer.errorlist("layout.AlmostStandardsMode")}
					${renderer.radio("layout.AlmostStandardsMode", 'False', label=_('This layout can run in HTML 5 mode.'))}
					<br>${renderer.radio("layout.AlmostStandardsMode", 'True', label=_('This layout requires backwards compatible mode.'))}
					%endif
				</td>
			</tr>
			<tr>
				<td class="field-label-cell">${_('Icon Library')}</td>
				<td class="field-data-cell">
					${renderer.errorlist("layout.UseFontAwesome")}
					${renderer.checkbox("layout.UseFontAwesome", label=_('Include Font Awesome CSS (Bootstrap CDN)'))}
				</td>
			</tr>
			<tr>
				<td class="field-label-cell">${_('Bootstrap Library')}</td>
				<td class="field-data-cell">
					${renderer.errorlist("layout.UseFullCIOCBootstrap")}
					${renderer.checkbox("layout.UseFullCIOCBootstrap", label=_('Include the full CIOC-adapted Bootstrap design libary'))}
				</td>
			</tr>
			<tr>
				<td class="field-label-cell">${_('Full SSL Compatible')}</td>
				<td class="field-data-cell">
					%if not is_add and layout.SystemLayout:
					${_('This layout can run in full SSL mode.') if layout.FullSSLCompatible else _('This layout cannot be used in full SSL mode.') }
					%else:
					${renderer.errorlist("layout.FullSSLCompatible")}
					${renderer.checkbox("layout.FullSSLCompatible", label=_('This layout can run in full SSL mode.'))}
					%endif
				</td>
			</tr>
			<tr>
				<td class="field-label-cell">${_('Layout Name')}</td>
				<td class="field-data-cell">
					%for culture in active_cultures:
					<%
					lang = culture_map[culture]
					field = "descriptions." +lang.FormCulture + ".LayoutName"
					label = lang.LanguageName
					%>
					<div class="form-group row">
						${renderer.label(field,label,class_='control-label col-sm-3 col-md-2')}
						<div class="col-sm-9 col-md-10">
							${renderer.errorlist(field)}
							${renderer.text(field, maxlength=50, class_='form-control')}
						</div>
					</div>
					%endfor
				</td>
			</tr>
			## XXX this should be based on if it is used, not just add
			%if is_add:
			<%
			layout_types = [ ('header', _('Header')), ('footer', _('Footer')), ('cicsearch', _('CIC Basic Search')), ('volsearch', _('Volunteer Basic Search'))]
			layout_types.sort(key=itemgetter(1))
			%>
			<tr>
				<td class="field-label-cell">${renderer.label("layout.LayoutType", _('Layout Type'))}</td>
				<td class="field-data-cell">
					${renderer.errorlist("layout.LayoutType")}
					${renderer.select('layout.LayoutType', layout_types)}
				</td>
			</tr>
			%endif
			%for culture in active_cultures:
			<% lang = culture_map[culture] %>
			%if not layout or not layout.SystemLayout:
			<tr>
				<td class="field-label-cell">${renderer.label("descriptions." +lang.FormCulture + ".LayoutHTMLURL", _('HTML URL') + " (" + lang.LanguageName + ")")}</td>
				<td class="field-data-cell">
					${renderer.errorlist("descriptions." +lang.FormCulture + ".LayoutHTMLURL")}
					http://${renderer.text("descriptions." +lang.FormCulture + ".LayoutHTMLURL")} <button class="fetch-url">${_('Fetch')}</button>
				</td>
			</tr>
			%endif
			<tr>
				<td class="field-label-cell">${renderer.label("descriptions." + lang.FormCulture + ".LayoutHTML", _('HTML') + " (" + lang.LanguageName + ")")}</td>
				<td class="field-data-cell">
					${renderer.errorlist("descriptions." +lang.FormCulture + ".LayoutHTML")}
					${renderer.textarea("descriptions." + lang.FormCulture + ".LayoutHTML", class_='form-control')}
				</td>
			</tr>
			%endfor
			%if not layout or not layout.SystemLayout:
			<tr>
				<td class="field-label-cell">${renderer.label("layout.LayoutCSSURL", _('CSS URL'))}</td>
				<td class="field-data-cell">
					${renderer.errorlist('layout.LayoutCSSURL')}
					http://${renderer.text('layout.LayoutCSSURL')} <button class="fetch-url">${_('Fetch')}</button>
				</td>
			</tr>
			%endif
			<tr>
				<td class="field-label-cell">${renderer.label("layout.LayoutCSS", _('CSS'))}</td>
				<td class="field-data-cell">
					${renderer.errorlist('layout.LayoutCSS')}
					${renderer.textarea('layout.LayoutCSS', class_='form-control')}
				</td>
			</tr>

			%if not layout or not layout.SystemLayout:
			<tr>
				<td colspan="2" class="field-data-cell">
					%if not is_add and layout.ReadOnlyLayoutOwner:
					<span class="Alert">${_('Setup of this item is exclusively controlled by the Agency: ') + layout.ReadOnlyLayoutOwner}</span>
					%else:
					<input type="submit" name="Submit" value="${_('Add') if action=='add' else _('Update')}" class="btn btn-default">
					%if not is_add and not templates:
					<input type="submit" name="Delete" value="${_('Delete')}" class="btn btn-default">
					%endif
					%endif
					<input type="reset" value="${_('Reset Form')}" class="btn btn-default">
				</td>
			</tr>
			%endif
			</table>
		</div>
		</div>

</form>

<%def name="bottomjs()">
%if not layout or not layout.SystemLayout:
<script type="text/javascript">
jQuery(function($){
	$('.fetch-url').live('click',function(evt) {
		var self = $(this),
			src = self.siblings('input'),
			row = self.parent().parent(),
			target = row.next().find('textarea'),
			fieldlabel = row.find('th');

		if (src[0].value) {
			var failfn = function(xhr, textStatus, errorThrown, what) {
				console.log(textStatus, what)
			};
			$.ajax(	{
					url: '${request.passvars.makeLink("fetch")|n}',
					data: {url: src[0].value},
					dataType: 'json',
					error: failfn,
					success: function(data, textStatus, xhr) {
						if (data.fail) {
							failfn(xhr, textStatus, null, data.message);
							return
						}

						target[0].value = data.data;
					}
			});

		}
		return false;
	});
});
</script>
%endif
</%def>
