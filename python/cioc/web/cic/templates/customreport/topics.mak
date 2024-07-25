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
<%namespace file="cioc.web.cic:templates/bsearch.mak" name="bsearch"/>
<%namespace file="cioc.web.cic:templates/searchcommon.mak" import="community_form" />
<%
from webhelpers2.html import tags
from cioc.core.modelstate import convert_options
%>

<h1>${renderinfo.doc_title}</h1>
<h2>${_('Step 1: ') + _('Selected Communities')}</h2>
%if not communities:
<p><em>${_('None selected')}</em></p>
%else:
<ul>
    %for community in communities:
    <li>${community.Community}</li>
    %endfor
</ul>
%endif

<h2>${_('Step 2: ') + _('Choose one or more Topics')}</h2>
