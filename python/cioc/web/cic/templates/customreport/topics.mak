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

<%!
from webhelpers2.html import tags
from cioc.core.modelstate import convert_options
%>
<%inherit file="cioc.web:templates/master.mak" />


<h1>${renderinfo.doc_title}</h1>
<form action="${request.route_path('cic_customreport_format')}" method="post" class="form">
    <div class="NotVisible">
        ${request.passvars.cached_form_vals|n}
        %if cmtype == 'L':
        <input type="hidden" name="CMType" value="L" />
        %else:
        <input type="hidden" name="CMType" value="S" />
        %endif
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
        %for community in communities:
        <input type="hidden" name="CMID" value="${community.CM_ID}">
        %endfor
    </div>
    %endif

    <h2>${_('Step 2: ') + _('Choose one or more Topics')}</h2>
    %if not headings:
    <p><em>${_('None available')}</em></p>
    %else:
    %if request.viewdata.cic.QuickListPubHeadings:
    <div class="NotVisible">
        ${renderer.hidden("GHPBID", request.viewdata.cic.QuickListPubHeadings)}
    </div>
    <%
    prev_heading_group = headings[0].Group
    heading_groups = True
    %>
    <ul class="no-bullet-list-indented report-heading-list">
        %if prev_heading_group:
        <li><strong>${prev_heading_group}</strong></li>
        <ul class="no-bullet-list-indented report-heading-list">
            %endif
            %for heading in headings:
            %if (heading.Group is not None and prev_heading_group != heading.Group):
            <%
            heading_groups = True
            %>
            %if heading_groups:
        </ul>
        %endif
    </ul>
    <ul class="no-bullet-list-indented report-heading-list">
        <li><strong>${heading.Group}</strong></li>
        <ul class="no-bullet-list-indented report-heading-list">
            %endif
            <%
            kwargs = {'data-record-count': heading.RecordCount}
            %>
            <li>${renderer.ms_checkbox('GHID', heading.GH_ID, label=heading.GeneralHeading, label_class='control_label', **kwargs)} <span class="badge">${heading.RecordCount}</span></li>
            <%
            prev_heading_group = heading.Group
            %>
            %endfor
            %if heading_groups:
        </ul>
        %endif
    </ul>
    %else:
    <ul class="no-bullet-list-indented report-heading-list">
        %for heading in headings:
        <li>${renderer.ms_checkbox('PBID', heading.PB_ID, label=heading.Name, label_class='control_label')} <span class="badge">${heading.RecordCount}</span></li>
        %endfor
    </ul>
    %endif
    %endif
    <div class="clear-line-above">
        <a href="${request.passvars.route_path('cic_customreport_index')}" class="btn btn-info"><< ${_('Start Over')}</a>
        <input type="submit" class="btn btn-info" value="${_('Next Step: ') + _('Choose Format')} >>">
    </div>
</form>
