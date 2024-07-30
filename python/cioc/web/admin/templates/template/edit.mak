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


<%
use_cic = request.user.cic.SuperUser
use_vol = request.user.vol.SuperUser and request.dboptions.UseVOL
only_vol = request.dboptions.UseVOL and not request.dboptions.UseCIC
%>
<%inherit file="cioc.web:templates/master.mak" />
<%namespace file="cioc.web.admin:templates/template/colour_set_tmpl.mak" import="colour_set"/>
<%
is_add = action == 'add'
%>
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp' if request.user.SuperUser else 'setup_webdev.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_template_index')}">${_('Templates')}</a> ]</p>
<p class="HideJs Alert">
${_('Javascript is required to use this page.')}
</p>
<div class="HideNoJs">
<form method="post" action="${request.route_path('admin_template', action=action)}" class="form-horizontal">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
%if action == 'edit':
<input type="hidden" name="TemplateID" value="${TemplateID}">
%endif
</div>

<table class="BasicBorder cell-padding-4 form-table responsive-table max-width-lg clear-line-below">
<tr>
	<th class="RevTitleBox" colspan="2">${_('Add Template') if action=='add' else _('Edit Template')}</th>
</tr>
%if action == 'edit' and context.get('template') is not None:
<tr>
	<% can_delete = True %>
	<td class="field-label-cell">${_('Status')}</td>
	<td class="field-data-cell">
	%if views:
		${_('This template is <strong>being used</strong> by the following views:')|n} ${", ".join(views) |n}
		<% can_delete = False %>
	%else:
		${_('This template is <strong>not</strong> being used by any views.')|n}
	%endif
	%if template.IsDefaultTemplate:
		<br>${_('This template is <strong>being used</strong> as the Admin Design Template.')|n}
		<% can_delete = False %>
	%else:
		<br>${_('This template is <strong>not</strong> being used as the Admin Design Template.')|n}
	%endif
	%if template.IsDefaultPrintTemplate:
		<br>${_('This template is <strong>being used</strong> as the Admin Print Template.')|n}
		<% can_delete = False %>
	%else:
		<br>${_('This template is <strong>not</strong> being used as the Admin Print Template.')|n}
	%endif
	%if template.SystemTemplate:
		<% can_delete = False %>
		<br>${_("This template is provided with the software. You can view and copy it, but you can't edit or delete it.")}
	%else:
		%if can_delete:
		<br>${_('Because this template is not being used, you can delete it using the button at the bottom of the form.')}
		%else:
		<br>${_('Because this template is being used, you cannot currently delete it.')}
		%endif
	%endif
	
	</td>
</tr>
%endif
%if action == 'edit' and context.get('template') is not None:
${self.makeMgmtInfo(template)}
%endif
%if not template or not template.SystemTemplate:
<tr>
	<td class="field-label-cell">${_('Preview Template')}</td>
	<td class="field-data-cell">${renderer.errorlist("template.PreviewTemplate")}
	${renderer.checkbox("template.PreviewTemplate", label= " " + _('Allow Template Preview Mode'))}</td>
</tr>
%endif
%if not template or not template.SystemTemplate:
<tr>
	<td class="field-label-cell">${_('Record Owner')}</td>
	<td class="field-data-cell">${renderer.errorlist("template.Owner")}
	${renderer.checkbox("template.Owner", request.user.Agency, label= " " + _('Setup of this item is exclusively controlled by the Agency: ') + (request.user.Agency if is_add or not template.ReadOnlyTemplateOwner else template.ReadOnlyTemplateOwner))}</td>
</tr>
%endif
%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="field-label-cell">${renderer.label("descriptions." + lang.FormCulture + ".Name", _('Template Name') + " (" + lang.LanguageName + ")")}</td>
	<td class="field-data-cell">${renderer.errorlist("descriptions." + lang.FormCulture + ".Name")}
	${renderer.text("descriptions." + lang.FormCulture + ".Name", maxlength=50, class_="form-control")}</td>

