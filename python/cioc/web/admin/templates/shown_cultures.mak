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

<%def name="shown_cultures_ui(edit=True)">
<div class="NotVisible">
	%for culture in active_cultures:
	<input type="hidden" name="ShowCulture" value="${culture}">
	%endfor
</div>

<% remaining_cultures = [rc for rc in record_cultures if rc not in active_cultures] %>
%if remaining_cultures:
<div id="show-also" class="clear-line-above">
	<p>
		%if edit:
		${_('Also edit labels in:')}
		%else:
		${_('Also show labels in:')}
		%endif
	</p>
	<ul>
		%for culture in remaining_cultures:
		<% lang = culture_map[culture] %>
		<li>
			<label for="ShowCultures_${culture}">
				<input id="ShowCultures_${culture}" class="ShowCultures" type="checkbox" name="ShowCultures" value="${culture}" ${'checked' if culture in shown_cultures else '' }> ${_('Edit Labels in ') if edit else _('Show Labels in ')}
				${lang.LanguageName}
			</label>
		</li>
		%endfor
	</ul>
</div>
%endif
</%def>
<%def name="shown_cultures_attrs(culture, extra_class='')">class="${extra_class} culture-${culture}" ${'' if culture in shown_cultures else 'style="display: none;"' |n}</%def>

<%def name="shown_cultures_js()">
<script type="text/javascript">
	(function () {
		var toggle_culture_display = function () {
			var form = $(this).parents('form,body').first().hide()
			if (this.checked) {
				form.find('.culture-' + this.value).show();
			} else {
				form.find('.culture-' + this.value).hide();
			}
			form.show()
		};
		jQuery(function ($) {

			$('.ShowCultures').live('change', toggle_culture_display).
				each(toggle_culture_display);
		});
	})();
</script>
</%def>
