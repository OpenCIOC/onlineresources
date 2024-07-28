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
<%
from webhelpers2.html import tags
from cioc.core.modelstate import convert_options
%>

<h1>${renderinfo.doc_title}</h1>
<form action="${request.route_path('print_list_cic')}" method="post" class="form">
	<div class="NotVisible">
		${request.passvars.cached_form_vals|n}
		${renderer.hidden("ProfileID", request.viewdata.dom.DefaultPrintProfile)}
		${renderer.hidden("Picked", "on")}
	</div>

<h2>${_('Step 1: ') + _('Selected Communities')}</h2>
%if not communities:
<p><em>${_('None selected')}</em></p>
%else:
    %if cmtype == 'L':
<p class="demi-bold">${_('Located in the chosen communities: ')}</p>
    %else:
<p class="demi-bold">${_('Serving the chosen communities: ')}</p>
    %endif
<ul class="row">
    %for community in communities:
    <li class="col-xs-12 col-sm-6 col-md-4">${community.Community}</li>
    %endfor
</ul>
<div class="NotVisible">
    %if cmtype == 'L':
    <input type="hidden" name="CMType" value="L" />
    %else:
    <input type="hidden" name="CMType" value="S" />
    %endif
    %for community in communities:
    <input type="hidden" name="CMID" value="${community.CM_ID}">
    %endfor
</div>
%endif

<h2>${_('Step 2: ') + _('Selected Topics')}</h2>
%if not headings and not pubs:
<p><em>${_('None selected')}</em></p>
%else:
<ul class="row">
    %for heading in headings:
    <li class="col-xs-12 col-sm-12 col-md-6 col-lg-4">${heading.GeneralHeading}</li>
    %endfor
    %for pub in pubs:
    <li class="col-xs-12 col-sm-12 col-md-6 col-lg-4">${pub.Name}</li>
    %endfor
</ul>
<div class="NotVisible">
    %for heading in headings:
    <input type="hidden" name="GHID" value="${heading.GH_ID}">
    %endfor
    %for pub in pubs:
    <input type="hidden" name="PBID" value="${pub.PB_ID}">
    %endfor
</div>
%endif

<h2>${_('Step 3: ') + _('Report Settings')}</h2>

<h3>${_('Report Title: ')}</h3>
${renderer.text('ReportTitle', maxlength=255, class_='form-control')}

%if headings and not pubs:
<h3>${_('Organize Records by: ')}</h3>
<div class="radio">
    ${renderer.radio("IndexType", value='N', label=_('Organization or Program Name'), id='IndexType_Name', checked=True)}
</div>
<div class="radio">
    ${renderer.radio("IndexType", value='T', label=_('Topic'), id='IndexType_Topic')}
</div>
%else:
<div class="NotVisible">
    ${renderer.hidden("IndexType", 'N')}
</div>
%endif

<h3>${_('Report Format: ')}</h3>
<div class="radio">
    ${renderer.radio("OutputPDF", value='', label=_('Printable list (webpage)'), id='FormatType_HTML', checked=True)}
</div>
<div class="radio">
    ${renderer.radio("OutputPDF", value='on', label=_('PDF Document'), id="FormatType_PDF")}
</div>
%if request.user and (request.viewdata.dom.CanSeeNonPublic or request.viewdata.dom.CanSeeDeleted):
<h3>${_('Record Visibility: ')}</h3>
%if request.viewdata.dom.CanSeeNonPublic:
<div class="checkbox">
    ${renderer.checkbox("IncludeNonPublic", "on", label=_('Include Non-Public Records'))}
</div>
%endif
%if request.viewdata.dom.CanSeeDeleted:
<div class="checkbox">
    ${renderer.checkbox("IncludeDeleted", "on", label=_('Include Deleted Records'))}
</div>
%endif
%endif

    <div class="clear-line-above">
        <a href="${request.passvars.route_path('cic_customreport_index')}" class="btn btn-info"><< ${_('Start Over')}</a>
        <input type="submit" class="btn btn-info" value="${_('Next Step: ') + _('Generate Report')} >>">
    </div>
</form>
