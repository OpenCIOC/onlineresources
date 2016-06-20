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

%for topicsearch in topicsearches:
	<h2 class="RevBoxHeader">${topicsearch.SearchTitle}</h2>
	<p class="SubBoxHeader">${topicsearch.SearchDescription}</p>
	<div class="ButtonLink"><a href="${request.passvars.route_path('cic_topicsearch',tag=topicsearch.TopicSearchTag)}">${_('Search')} <em>${topicsearch.SearchTitle}</em></a></div>
%endfor
