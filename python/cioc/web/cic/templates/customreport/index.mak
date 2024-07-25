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

<h1>${renderinfo.doc_title}</h1>
<p>... report instructions here</p>
<h2>${_('Step 1: ') + _('Choose one or more Communities')}</h2>

<form action="${request.route_path('cic_customreport_topic')}" method="post" class="form">
${community_list(None, report_communities, False)}

<%def name="community_list(parent_id, communities, hidden)">
<ul id="list_${parent_id}" class="no-bullet-list-indented report-community-list ${'NotVisible' if hidden else ''}">
    %for community in communities[parent_id]:
    <li data-cmid="${community.CM_ID}" data-parent="${community.Parent_CM_ID}" data-cmlvl="${community.Lvl}">
        ${renderer.ms_checkbox('CMID', community.CM_ID, label=community.Community, label_class='control_label')}
        %if communities.get(community.CM_ID):
        ${community_list(community.CM_ID, communities, False)}
        %endif
    </li>
    %endfor
</ul>
</%def>

<input type="submit" class="btn btn-info clear-line-above" value="${_('Next Step: ') + _('Choose Topics')}">