</tr>
%endfor
%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="field-label-cell">${renderer.label("descriptions." + lang.FormCulture + ".Logo", _('Logo') + " (" + lang.LanguageName + ")")}</td>
	<td class="field-data-cell">${renderer.errorlist("descriptions." + lang.FormCulture + ".Logo")}
	${renderer.proto_url("descriptions." + lang.FormCulture + ".Logo", class_="form-control")}</td>

</tr>
%endfor
%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="field-label-cell">${renderer.label("descriptions." + lang.FormCulture + ".LogoAltText", _('Logo Alt Text') + " (" + lang.LanguageName + ")")}</td>
	<td class="field-data-cell">${renderer.errorlist("descriptions." + lang.FormCulture + ".LogoAltText")}
	${renderer.text("descriptions." + lang.FormCulture + ".LogoAltText", maxlength=255, class_="form-control")}</td>

</tr>
%endfor
%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="field-label-cell">${renderer.label("descriptions." + lang.FormCulture + ".LogoLink", _('Logo Link') + " (" + lang.LanguageName + ")")}</td>
	<td class="field-data-cell">${renderer.errorlist("descriptions." + lang.FormCulture + ".LogoLink")}
	${renderer.proto_url("descriptions." + lang.FormCulture + ".LogoLink", class_="form-control")}</td>

</tr>
%endfor
%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="field-label-cell">${renderer.label("descriptions." + lang.FormCulture + ".LogoMobile", _('Mobile Logo') + " (" + lang.LanguageName + ")")}</td>
	<td class="field-data-cell">${renderer.errorlist("descriptions." + lang.FormCulture + ".LogoMobile")}
	${renderer.proto_url("descriptions." + lang.FormCulture + ".LogoMobile", class_="form-control")}</td>

</tr>
%endfor
%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="field-label-cell">${renderer.label("descriptions." + lang.FormCulture + ".Banner", _('Banner Image') + " (" + lang.LanguageName + ")")}</td>
	<td class="field-data-cell">${renderer.errorlist("descriptions." + lang.FormCulture + ".Banner")}
	${renderer.proto_url("descriptions." + lang.FormCulture + ".Banner", class_="form-control")}</td>
</tr>
%endfor
<tr>
	<td class="field-label-cell">${_('Banner Display')}</td>
	<td class="field-data-cell">${renderer.errorlist("template.BannerRepeat")}
	${renderer.checkbox("template.BannerRepeat", label= _('Tile/Repeat Banner'))}
	<div class="form-inline form-inline-always">
		${renderer.errorlist("template.BannerHeight")}
		<div class="input-group">
			<span class="input-group-addon">${_('Banner Height')}</span>
			${renderer.text("template.BannerHeight", maxlength=3, class_="form-control")}
			<span class="input-group-addon">px</span>
		</div>
	</div>
	</td>
</tr>
%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="field-label-cell">${renderer.label("descriptions." + lang.FormCulture + ".CopyrightNotice", _('Copyright Notice') + " (" + lang.LanguageName + ")")}</td>
	<td class="field-data-cell">${renderer.errorlist("descriptions." + lang.FormCulture + ".CopyrightNotice")}
	${renderer.text("descriptions." + lang.FormCulture + ".CopyrightNotice", maxlength=255, class_="form-control")}</td>

