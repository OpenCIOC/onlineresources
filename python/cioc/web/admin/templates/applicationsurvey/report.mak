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
from itertools import groupby
from operator import attrgetter
%>
<%
if None not in (start_date,end_date):
    date_range = format_date(start_date) + _(' to ') + format_date(end_date)
elif start_date is not None:
    date_range = _('after ') + format_date(start_date)
elif end_date is not None:
    date_range = _('until ') + format_date(end_date)
else:
    date_range = _('all available dates')
%>
<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="${request.passvars.route_path('admin_applicationsurvey_index')}">${_('Application Surveys')}</a> ]</p>
<h2>${renderinfo.doc_title} (${date_range})</h2>

<h3>${_('Survey Counts')}</h3>
<table class="BasicBorder cell-padding-3">
    <thead>
        <tr>
            <th>${_('Name')}</th>
            <th>${_('Language')}</th>
            <th>${_('Total Entries')}</th>
            <th>${_('First Entry')}</th>
            <th>${_('Last Entry')}</th>
        </tr>
    </thead>
    <tbody>
        %for survey in counts_by_survey:
        <tr>
            <td>${survey.SurveyName}</td>
            <td>${survey.LanguageName}</td>
            <td>${survey.SurveyCount}</td>
            <td>${survey.FirstSubmissionInRange}</td>
            <td>${survey.LastSubmissionInRange}</td>
        </tr>
        %endfor
    </tbody>
</table>

<hr />
<h3>${_('City Counts')}</h3>
<table class="BasicBorder cell-padding-3">
    <thead>
        <tr>
            <th>${_('City')}</th>
            <th>${_('Total Entries')}</th>
        </tr>
    </thead>
    <tbody>
        %for survey in counts_by_city:
        <tr>
            <td>${survey.ApplicantCity}</td>
            <td>${survey.CityCount}</td>
        </tr>
        %endfor
    </tbody>
</table>

<hr />
<h3>${_('Question Response Counts')}</h3>

%for question,surveygroup in groupby(counts_by_answer, attrgetter('Question')):
<h4>${question}</h4>
<table class="BasicBorder cell-padding-3">
    <thead>
        <tr>
            <th>${_('Answer')}</th>
            <th>${_('Total Entries')}</th>
        </tr>
    </thead>
    <tbody>
        %for survey in surveygroup:
        <tr>
            <td>${survey.Answer}</td>
            <td>${survey.AnswerCount}</td>
        </tr>
        %endfor
    </tbody>
</table>
<br />
%endfor
