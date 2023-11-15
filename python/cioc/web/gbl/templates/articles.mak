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
from cioc.core import gtranslate
%>

%if not request.viewdata.PrintMode:
${gtranslate.render_ui(request)}
%endif

%if any(articles):
<div class="row">
	%for article in articles:
	%if request.pageinfo.DbArea == const.DM_CIC:
	<% lnk = request.passvars.route_path('pages_cic', slug=article.Slug) %>
	%else:
	<% lnk = request.passvars.route_path('pages_vol', slug=article.Slug) %>
	%endif

	<div class="col-md-6 col-xs-12" data-category="${article.Category}">
		<div class="panel panel-default">
			<div class="panel-heading">
				<a href="${lnk}">
					<h2 class="ArticleTitle">${article.Title}</h2>
				</a>
			</div>
			<div class="panel-body">
				%if article.Author or article.DisplayPublishDate:
				<div class="SmallNote clear-line-below">${article.Author} ${article.DisplayPublishDate}</div>
				%endif
				%if article.ThumbnailImageURL:
				<div class="row">
					<div class="col-xs-4">
						<a href="${lnk}"><img src="${article.ThumbnailImageURL}" aria-hidden="true" class="img-responsive img-thumbnail" /></a>
					</div>
					<div class="col-xs-8">
						%endif
						<p>${article.PreviewText or ''|n}</p>
						%if article.ThumbnailImageURL:
					</div>
				</div>
				%endif
				%if article.Category:
				<hr>
				<p class="SmallNote">${article.Category}</p>
				%endif
			</div>
		</div>

	</div>

	%endfor
</div>
%else:
<p class="Info">${_('There are no articles available.')}</p>
%endif