</tr>
%endfor
%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="field-label-cell">${_('Contact Information') + " (" + lang.LanguageName + ")"}</td>
	<td class="field-data-cell">
		<div class="row form-group">
			${renderer.label("descriptions." + lang.FormCulture + ".Agency",_('Agency Name'), class_="control-label col-sm-3")}
			<div class="col-sm-9">
				${renderer.errorlist("descriptions." + lang.FormCulture + ".Agency")}
				${renderer.text("descriptions." + lang.FormCulture + ".Agency", maxlength=255, class_="form-control")}
			</div>
		</div>
		<div class="row form-group">
			${renderer.label("descriptions." + lang.FormCulture + ".Address",_('Address'), class_="control-label col-sm-3")}
			<div class="col-sm-9">
				${renderer.errorlist("descriptions." + lang.FormCulture + ".Address")}
				${renderer.text("descriptions." + lang.FormCulture + ".Address", maxlength=255, class_="form-control")}
			</div>
		</div>
		<div class="row form-group">
			${renderer.label("descriptions." + lang.FormCulture + ".Phone",_('Phone'), class_="control-label col-sm-3")}
			<div class="col-sm-9">
				${renderer.errorlist("descriptions." + lang.FormCulture + ".Phone")}
				${renderer.text("descriptions." + lang.FormCulture + ".Phone", maxlength=255, class_="form-control")}
			</div>
		</div>
		<div class="row form-group">
			${renderer.label("descriptions." + lang.FormCulture + ".Email",_('Email'), class_="control-label col-sm-3")}
			<div class="col-sm-9">
				${renderer.errorlist("descriptions." + lang.FormCulture + ".Email")}
				${renderer.text("descriptions." + lang.FormCulture + ".Email", maxlength=150, class_="form-control")}
			</div>
		</div>
		<div class="row form-group">
			${renderer.label("descriptions." + lang.FormCulture + ".Web",_('Web'), class_="control-label col-sm-3")}
			<div class="col-sm-9">
				${renderer.errorlist("descriptions." + lang.FormCulture + ".Web")}
				${renderer.text("descriptions." + lang.FormCulture + ".Web", maxlength=150, class_="form-control")}
			</div>
		</div>
		<div class="row form-group">
			${renderer.label("descriptions." + lang.FormCulture + ".Facebook",_('Facebook'), class_="control-label col-sm-3")}
			<div class="col-sm-9">
				${renderer.errorlist("descriptions." + lang.FormCulture + ".Facebook")}
				${renderer.text("descriptions." + lang.FormCulture + ".Facebook", maxlength=150, class_="form-control")}
			</div>
		</div>
		<div class="row form-group">
			${renderer.label("descriptions." + lang.FormCulture + ".Twitter",_('X (Twitter)'), class_="control-label col-sm-3")}
			<div class="col-sm-9">
				${renderer.errorlist("descriptions." + lang.FormCulture + ".Twitter")}
				${renderer.text("descriptions." + lang.FormCulture + ".Twitter", maxlength=150, class_="form-control")}
			</div>
		</div>
		<div class="row form-group">
			${renderer.label("descriptions." + lang.FormCulture + ".Instagram",_('Instagram'), class_="control-label col-sm-3")}
			<div class="col-sm-9">
				${renderer.errorlist("descriptions." + lang.FormCulture + ".Instagram")}
				${renderer.text("descriptions." + lang.FormCulture + ".Instagram", maxlength=150, class_="form-control")}
			</div>
		</div>
		<div class="row form-group">
			${renderer.label("descriptions." + lang.FormCulture + ".LinkedIn",_('LinkedIn'), class_="control-label col-sm-3")}
			<div class="col-sm-9">
				${renderer.errorlist("descriptions." + lang.FormCulture + ".LinkedIn")}
				${renderer.text("descriptions." + lang.FormCulture + ".LinkedIn", maxlength=150, class_="form-control")}
			</div>
		</div>
		<div class="row form-group">
			${renderer.label("descriptions." + lang.FormCulture + ".YouTube",_('YouTube'), class_="control-label col-sm-3")}
			<div class="col-sm-9">
				${renderer.errorlist("descriptions." + lang.FormCulture + ".YouTube")}
				${renderer.text("descriptions." + lang.FormCulture + ".YouTube", maxlength=150, class_="form-control")}
			</div>
		</div>
		<div class="row form-group">
			${renderer.label("descriptions." + lang.FormCulture + ".TermsOfUseLink",_('Terms of Use Link'), class_="control-label col-sm-3")}
			<div class="col-sm-9">
				${renderer.errorlist("descriptions." + lang.FormCulture + ".TermsOfUseLink")}
				${renderer.text("descriptions." + lang.FormCulture + ".TermsOfUseLink", maxlength=150, class_="form-control")}
			</div>
		</div>
		<div class="row form-group">
			${renderer.label("descriptions." + lang.FormCulture + ".TermsOfUseLabel",_('Terms of Use Label'), class_="control-label col-sm-3")}
			<div class="col-sm-9">
				${renderer.errorlist("descriptions." + lang.FormCulture + ".TermsOfUseLabel")}
				${renderer.text("descriptions." + lang.FormCulture + ".TermsOfUseLabel", maxlength=100, class_="form-control")}
			</div>
		</div>
		<div class="row form-group">
			${renderer.label("descriptions." + lang.FormCulture + ".FooterNoticeContact", _('Contact Footer Notice'), class_="control-label col-sm-3")}
			<div class="col-sm-9">
				${renderer.errorlist("descriptions." + lang.FormCulture + ".FooterNoticeContact")}
				${renderer.textarea("descriptions." + lang.FormCulture + ".FooterNoticeContact", class_="form-control")}
			</div>
		</div>
		</td>
