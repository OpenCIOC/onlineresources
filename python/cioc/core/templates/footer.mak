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

<%def name="footer()">
<%! 
import json

from datetime import date
from cioc.core import gtranslate 
%>
<% email_messages = request.session.pop('email_messages', []) %>
%if email_messages:
			<div>
	%for message in email_messages:
				${message}
	%endfor
			</div>
%endif
		<% renderinfo.show_message = renderinfo.show_message and not request.viewdata.PrintMode %>
		%if renderinfo.show_message and request.pageinfo.DbAreaBottomMsg:
		<div id="bottom-message-container">
			<hr id="bottom-message-hr">
			${request.pageinfo.DbAreaBottomMsg|n}
		</div>
		%endif
		</div>
		
		%if renderinfo.print_table:
			${makeLayoutFooter()|n}

			%if not request.context.force_print_mode:
			<div class="container-fluid">
				<footer class="last-line">
					%if request.template_values['CopyrightNotice']:
					<div class="copyright">&copy; ${request.template_values['CopyrightNotice']|n}</div>
					%endif
					%if not request.viewdata.PrintMode:
					<div class="cioc-attribution">${_('This database runs on the <a href="http://www.opencioc.org/">OpenCIOC Platform</a>')|n}</div>
					%else:
					<div class="cioc-attribution printed-on">${_('Printed on:')} ${format_date(date.today())}</div>
					%endif
				</footer>
			</div>
			%endif
		%endif

	</div> <!--! end of #container -->

	%if not request.params.get("InlineResults")=="on":
		${request.assetmgr.makeJQueryScriptTags()|n}
	%endif

	%if hasattr(caller, 'bottomjs') and not request.params.get("InlineResults")=="on":
		${caller.bottomjs()}
	%endif

	%if request.viewdata.PrintMode:
		<script type="text/javascript">
		%if not request.context.force_print_mode:
			var pageTitle= prompt('Please enter a Title for the report', '');
			if ((pageTitle!='') && (pageTitle!=null)) { 
				document.getElementById('PrintModePageTitle').innerHTML=pageTitle;
				show(document.getElementById('PrintModePageTitle'));
			}
		%endif
		%if renderinfo.focus:
			(function() {
				window.onerror = null;
				if (top.frames.length == 0 || navigator.appName != "Microsoft Internet Explorer") {
					self.document.forms.${renderinfo.focus}.focus();
				}
			})();
		%endif
		</script>
	%else:
	%if not renderinfo.list_script_loaded and not request.params.get("InlineResults")=="on":
		${request.assetmgr.JSVerScriptTag("scripts/ciocbasic.js")|n}
	%endif

	%if (request.pageinfo.DbArea != const.DM_GLOBAL and request.viewdata.dom.MyList) or (request.pageinfo.DbArea == const.DM_CIC and renderinfo.ct_launched):
		<% bEnableListViewMode = request.pageinfo.ThisPage.lower() == "viewlist.asp" %>
	<script type="text/javascript">
	(function() {
	var list_nums = ${renderinfo.my_list_values|n};

	var init = function() {
		init_list_adder({
			has_session: ${'true' if renderinfo.has_session else 'false'},
			list_view_mode: ${("'ct'" if renderinfo.ct_list_mode else "true") if bEnableListViewMode else "false" |n},
			%if not bEnableListViewMode:
			already_added: list_nums,
			%if renderinfo.ct_launched:
			in_request: "${request.passvars.makeLink(request.pageinfo.PathToStart + "ct/inrequest")}",
			%endif
			%endif
			ct_update_url: "${request.passvars.makeLink(request.pageinfo.PathToStart + "ct/push")}",
			list_update_url: "${request.passvars.makeLink(request.pageinfo.PathToStart + "jsonfeeds/updatelist.asp")}",
			domain: '${request.pageinfo.DbAreaS}'
			});
	}
	%if not request.params.get('InlineResults')=='on':
	jQuery(init);
	%else:
	setTimeout(init, 10);
	%endif
	})();
	%if renderinfo.focus:
		(function() {
			window.onerror = null;
			if (top.frames.length == 0 || navigator.appName != "Microsoft Internet Explorer") {
				self.document.forms.${renderinfo.focus}.focus();
			}
		})();
	%endif
	</script>
	%endif
	%endif

	%if request.template_values['JavaScriptBottomUrl']:
	<script type="text/javascript" src="${request.template_values['JavaScriptBottomUrl']}"></script>
	%endif

	%if request.dboptions.domain_info.get('GoogleAnalyticsCode') or request.dboptions.dbopts.get('GlobalGoogleAnalyticsCode'):
	<!-- Google Analytics -->
	<script type="text/javascript">
	%if not request.params.get('InlineResults')=='on':
		(function() {
		(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
		(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
		m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
		})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
		%for prefix, name, source in [('','', request.dboptions.domain_info), ('Global', 'cioc_all_views.', request.dboptions.dbopts), ('Second', 'second.', request.dboptions.domain_info)]:
			<% name_prefix = (prefix.lower() + '_') if prefix else '' %>
		%if source.get(prefix + 'GoogleAnalyticsCode'):
			window.${name_prefix}cioc_ga_code = '${source[prefix + 'GoogleAnalyticsCode'].replace("'", "\\'")}';
			ga('create', window.${name_prefix}cioc_ga_code, 'auto' ${(", '" + name[:-1] + "'") if name else '' |n});
			%if source.get(prefix + 'GoogleAnalyticsAgencyDimension'):
				ga('${name}set', 'dimension${source[prefix + 'GoogleAnalyticsAgencyDimension']}', '${request.user.Agency if request.user else 'PUBLIC'}');
			%endif
			%if source.get(prefix + 'GoogleAnalyticsLanguageDimension'):
				ga('${name}set', 'dimension${source[prefix + 'GoogleAnalyticsLanguageDimension']}', '${request.language.Culture}');
			%endif
			%if source.get(prefix + 'GoogleAnalyticsDomainDimension'):
				ga('${name}set', 'dimension${source[prefix + 'GoogleAnalyticsDomainDimension']}', '${request.pageinfo.DbAreaS + ('' if not request.viewdata.dom else ('-%s' % request.viewdata.dom.ViewType))}');
			%endif
			%if source.get(prefix + 'GoogleAnalyticsResultsCountMetric'):
				if (window.cioc_results_count) {
					ga('${name}set', 'dimension${source[prefix + 'GoogleAnalyticsResultsCountMetric']}', window.cioc_results_count);
				}
			%endif
			ga('${name}send', 'pageview');
		%endif
		%endfor
		})();
	%else:
		if (ga) {
			<% 
			url = request.path_qs
			if url.startswith('/details.asp'):
				exclude = ['NUM', 'UseCICVw', 'UseVOLVw', 'Ln', 'UseEq', 'InlineResults']
				
				new_params = [(x, request.params[x]) for x in request.GET if x not in exclude]
				num = request.params.get('NUM')
				url = request.passvars.makeDetailsLink(request.params.get('NUM'), new_params)
			if url.startswith('/volunteer/details.asp'):
				exclude = ['VNUM', 'UseCICVw', 'UseVOLVw', 'Ln', 'UseEq', 'InlineResults']
				
				new_params = [(x, request.params[x]) for x in request.GET if x not in exclude]
				num = request.params.get('VNUM')
				url = request.passvars.makeVOLDetailsLink(request.params.get('VNUM'), new_params)
			%>
			%for prefix, name in [('', ''), ('global_', 'cioc_all_views.'), ('second_', 'second.')]:
				if (window.${prefix}cioc_ga_code) {
					ga('${name}send', 'pageview', {'page': ${json.dumps(url)|n}, 'title': ${json.dumps((renderinfo.doc_title or '').replace('<br>', ' ').replace('&nbsp;', ' '))|n} });
				}
			%endfor
		}
	%endif

	</script>
	<!-- End Google Analytics -->
	%endif
%if not request.params.get('InlineResults')=='on':
	%if request.added_gtranslate:
	<script type="text/javascript">
	jQuery(function(){
		window.googleTranslateElementInit = function() {
			var settings = {pageLanguage: '${request.language.Culture}', layout: google.translate.TranslateElement.InlineLayout.SIMPLE}
			if (window.cioc_ga_code) {
				settings.gaTrack = true;
				settings.gaId = window.cioc_ga_code;
			}
			jQuery('#google-translate-element-parent').show();
			new google.translate.TranslateElement(settings, 'google-translate-element');
		};
	});
	</script>
	%endif
	${gtranslate.render_script(request)}
	${request.template_values.get('ExtraJavascript') or '' |n}
</body>
</html>
%endif
</%def>
${footer()}
