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
from markupsafe import Markup
%>
<%inherit file="cioc.web:templates/master.mak" />

<h1>${renderinfo.doc_title}</h1>
%if report_instructions.CustomReportInstructions:
${report_instructions.CustomReportInstructions|n}
%endif
<h2>${_('Step 1: ') + _('Choose one or more Communities')}</h2>

<form action="${request.route_path('cic_customreport_topic')}" method="post" class="form">
    <div class="NotVisible">
        ${request.passvars.cached_form_vals|n}
    </div>


    %if report_instructions.SrchCommunityDefaultOnly:
        %if report_instructions.SrchCommunityDefault:
    <input type="hidden" name="CMType" value="S" />
        %else:
    <input type="hidden" name="CMType" value="L" />
        %endif
    %else:
    <div class="radio">
        ${renderer.radio("CMType", value='L', label=_('Located in the chosen communities: '), id='CMType_L', checked=not report_instructions.SrchCommunityDefault)}
    </div>
    <div class="radio">
        ${renderer.radio("CMType", value='S', label=_('Serving the chosen communities: '), id='CMType_S', checked=report_instructions.SrchCommunityDefault)}
    </div>
    %endif

    <div id="parent-list" class="panel-group" role="tablist" aria-multiselectable="true">
        %for community in report_communities[None]:
        <div class="panel panel-default">
            <div class="panel-heading" role="tab" id="panel-heading-${community.CM_ID}">
                <h4 class="panel-title">
                    <a class="collapsed" role="button" data-toggle="collapse" href="#panel-collapse-${community.CM_ID}" aria-expanded="true" aria-controls="panel-collapse-${community.CM_ID}">
                        ${community.Community}
                    </a>
                </h4>
            </div>
            <div id="panel-collapse-${community.CM_ID}" class="panel-collapse collapse" role="tabpanel" aria-labelledby="panel-heading-${community.CM_ID}">
                <div class="panel-body">
                    ${renderer.ms_checkbox('CMID', community.CM_ID, label=Markup(_('All of <span class="demi-bold">%s</span>')) % (community.Community,), label_class='control_label')}
                    ${community_list(community.CM_ID, report_communities, False)}
                </div>
            </div>
        </div>
        %endfor
    </div>

    <p class="AlertBubble clear-line-above" id="proceed-community-alert">${_('Please choose one or more communities to proceed.')}</p>

    <div class="clear-line-above">
        <input type="reset" class="btn btn-info" value="${_('Reset Selections')}">
        <input type="submit" ${"disabled" if report_communities else ""}  class="btn btn-info" id="submit-button" value="${_('Next Step: ') + _('Choose Topics')} >>">
    </div>
</form>

<%def name="community_list(parent_id, communities, hidden)">
<ul id="list-${parent_id}" class="no-bullet-list-indented  report-community-list ${'NotVisible' if hidden else ''}">
    %for community in communities[parent_id]:
    <li data-cmid="${community.CM_ID}" data-parent="${community.Parent_CM_ID}" data-cmlvl="${community.Lvl}">
        ${renderer.ms_checkbox('CMID', community.CM_ID, label=Markup(_('All of <span class="demi-bold">%s</span>')) % (community.Community,) if communities.get(community.CM_ID) else Markup('<span class="demi-bold">' + community.Community + '</span>'), label_class='control_label')}
        %if communities.get(community.CM_ID):
        ${community_list(community.CM_ID, communities, False)}
        %endif
    </li>
    %endfor
</ul>
</%def>

<%def name="bottomjs()">
<script type="text/javascript">
    jQuery(function ($) {
        var on_check_changed = function(duration) {
            var self = $(this);
            var myid = self.prop('value'), checked = self.prop('checked'), child_list = $('#list-' + myid);

            if (checked) {
                child_list.hide(duration);
            } else {
                child_list.show(duration);
            }

        };

        $(window).on("pageshow", function() {
            $('#parent-list input:checkbox:checked').each(function() {
                    on_check_changed.call(this, 0);
                    $(this).parents('.panel-collapse').collapse('show');
            });
            $('#submit-button').prop('disabled', !$('#parent-list input:checkbox:checked').size());
			if ($('#parent-list input:checkbox:checked').size() == 0) {
				$('#proceed-community-alert').show();
			} else {
				$('#proceed-community-alert').hide();
			}
        });

        $('#parent-list').on('change', 'input', function () {
            on_check_changed.call(this, 'fast');
			$('#submit-button').prop('disabled', !$('#parent-list input:checkbox:checked').size());
			if ($('#parent-list input:checkbox:checked').size() == 0) {
				$('#proceed-community-alert').show();
			} else {
				$('#proceed-community-alert').hide();
			}
        });

		$('#submit-button').prop('disabled', !$('#parent-list input:checkbox:checked').size());
    });
</script>
</%def>