</tr>
%endfor

%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="field-label-cell">${renderer.label("descriptions." + lang.FormCulture + ".HeaderNotice", _('Header Notice') + " (" + lang.LanguageName + ")")}</td>
	<td class="field-data-cell">${renderer.errorlist("descriptions." + lang.FormCulture + ".HeaderNotice")}
	${renderer.textarea("descriptions." + lang.FormCulture + ".HeaderNotice", class_="form-control")}</td>
</tr>
%endfor

%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="field-label-cell">${renderer.label("descriptions." + lang.FormCulture + ".HeaderNoticeMobile", _('Header Notice - Mobile') + " (" + lang.LanguageName + ")")}</td>
	<td class="field-data-cell">${renderer.errorlist("descriptions." + lang.FormCulture + ".HeaderNoticeMobileMobile")}
	${renderer.textarea("descriptions." + lang.FormCulture + ".HeaderNoticeMobile", class_="form-control")}</td>
</tr>
%endfor

%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="field-label-cell">${renderer.label("descriptions." + lang.FormCulture + ".FooterNotice", _('Footer Notice (1)') + " (" + lang.LanguageName + ")")}</td>
	<td class="field-data-cell">${renderer.errorlist("descriptions." + lang.FormCulture + ".FooterNotice")}
	${renderer.textarea("descriptions." + lang.FormCulture + ".FooterNotice", class_="form-control")}</td>
</tr>
%endfor

%for culture in active_cultures:
<% lang = culture_map[culture] %>
<tr>
	<td class="field-label-cell">${renderer.label("descriptions." + lang.FormCulture + ".FooterNotice2", _('Footer Notice (2)') + " (" + lang.LanguageName + ")")}</td>
	<td class="field-data-cell">${renderer.errorlist("descriptions." + lang.FormCulture + ".FooterNotice2")}
	${renderer.textarea("descriptions." + lang.FormCulture + ".FooterNotice2", class_="form-control")}</td>
</tr>
%endfor

