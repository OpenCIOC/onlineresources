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
from itertools import izip_longest

def grouper(n, iterable, fillvalue=None):
	"grouper(3, 'ABCDEFG', 'x') --> ABC DEF Gxx"
	args = [iter(iterable)] * n
	return izip_longest(fillvalue=fillvalue, *args)
%>

<%def name="gh_selector(fieldname, headings, existing)">
	%if existing:
		<div><strong>${_('Existing Headings')}</strong></div>
		${heading_checkboxes(fieldname, (x for x in headings if unicode(x.GH_ID) in existing))}
	%endif
	%if caller:
	${caller.body()}
	%endif
	%if set(unicode(x.GH_ID) for x in headings) - existing:
	<div><br><strong>${_('Add New Headings')}</strong></div>
	${heading_checkboxes(fieldname, (x for x in headings if unicode(x.GH_ID) not in existing))}
	%endif
</%def>

<%def name="heading_checkboxes(fieldname, groupheadings)">
<table class="NoBorder cell-padding-2">
%for headings in grouper(2, groupheadings):
<tr>
	%for heading in headings:
	<td>
	%if heading:
		${renderer.ms_checkbox(fieldname, heading.GH_ID, label=heading.Name)}
	%endif
	</td>
	%endfor
</tr>
%endfor
</table>
</%def>
