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
<%def name="headerextra()">
<style type="text/css">
	.SLList { 
		list-style: none; 
		padding: 0;
		margin: 0;
		min-height: 2em;
	}
	.SLList li {
		margin: 0 0 5px 0;
		padding: 5px;
		/* font-size: 1.2em;
		width: 120px;*/
	}

	#OfflineMachines {
		float: left;
		margin: 2em;
	}
	#UserTypes {
		float: right;
		margin: 2em;
	}
	
	#UserTypes ul {
		cursor: move;
	}

	.inline-icon {
		display: inline-block;
		border: none;
		cursor: pointer;
	}
	.selected-sl-actions {
		float: right;
		margin-left: 0.5em;
		margin-right: 0.25em;
	}
</style>
</%def>

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> ]</p>

%if not machines:
<p class="Info">${_('No Offline Machines found.')}</p>
%else:
<div style="float: left;">
<div id="UserTypes" class="clearfix">
	<h3>${_('User Types')}</h3>
	<ul class="SLList">
	%for security_level in security_levels:
		%if security_level.CAN_ADD:
		<li data-slid="${security_level.SL_ID}" class="ui-state-highlight">${security_level.SecurityLevel}</li>
		%endif
	%endfor
	</ul>
</div>
<div id="OfflineMachines">
<form action="${request.current_route_path()}" method="post">
${request.passvars.getHTTPVals(bForm=True)}

<% machine_data = data['machine'] %>
%for i,(machine,machine_state) in enumerate(zip(machines, machine_data)):
<div class="OfflineMachine clearfix">
	<h3>${machine.MachineName}</h3>
	<% prefix = 'machine-%d.' % i %>
	<% slids = machine_state['SecurityLevels'] %>
	${renderer.hidden(prefix + 'MachineID')}
	<% name = '%sSecurityLevels-%%d' % prefix %>
	<ul class="MachineSLTarget SLList" data-counts="{&quot;machine&quot;: ${i}, &quot;sl&quot;: ${9999}}">
	%for j,slid in enumerate(slids):
		<% sl = security_level_map.get(int(slid)) %>
		%if sl:
			${SelectedSecurityLevel(renderer, i,j,sl)}
		%endif
	%endfor
	</ul>
</div>
%endfor

<input type="submit" value="${_('Submit')}">
</form>
</div>

</div>
%endif

<%def name="SelectedSecurityLevel(renderer, machine_count, sl_count, sl_name, slid=None)">
	<li class="ui-state-default"><span class="selected-sl-actions"><span class="ui-state-default ui-icon ui-icon-circle-close selected-sl-remove inline-icon" title=${_('Remove')}>${_('Remove')}</span></span>${renderer.hidden('machine-%s.SecurityLevels-%s' % (machine_count,sl_count), slid)}${sl_name}</li>
</%def>
<%def name="bottomjs()">
%if machines:
<script type="text/html" id="selected_item_template">
${SelectedSecurityLevel(renderer, '[MACHINE_COUNT]', '[SL_COUNT]', '[SL_NAME]', '[SL_ID]')}
</script>
<script type="text/javascript">
jQuery(function($) {
	$('#UserTypes li').draggable({helper: 'clone'});
	$('.MachineSLTarget').droppable({
			accept: function(el) {
				var slid=el.data('slid'), selector = 'input[value="' + slid + '"]';
				//console.log(this)
				if ($(this).find(selector).length == 0) {
					return true;
				}
			},
			hoverClass: "ui-state-hover",
			drop: function( event, ui ) {
			/*
				var $item = $( this );
				var $list = $( $item.find( "a" ).attr( "href" ) )
					.find( ".connectedSortable" );

				ui.draggable.hide( "slow", function() {
					$tabs.tabs( "select", $tab_items.index( $item ) );
					$( this ).appendTo( $list ).show( "slow" );
				});
				*/
			var self = $(this), tmpl=$('#selected_item_template')[0].innerHTML, 
				counts=self.data('counts'),
				rendered = $(tmpl.replace(/\[MACHINE_COUNT\]/g, counts.machine).
								replace(/\[SL_COUNT\]/g, counts.sl).
								replace(/\[SL_NAME\]/g, ui.draggable.text()).
								replace(/\[SL_ID\]/g, ui.draggable.data('slid')));


			rendered.hide().appendTo(self).show('slow');
			counts.sl++;

			}
		});

	$('.selected-sl-remove').live('click', function() {
		$(this).parent().parent().hide('slow', function() { $(this).remove(); });
	});
});
</script>
%endif
</%def>
