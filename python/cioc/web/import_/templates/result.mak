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
%if not error_log:
<h2>${_('Validation of %s was SUCCESSFUL!') % filename}</h2>
%else:
<h2>${_('Validation of %s failed!') % filename}</h2>
%endif
<p>${_('<strong>%d records</strong> were loaded successfully and are ready to import. You will need to refresh the list of datasets to work with this information.') % total_inserted |n} 
%if error_log:
${_('Some records may not have been loaded; please refer to the error report below.')}
%endif
</p>
%if error_log:
<table class="BasicBorder cell-padding-4">
%for num,error in error_log:
<tr>
%if num:
<td>${num}</td>
%endif:
<td ${'' if num else 'colspan="2"' |n} style="white-space: pre-wrap">${error}</td>
</tr>
%endfor
</table>
%endif
<p align="center">[ <a href="javascript:parent.close()">Close Window</a> ]</p>

