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
from cioc.core import constants as const
from cioc.core.format import textToHTML
from markupsafe import Markup
%>
<%def name="printROContactInfo(bOnline, id, ro)">

<ul>
%if ro.MailAddress or ro.SiteAddress:
	<li>${_('By <strong>Mail</strong> at:')|n} <blockquote>${textToHTML(ro.MailAddress or ro.SiteAddress)}</blockquote></li>
%endif
%if ro.UpdatePhone:
	<li>${_('By <strong>Phone</strong> at:')|n} ${ro.UpdatePhone}</li>
%endif
%if ro.Fax:
	<li>${_('By <strong>Fax</strong> at:')|n} ${ro.Fax}</li>
%endif
%if ro.UpdateEmail:
	<li>${_('By <strong>Email</strong> at:')|n} <a href="mailto:${ro.UpdateEmail}">${ro.UpdateEmail}</a></li>
%endif
%if bOnline:
	%if request.pageinfo.Domain == const.DM_CIC:
	<li>${Markup(_('<strong>Online</strong> using the "Suggest Update" option at'))} <strong>${request.host_url}/feedback.asp?NUM=${id}&amp;Ln=${request.language.Culture}</strong></li>
	%elif request.pageinfo.Domain == const.DM_VOL:
	<li>${Markup(_('<strong>Online</strong> using the "Suggest Update" option at'))} <strong>${request.host_url}/volunteer/feedback.asp?OPID=${id}&amp;Ln=${request.language.Culture}</strong></li>
	%endif
%endif:
</ul>
</%def>