<tr>
	<td class="field-label-cell">${renderer.label("template.ShortCutIcon", _('Shortcut Icon'))}</td>
	<td class="field-data-cell">${renderer.errorlist("template.ShortCutIcon")}
	${renderer.proto_url("template.ShortCutIcon", class_="form-control")}</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.AppleTouchIcon", _('Mobile App Icon'))}</td>
	<td class="field-data-cell">${renderer.errorlist("template.AppleTouchIcon")}
	${renderer.proto_url("template.AppleTouchIcon", class_="form-control")}</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.StyleSheetUrl", _('Style Sheet'))}</td>
	<td class="field-data-cell">${renderer.errorlist("template.StyleSheetUrl")}
	${renderer.proto_url("template.StyleSheetUrl", class_="form-control")}</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.ExtraCSS", _('Extra CSS'))}</td>
	<td class="field-data-cell">${renderer.errorlist("template.ExtraCSS")}
	${renderer.textarea("template.ExtraCSS", class_="form-control")}</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.JavaScriptTopUrl", _('Javascript Top'))}</td>
	<td class="field-data-cell">${renderer.errorlist("template.JavaScriptTopUrl")}
	${renderer.proto_url("template.JavaScriptTopUrl", class_="form-control")}</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.JavaScriptBottomUrl", _('Javascript Bottom'))}</td>
	<td class="field-data-cell">${renderer.errorlist("template.JavaScriptBottomUrl")}
	${renderer.proto_url("template.JavaScriptBottomUrl", class_="form-control")}</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.BodyTagExtras", _('Body Tag Extras'))}</td>
	<td class="field-data-cell">${renderer.errorlist("template.BodyTagExtras")}
	${renderer.text("template.BodyTagExtras", maxlength=150, class_="form-control")}</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.Background", _('Background Image URL'))}</td>
	<td class="field-data-cell">${renderer.errorlist("template.Background")}
	${renderer.proto_url("template.Background", class_="form-control")}</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.BackgroundColour", _('Background Colour'))}</td>
	<td class="field-data-cell">
	<div class="form-inline form-inline-always">
		${renderer.errorlist("template.BackgroundColour")}
		${renderer.colour("template.BackgroundColour", class_="form-control")}
	</div>
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.bgColorLogo", _('Logo Background Colour'))}</td>
	<td class="field-data-cell">
		<div class="form-inline form-inline-always">
			${renderer.errorlist("template.bgColorLogo")}
			${renderer.colour("template.bgColorLogo", class_="form-control")}
		</div>
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.FontFamily", _('Font Family'))}</td>
	<td class="field-data-cell">
		${renderer.errorlist("template.FontFamily")}
		${renderer.text("template.FontFamily", maxlength=100, class_="form-control")}
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.FontColour", _('Font Colour'))}</td>
	<td class="field-data-cell">
		<div class="form-inline form-inline-always">
			${renderer.errorlist("template.FontColour")}
			${renderer.colour("template.FontColour", class_="form-control")}
		</div>
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.AlertColour", _('Alert Colour'))}</td>
	<td class="field-data-cell">
		<div class="form-inline form-inline-always">
			${renderer.errorlist("template.AlertColour")}
			${renderer.colour("template.AlertColour", class_="form-control")}
		</div>
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.LinkColour", _('Link Colour'))}</td>
	<td class="field-data-cell">
		<div class="form-inline form-inline-always">
			${renderer.errorlist("template.LinkColour")}
			${renderer.colour("template.LinkColour", class_="form-control")}
		</div>
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.ALinkColour", _('Active Link Colour'))}</td>
	<td class="field-data-cell">
		<div class="form-inline form-inline-always">
			${renderer.errorlist("template.ALinkColour")}
			${renderer.colour("template.ALinkColour", class_="form-control")}
		</div>
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.VLinkColour", _('Visited Link Colour'))}</td>
	<td class="field-data-cell">
		<div class="form-inline form-inline-always">
			${renderer.errorlist("template.VLinkColour")}
			${renderer.colour("template.VLinkColour", class_="form-control")}
		</div>
	</td>
</tr>

<tr>
	<td class="field-label-cell">${_('Bootstrap Container')}</td>
	<td class="field-data-cell"><span class="SmallNote">${_('These options do not apply to all Layouts')}</span>
	<br>${renderer.errorlist("template.ContainerFluid")}
	${renderer.checkbox("template.ContainerFluid", label=_('Fluid (Wide) Container'))}
	<br>${renderer.errorlist("template.ContainerContrast")}
	${renderer.checkbox("template.ContainerContrast", label=_('Contrast the Container Colour with the Background'))}
	</td>
</tr>

