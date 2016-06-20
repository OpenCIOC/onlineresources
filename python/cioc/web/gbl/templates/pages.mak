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

%if page:
${page.PageContent |n}
%else:
<p class="Info">${_('This page is not available in this language. Please choose a language from below:')}</p>
<ul>
%for lang in other_langs:
	<li><a href="${request.passvars.current_route_path(exclude_keys=['Ln'], _query=[('Ln', lang.Culture)])}">${lang.Title}</a></li>
%endfor
</ul>
%endif
