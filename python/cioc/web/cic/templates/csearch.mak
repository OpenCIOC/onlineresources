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

${childsearchform}

<%def name="inlinebottomjs()">
${mapsbottomjs}
</%def>
<%def name="bottomjs()">
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<% renderinfo.list_script_loaded = True %>
${request.assetmgr.JSVerScriptTag('scripts/bsearch.js')}
${inlinebottomjs()}
<script type="text/javascript">
jQuery(function() {
	init_cached_state();
	init_pre_fill_search_parameters();
	init_bsearch_community_dropdown_expand("${_('Select ')}","${ request.passvars.makeLink(request.pageinfo.PathToStart + "jsonfeeds/community_generator.asp")}")
	restore_cached_state();
});
</script>
</%def>