<tr>
	<td class="field-label-cell">${_('View Title')}</td>
	<td class="field-data-cell"><span class="SmallNote">${_('These options do not apply to all Layouts')}</span>
	<br>${renderer.errorlist("template.SmallTitle")}
	${renderer.checkbox("template.SmallTitle", label=_('Small Title (Put the View Title in the Site Bar)'))}
	</td>
</tr>

<tr>
	<td class="field-label-cell">${renderer.label("template.HeaderLayout", _('Header Layout'))}</td>
	<td class="field-data-cell">${renderer.errorlist("template.HeaderLayout")}
	${renderer.select("template.HeaderLayout", [(x.LayoutID, x.LayoutName + (' *' if x.SystemLayout else '')) for x in layouts['header']], class_="form-control")}
	%if not template or not template.SystemTemplate:
	${menu_form('header')}
	<br>${renderer.checkbox("template.HeaderSearchLink", label= _('Include a search/menu link as a menu item'))}
	<br>${renderer.checkbox("template.HeaderSearchIcon", label= _('Include an icon in the search link'))}
	<br>${renderer.checkbox("template.HeaderSuggestLink", label= _('Include a suggest record link as a menu item'))}
	<br>${renderer.checkbox("template.HeaderSuggestIcon", label= _('Include an icon in the suggest record link'))}
	%endif
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.FooterLayout", _('Footer Layout'))}</td>
	<td class="field-data-cell">${renderer.errorlist("template.FooterLayout")}
	${renderer.select("template.FooterLayout", [(x.LayoutID, x.LayoutName + (' *' if x.SystemLayout else '')) for x in layouts['footer']], class_="form-control")}
	%if not template or not template.SystemTemplate:
	${menu_form('footer')}
	%endif
	</td>
</tr>

%if use_cic:
<tr>
	<td class="field-label-cell">${renderer.label("template.SearchLayoutCIC", _('CIC Search Layout'))}</td>
	<td class="field-data-cell">${renderer.errorlist("template.SearchLayoutCIC")}
	${renderer.select("template.SearchLayoutCIC", [("","")] + [(x.LayoutID, x.LayoutName + (' *' if x.SystemLayout else '')) for x in layouts.get('cicsearch', [])], class_="form-control")}
	%if not template or not template.SystemTemplate:
	${menu_form('cicsearch')}
	%endif
	</td>
</tr>
%endif

%if use_vol:
<tr>
	<td class="field-label-cell">${renderer.label("template.SearchLayoutVOL", _('Volunteer Search Layout'))}</td>
	<td class="field-data-cell">${renderer.errorlist("template.SearchLayoutVOL")}
	${renderer.select("template.SearchLayoutVOL", [("","")] + [(x.LayoutID, x.LayoutName + (' *' if x.SystemLayout else '')) for x in layouts.get('volsearch', [])], class_="form-control")}
	%if not template or not template.SystemTemplate:
	${menu_form('volsearch')}
	%endif
	</td>
</tr>
%endif


<!-- Label -->
<tr>
	<td class="field-label-cell">${_('Field Label')}</td>
	<td class="field-data-cell">
		${renderer.errorlist("template.fcLabel")}
		<div class="form-group row form-inline form-inline-always">
			${renderer.label("template.fcLabel", _('Text Color'), class_='col-xs-4 col-md-3 control-label')}
			<div class="col-xs-8 col-md-9">
				${renderer.colour("template.fcLabel", class_="form-control")}
			</div>
		</div>

		${renderer.errorlist("template.FieldLabelColour")}
		<div class="form-group row form-inline form-inline-always">
			${renderer.label("template.FieldLabelColour", _('Background Color'), class_='col-xs-4 col-md-3 control-label')}
			<div class="col-xs-8 col-md-9">
				${renderer.colour("template.FieldLabelColour", class_="form-control")}
			</div>
		</div>
		</td>
</tr>
<!-- End Label -->

${colour_set('Content',_('Content'))}

${colour_set('Title',_('Titles'))}

