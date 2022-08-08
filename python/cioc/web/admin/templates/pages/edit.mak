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
from operator import itemgetter
%>
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp' if request.user.SuperUser else 'setup_webdev.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_pages_index', _query=[('DM', domain.id)])}">${_('Pages')}</a> ]</p>
<form method="post" action="${request.current_route_path()}">
<div class="NotVisible">
${request.passvars.cached_form_vals|n}
%if not is_add:
<input type="hidden" name="PageID" value="${PageID}">
%endif
<input type="hidden" name="DM" value="${domain.id}">
</div>

<table class="BasicBorder cell-padding-4 form-table responsive-table clear-line-below max-width-lg">
<tr>
	<th class="RevTitleBox" colspan="2">${_('Add Page') if is_add else _('Edit Page')}</th>
</tr>
%if not is_add and context.get('page') is not None:
${self.makeMgmtInfo(page)}
%endif
<tr>
	<td class="field-label-cell">${_('Owner')}</td>
	<td class="field-data-cell">
		${renderer.errorlist("page.Owner")}
		${renderer.checkbox("page.Owner", request.user.Agency, label=" " + _('Setup of this item is exclusively controlled by the Agency: ') + ((page and page.ReadOnlyPageOwner) or request.user.Agency))}
</tr>
<tr>
	<td class="field-label-cell">${_('Language')}</td>
	<td class="field-data-cell">
	%if is_add:
	${renderer.errorlist('page.Culture')}
	${renderer.select('page.Culture', [(x, culture_map[x].LanguageName) for x in active_cultures])}
	%else:
	${page.LanguageName}
	%endif
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label('page.Slug', _('Slug'))}</td>
	<td class="field-data-cell">
	${renderer.errorlist("page.Slug")}
	${renderer.text("page.Slug", maxlength=50, class_="form-control")}
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label('page.Title', _('Title'))}</td>
	<td class="field-data-cell">
	${renderer.errorlist("page.Title")}
	${renderer.text("page.Title", maxlength=200, class_="form-control")}
	</td>
</tr>
<tr>
	<td class="field-label-cell">${renderer.label('page.PageContent', _('Page Content'))}</td>
	<td class="field-data-cell">
	${renderer.errorlist("page.PageContent")}
	${renderer.textarea("page.PageContent", max_rows=30, class_="form-control")}
	</td>
</tr>
<tr>
	<td class="field-label-cell">${_('Views')}</td>
	<td class="field-data-cell">
	${renderer.errorlist('views')}
	%for i, view in enumerate(views):
		%if i:
		<br>
		 %endif
		 ${renderer.ms_checkbox('views', view.ViewType, label=view.ViewName)}
		 %if page and view.Selected:
			 %if domain.id == const.DM_CIC:
				<% lnk = request.passvars.route_path('pages_cic', slug=page.Slug, _query=[('UseCICVw', str(view.ViewType))]) %>
			 %else:
				<% lnk = request.passvars.route_path('pages_vol', slug=page.Slug, _query=[('UseVOLVw', str(view.ViewType))]) %>
			 %endif
			 <a href="${lnk}" target="_blank">${_('View Page')} <span class="glyphicon glyphicon-new-window" class="aria-hidden"></span></a>
		 %endif
	%endfor
	</td>
</tr>
</table>

<input type="submit" name="Submit" value="${_('Add') if is_add else _('Update')}" class="btn btn-default">
%if not is_add:
<input type="submit" name="Delete" value="${_('Delete')}" class="btn btn-default">
%endif
<input type="reset" value="${_('Reset Form')}" class="btn btn-default">

</form>

<%def name="bottomjs()">
<script type="text/javascript">
$(document).ready(function(){
    $('[data-toggle="popover"]').popover();
});
</script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/tinymce/6.1.0/tinymce.min.js" integrity="sha512-dr3qAVHfaeyZQPiuN6yce1YuH7YGjtUXRFpYK8OfQgky36SUfTfN3+SFGoq5hv4hRXoXxAspdHw4ITsSG+Ud/g==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script type="text/javascript">
    tinymce.init({
        selector: '#page_PageContent',
        plugins: 'anchor autolink link advlist lists image charmap preview searchreplace paste visualblocks code fullscreen insertdatetime media table contextmenu help',
        menubar: 'edit view insert format table help',
        toolbar: 'undo redo styles bullist numlist link | bold italic underline removeformat | copy cut paste searchreplace code',
        extended_valid_elements: 'span[*],i[*],script[*]',
        convert_urls: false,
        schema: 'html5'
	});
</script>
</%def>
