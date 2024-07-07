<%doc>
=========================================================================================
 Copyright 2024 KCL Software Solutions Inc.

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
<%namespace name="printoptions" file="cioc.web.gbl:templates/printlist/printoptions.mak" import="printlist_form,bottomjs" />

%if not only_show_error:
${printoptions.printlist_form()}
%endif

<%def name="bottomjs()">
%if not only_show_error:
${printoptions.bottomjs()}
%endif
</%def>