${colour_set('Header',_('Header'))}

${colour_set('Footer',_('Footer'))}

${colour_set('Menu',_('Menu'))}

${colour_set('Default','Default')}

${colour_set('Hover',_('Hover'))}

${colour_set('Active',_('Active'))}

${colour_set('Highlight',_('Highlight'))}

${colour_set('Error',_('Error'))}

${colour_set('Info',_('Info'))}

<tr>
	<td class="field-label-cell">${renderer.label("template.cornerRadius", _('Corner Radius'))}</td>
	<td class="field-data-cell">
		<div class="form-inline form-inline-always">
			${renderer.errorlist("template.cornerRadius")}
			${renderer.text("template.cornerRadius", maxlength=10, class_="form-control")}
		</div>
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.fsDefault", _('jQuery Widget Font Size'))}</td>
	<td class="field-data-cell">
		<div class="form-inline form-inline-always">
			${renderer.errorlist("template.fsDefault")}
			${renderer.text("template.fsDefault", maxlength=10, class_="form-control")}
		</div>
	</td>
</tr>

<!-- Deprecated -->

<tr>
	<th colspan="2"><span class="Alert">${_('Warning: the values below are deprecated and should not be used in new Template Layouts')}</span></th>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.TitleBgColour", _('Title Background Colour [OLD]'))}</td>
	<td class="field-data-cell">
		${renderer.errorlist("template.TitleBgColour")}
		<div class="form-inline form-inline-always">
			${renderer.colour("template.TitleBgColour", class_="form-control")}
		</div>
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.TitleFontColour", _('Title Text Colour [OLD]'))}</td>
	<td class="field-data-cell">
		${renderer.errorlist("template.TitleFontColour")}
		<div class="form-inline form-inline-always">
			${renderer.colour("template.TitleFontColour", class_="form-control")}
		</div>
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.MenuBgColour", _('Menu Background Colour [OLD]'))}</td>
	<td class="field-data-cell">
		${renderer.errorlist("template.MenuBgColour")}
		<div class="form-inline form-inline-always">
			${renderer.colour("template.MenuBgColour", class_="form-control")}
		</div>
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label("template.MenuFontColour", _('Menu Text Colour [OLD]'))}</td>
	<td class="field-data-cell">
		${renderer.errorlist("template.MenuFontColour")}
		<div class="form-inline form-inline-always">
			${renderer.colour("template.MenuFontColour", class_="form-control")}
		</div>
	</td>
</tr>

<!-- End Deprecated -->


</table>
%if not template or not template.SystemTemplate:
	%if not is_add and template.ReadOnlyTemplateOwner:
	<span class="Alert">${_('Setup of this item is exclusively controlled by the Agency: ') + template.ReadOnlyTemplateOwner}</span>
	%else:
	<input type="submit" name="Submit" value="${_('Add') if action=='add' else _('Update')}" class="btn btn-default">
	%if action != 'add' and can_delete:
	<input type="submit" name="Delete" value="${_('Delete')}" class="btn btn-default">
	%endif
	%endif
	<input type="reset" value="${_('Reset Form')}" class="btn btn-default">
%endif

</form>
</div>

<script type="text/html" id="menu-edit-template">
	${menu_item('[PREFIX]', 'NEW')}
</script>

<%def name="menu_form(which)">
<% menus_lang = menus.get(which,{}) %>
%for culture in active_cultures:
<% lang = culture_map[culture] %>
<div class="menu-edit">
<h3>${_('Menu Items')} ( ${lang.LanguageName} )</h3>

%for i in range(1,4):
<div class="form-group row">
	<% field_name = 'descriptions.%s.%sGroup%d' % (lang.FormCulture, which, i) %>
	${renderer.label(field_name, _('Group %s') % i, class_='col-sm-3 col-md-2 control-label')}
	<div class="col-sm-9 col-md-10">
		${renderer.errorlist(field_name)}
		${renderer.text(field_name, maxlength=100, class_="form-control")}
	</div>
