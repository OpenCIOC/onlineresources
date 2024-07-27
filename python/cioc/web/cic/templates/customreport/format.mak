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
<form action="" method="post" class="form">
	<div class="NotVisible">
		${request.passvars.cached_form_vals|n}
	</div>

<h2>${_('Step 1: ') + _('Selected Communities')}</h2>
%if not communities:
<p><em>${_('None selected')}</em></p>
%else:
<ul class="row">
    %for community in communities:
    <li class="col-xs-12 col-sm-6 col-md-4">${community.Community}</li>
    %endfor
</ul>
<div class="NotVisible">
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

<h3>${_('Organize Records by: ')}</h3>
<div class="radio">
    ${renderer.radio("IndexType", value='N', label=_('Organization or Program Name'), id='IndexType_Name', checked=True)}
</div>
<div class="radio">
    ${renderer.radio("IndexType", value='T', label=_('Topic'), id='IndexType_Topic')}
</div>

<h3>${_('Report Format: ')}</h3>
<div class="radio">
    ${renderer.radio("FormatType", value='H', label=_('Printable list (webpage)'), id='FormatType_HTML', checked=True)}
</div>
<div class="radio">
    ${renderer.radio("FormatType", value='P', label=_('PDF Document'), id="FormatType_PDF")}
</div>

    <div class="clear-line-above">
        <a href="${request.route_path('cic_customreport_index')}" class="btn btn-info"><< ${_('Start Over')}</a>
        <input type="submit" class="btn btn-info" value="${_('Next Step: ') + _('Generate Report')} >>">
    </div>
</form>