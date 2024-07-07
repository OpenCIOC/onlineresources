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

	%if request.dboptions.dbopts.get('AcceptCookiePrompt'):
	<!-- Modal -->
	<div class="modal fade" id="cioc-cookie-prompt-modal" tabindex="-1" role="dialog" aria-labelledby="cioc-cookie-prompt-modal-label">
	  <div class="modal-dialog" role="document">
		<div class="modal-content">
		  <div class="modal-header">
			<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
			<h4 class="modal-title" id="cioc-cookie-prompt-modal-label">${_('Cookie Details')}</h4>
		  </div>
		  <div class="modal-body">
			<div class="panel panel-default">
				<div class="panel-body">
					${_('We use cookies to enhance your browsing experience, serve personalized content, and analyze our traffic. By clicking "Accept All", you consent to our use of cookies.')}
				</div>
			</div>
			<div class="panel panel-default">
				<div
				class="panel-heading">
					${request.dboptions.get_best_lang('AcceptCookiePromptText') or _('Necessary')}
				</div>
				<div class="panel-body">
					${request.dboptions.get_best_lang('AcceptCookieDetails') or _('These cookies allow the site to work and last for the duration of your session. No personal information is tracked with these cookies.')}
				</div>
			</div>
			<div class="panel panel-default">
				<div class="panel-heading">
					${request.dboptions.get_best_lang('AcceptCookieOptionalText') or _('Optional Cookies')}
				</div>
				<div class="panel-body">
					${request.dboptions.get_best_lang('AcceptCookieOptionalDetails') or _('These cookies are used to understand how visitors interact with the website. These cookies help provide information on metrics such as the number of visitors, bounce rate, traffic source, etc.')}
				</div>
			</div>
		  </div>
		  <div class="modal-footer">
			<button type="button" class="btn btn-default" data-dismiss="modal">${_('Close')}</button>
			<button type="button" class="btn btn-default cioc-cookie-only-necessary">${_('Only Necessary')}</button>
			<button type="button" class="btn btn-primary cioc-cookie-accept-all">${_('Accept All')}</button>
		  </div>
		</div>
	  </div>
	</div>
	<div class="cioc-inline-cookie-container modal-content" id="cioc-inline-cookie-prompt"
	 style="display: none;" role="dialog" aria-labelledby="cioc-inline-cookie-prompt-title">
		 <div class="cioc-inline-cookie-prompt-header modal-header">
			<h4 class="modal-title" id="cioc-inline-cookie-prompt-title">${_('We value your privacy')}</h4>
		</div>
		 <div class="cioc-incline-cookie-prompt modal-body">
			${_('We use cookies to enhance your browsing experience, serve personalized content, and analyze our traffic. By clicking "Accept All", you consent to our use of cookies.')}
		 </div>
		 <div class="cioc-inline-cookie-notice-actions modal-footer">
			 <button type="button" class="btn btn-default cioc-cookie-details" data-toggle="modal"
						data-target="#cioc-cookie-prompt-modal">${_('Details')}</button>
			 <button type="button" class="btn btn-default cioc-cookie-only-necessary">${_('Only Necessary')}</button>
			 <button type="button" class="btn btn-primary cioc-cookie-accept-all">${_('Accept All')}</button>
		 </div>
	</div>
	%endif

	</div> <!--! end of #container -->

	%if not request.params.get("InlineResults")=="on":
		${request.assetmgr.makeJQueryScriptTags()|n}
	%endif

	%if hasattr(caller, 'bottomjs') and not request.params.get("InlineResults")=="on":
		${caller.bottomjs()}
	%elif context.kwargs.get('bottomjs') and not request.params.get("InlineResults")=="on":
		${context.kwargs['bottomjs']()}
	%endif
	<script type="text/javascript">
	 (
	  function() {
		  class CiocCookieConsent extends EventTarget {
			constructor() {
				super();
				var self = this;
				this.COOKIE_CONSENT_KEY = 'cioc_cookie_consent';
				this.prompt_enabled = ${"true" if request.dboptions.dbopts.get('AcceptCookiePrompt') else "false"};
				window.addEventListener("storage", function(e)
						{self.onStorageChange(e)});
				this.consent_state = this.check_stored_consent_state();
			}
			check_stored_consent_state() {
				let value = localStorage.getItem(this.COOKIE_CONSENT_KEY);
				return this.parse_stored_consent_state(value);
			}
			parse_stored_consent_state(value) {
				if (value) {
					let parsed = JSON.parse(value);
					let date_saved = new Date(parsed.date_saved);
					let maxage = date_saved.getTime() + (3600*24*182*1000);
					if(Date.now() > maxage) {
						localStorage.removeItem(this.COOKIE_CONSENT_KEY);
						return null;
					}
					return parsed;
				}
				return null;
			}
			emitConsentChangeEvent() {
				this.dispatchEvent(new CustomEvent("cookieconsentchanged", { detail: this.consent_state }));
			}
			onStorageChange(e) {
				if(e.key == this.COOKIE_CONSENT_KEY){
					this.consent_state = this.parse_stored_consent_state(e.newvalue);
					this.emitConsentChangeEvent();
				}
			}
			isAnalyticsAllowed() {
				if (!this.prompt_enabled) {
					return true;
				}
				return this.consent_state && this.consent_state.cookies_allowed === 'all';
			}
			storeConsentChange(cookies_allowed) {
				this.consent_state = {'date_saved': (new Date()).toISOString(),
						'cookies_allowed': cookies_allowed}
				let value = JSON.stringify(this.consent_state);
				localStorage.setItem(this.COOKIE_CONSENT_KEY, value);
				this.emitConsentChangeEvent();
				jQuery('#cioc-inline-cookie-prompt').hide();
				jQuery('#cioc-cookie-prompt-modal').modal('hide');
			}
			acceptAll() {
				this.storeConsentChange('all');
			}
			acceptNeccessary() {
				this.storeConsentChange('necessary');
			}
			configureUI($){
				var self = this;
				if(!this.consent_state) {
					$('#cioc-inline-cookie-prompt').show();
				}
				$("#body_content").on('click', '.cioc-cookie-accept-all', function() {
					self.acceptAll();
				}).on('click', '.cioc-cookie-only-necessary', function() {
					self.acceptNeccessary();
				});
			}
		  }
		  if(!window.cioc_cookie_consent) {
			  window.cioc_cookie_consent = new CiocCookieConsent();
			  if (window.cioc_cookie_consent.prompt_enabled) {
				  jQuery(function(){
					window.cioc_cookie_consent.configureUI(jQuery);
				  });
			  }
		  }

	  })();
	 </script>

	%if request.viewdata.PrintMode:
		<script type="text/javascript">
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
			in_request: ${request.passvars.makeLink(request.pageinfo.PathToStart + "ct/inrequest")|json.dumps},
			%endif
			%endif
			ct_update_url: ${request.passvars.makeLink(request.pageinfo.PathToStart + "ct/push")|json.dumps},
			list_update_url: ${request.passvars.makeLink(request.pageinfo.PathToStart + "jsonfeeds/updatelist.asp")|json.dumps},
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
	<%
	has_ga4 = request.dboptions.domain_info.get('GoogleAnalytics4Code') or request.dboptions.dbopts.get('GlobalGoogleAnalytics4Code')
	%>
	%if has_ga4:
	<!-- Google Analytics -->
	<script type="text/javascript">
	%if not request.params.get('InlineResults')=='on':
		(function() {
		window.dataLayer = window.dataLayer || [];
		window.gtag = function(){dataLayer.push(arguments);}
		if (window.cioc_cookie_consent.prompt_enabled) {
			gtag('consent', 'default', {
				'ad_user_data': 'denied',
				'ad_personalization': 'denied',
				'ad_storage': 'denied',
				'analytics_storage': 'denied',
			});
		}
		gtag('js', new Date());
		var record_page_event = function() {
		  var gtagScript = document.createElement('script');
		  gtagScript.async = true;
		  gtagScript.src = "https://www.googletagmanager.com/gtag/js?id=${request.dboptions.domain_info.get('GoogleAnalytics4Code') or request.dboptions.dbopts.get('GlobalGoogleAnalytics4Code')}";

		  var firstScript = document.getElementsByTagName('script')[0];
		  firstScript.parentNode.insertBefore(gtagScript,firstScript);

		%for prefix, name, source in [('','', request.dboptions.domain_info), ('Global', 'cioc_all_views.', request.dboptions.dbopts), ('Second', 'second.', request.dboptions.domain_info)]:
			<% name_prefix = (prefix.lower() + '_') if prefix else '' %>
		%if source.get(prefix + 'GoogleAnalytics4Code'):
		{
			<%
			dimensions = [
			   (source.get(prefix + 'GoogleAnalytics4AgencyDimension'), request.user.Agency if request.user else 'PUBLIC'),
			   (source.get(prefix + 'GoogleAnalytics4LanguageDimension'), request.language.Culture),
			   (source.get(prefix + 'GoogleAnalytics4DomainDimension'), request.pageinfo.DbAreaS + ('' if not request.viewdata.dom else f'-{request.viewdata.dom.ViewType}')),
			]
			dimensions = json.dumps({f'dimension{k}': v for k, v in dimensions if k is not None})
			%>
			let d = ${dimensions|n};
			%if source.get(prefix + 'GoogleAnalytics4ResultsCountMetric'):
			if(window.cioc_results_count) {
			   d['metric${source[prefix + 'GoogleAnalytics4ResultsCountMetric']}'] = window.cioc_results_count;
			}
			%endif

			window.${name_prefix}cioc_ga4_code = '${source[prefix + 'GoogleAnalytics4Code'].replace("'", "\\'")}';
			window.${name_prefix}cioc_ga4_dimensions = d;
			gtag('config', window.${name_prefix}cioc_ga4_code,  {send_page_view: false});
			gtag('event', 'page_view', jQuery.merge(
				{page_title: document.title,
				page_location: location.href, send_to:
				window.${name_prefix}cioc_ga4_code}, d)
			);
		}
		}
		var record_consent = function() {
			gtag('consent', 'update', {
				'ad_user_data': 'denied',
				'ad_personalization': 'denied',
				'ad_storage': 'denied',
				'analytics_storage': 'granted',
			});
		}
		if (window.cioc_cookie_consent.prompt_enabled) {
			if (window.cioc_cookie_consent.isAnalyticsAllowed()) {
				record_consent();
				record_page_event();
			} else {
				window.cioc_cookie_consent.addEventListener('cookieconsentchanged', function() {
					if (window.cioc_cookie_consent.isAnalyticsAllowed()) {
						record_consent();
						record_page_event();
					}
				});
			}
		} else {
			record_page_event();
		}
		%endif
		%endfor
		})();
	%else:
		if (gtag) {
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
			%for prefix, name, source in [('', '', request.dboptions.domain_info), ('Global', 'cioc_all_views.', request.dboptions.dbopts), ('Second', 'second.', request.dboptions.domain_info)]:
				<% name_prefix = (prefix.lower() + '_') if prefix else '' %>
				if (window.${name_prefix}cioc_ga4_code) {
					let d = jQuery.merge(
					{
					    'page_location': ${json.dumps(url)|n},
					    'page_title': ${json.dumps((renderinfo.doc_title or '').replace('<br>', ' ').replace('&nbsp;', ' '))|n},
					    'send_to': window.${name_prefix}cioc_ga4_code
					}, window.${name_prefix}cioc_ga4_dimensions );
					%if source.get(name_prefix, 'GoogleAnalytics4ResultsCountMetric'):
					    %if url.startswith(('/record/', '/volunteer/record/')):
					if (d['metric${source[prefix + 'GoogleAnalytics4ResultsCountMetric']}']){
					    delete d['metric${source[prefix + 'GoogleAnalytics4ResultsCountMetric']}'];
					} else
						%endif
						if (window.cioc_results_count) {
					    d['metric${source[prefix + 'GoogleAnalytics4ResultsCountMetric']}'] = window.cioc_results_count;
					}
					%endif
					gtag('event', 'page_view', d);
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
			if (window.cioc_ga4_code) {
				settings.gaTrack = true;
				settings.gaId = window.cioc_ga4_code;
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