</div>
%endfor

<table class="BasicBorder cell-padding-2 full-width clear-line-below">
<thead>
<tr>
	<th>${_('Delete')}</th>
	<th>${_('Link')}</th>
	<th>${_('Display')}</th>
	<th>${_('Group')}</th>
	<th>${_('Re-Order')}</th>
</tr>
</thead>
<tbody class="sortable">
<% lang_prefix = 'menus.' + which + '.' + lang.FormCulture + '-' %>
%for index,menu in enumerate(menus_lang.get(lang.FormCulture, [])):
	<% 
		prefix = lang_prefix + str(index) 
		itemid = menu.get('MenuID', 'NEW')
	%>
	${menu_item(prefix, itemid)}
%endfor
</tbody>
</table>
<button class="add-menu-item btn btn-info" data-prefix="${lang_prefix}" data-last-item="999">${_('Add Menu Item')}</button>
</div>
%endfor

</%def>

<%def name="menu_item(prefix, itemid)">
	<tr>
		<td>
			${renderer.hidden(prefix + '.MenuID', itemid)}
			${renderer.checkbox(prefix + '.delete', title=_('Delete Menu Item'))}
		</td>
		<td>${renderer.errorlist(prefix + '.Link')}${renderer.text(prefix + '.Link', maxlength=150, title=_('Link Location'), class_="form-control")}</td>
		<td>${renderer.errorlist(prefix + '.Display')}${renderer.text(prefix + '.Display', maxlength=255, title=_('Display Text'), class_="form-control")}</td>
		<td>${renderer.errorlist(prefix + '.MenuGroup')}${renderer.select(prefix + '.MenuGroup', options=[('',''), '1', '2', '3'], class_="form-control")}</td>
		<td><div class="ui-state-default ui-corner-all drag-handle"><span class="ui-icon ui-icon-arrow-2-n-s">${_('Drag to Re-Order Items')}</span></div></td>
	</tr>
</%def>

<%def name="headerextra()">
<link rel="STYLESHEET" type="text/css" href="/styles/jpicker-1.1.6.min.css">
</%def>
<%def name="bottomjs()">
${request.assetmgr.JSVerScriptTag("scripts/jpicker-1.1.6.min.js")}
<script type="text/javascript">
(function() {
$.fn.jPicker.defaults.images.clientPath='/images/jPicker/';
// Return a helper with preserved width of cells
var sortable_row_size_helper = function(e, ui) {
	ui.children().each(function() {
		var self = $(this);
		self.width(self.width());
	});
	return ui;
}, update_field_names = function(parent) {
	parent.find('tr').each(function(row_idx, element) {
		$(element).find('input,select').prop('name', function(idx, value) {
			var parts = value.split('-'), suffix = parts[1].split('.')[1];
			return parts[0] + '-' + row_idx + '.' + suffix;
		});
	});
	return parent;
},on_update = function(e, ui) {
	update_field_names( ui.item.parent())
};

jQuery(function($) {
	$('.colour').jPicker();

	$('.add-menu-item').live('click',function() {
		var self = $(this), parent = self.parents('.menu-edit').first(),
		last_item=self.data('lastItem'), prefix = self.data('prefix')+last_item, template = $('#menu-edit-template')[0].innerHTML, 
		rows = parent.find('tr'), sortable = parent.find('.sortable'), 
		row = template.replace(/\[PREFIX\]/g, prefix);
		self.data('lastItem',parseInt(last_item,10)+1)

		sortable.append($(row));
		update_field_names(sortable).sortable('refresh');

		parent.find('table').show();

		return false;
	});
	$('.menu-edit').each(function() {
		var self = $(this), tbody = self.find('.sortable'), rows = tbody.find('tr');
		tbody.sortable({handle: '.drag-handle', helper: sortable_row_size_helper, 'update': on_update});

		if (!rows.length) {
			self.find('table').hide();
		}


	});
});
})();
</script>
</%def>

