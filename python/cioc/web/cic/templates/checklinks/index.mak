<%doc>
=========================================================================================
 Copyright 2025 KCL Software Solutions Inc.

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

<table class="BasicBorder cell-padding-3">
<thead>
<tr>
	<th>${_('Record Number')}</th>
	<th>${_('Web Address')}</th>
	<th>${_('Status')}</th>
	<th>${_('Action')}</th>
</tr>
<tbody class="alternating-highlight">
%for record in records:
<%
num = record["NUM"]
address = record["WWW_ADDRESS"]
protocol = record["WWW_ADDRESS_PROTOCOL"]
%>
<tr id="record-${num}">
	<td><a href="${request.passvars.makeDetailsLink(num)}">${num}</a></td>
	<td><a href="${(protocol or 'http://') if address else ''}${address}">${(protocol or 'http://') if address else ''}${address}</a></td>
	<td id="check-status-${num}" class="check-status pending">${_('Check Pending') if protocol else _('No Address to Check')}</td>
	<td>
	%if record["CanEdit"]:
	<button class="btn">${_('Edit')}</button>
	%else:
	<span class="Info">${_('Not Editable')}</span>
	%endif
	</td>
</tr>
%endfor
</tbody>
</table>

<%def name="bottomjs()">
<script type="text/javascript">
jQuery(function($) {

	var timeoutID;
	var link_checking_done = false;
	var request_link_status_update = function() {
		if (timeoutID) {
			clearTimeout(timeoutID);
		}
		if (link_checking_done) {
			timeoutID = null;
			return;
		}
		timeoutID = setTimeout(get_updated_link_status, 5000);
	};
	var handle_link_status_updates = function (data) {
		console.log(data);
		for(var result of data.results) {
		   var status_element = $('#check-status-' + result.NUM)
		   status_element.text(result.result)
		   if (result.final_link) {
			status_element.append($('<br>')).append($('<div>').text(result.final_link))
		   }
		   if (result.error) {
			status_element.append($('<br>')).append($('<div>').text(result.error))
		   }
		}
	}

	var get_updated_link_status = function() {
		timeoutID = null;
		$.ajax({
			dataType: "json",
			url: "${request.passvars.route_url('cic_checklinks', action='check')}",
			cache: false,
			data: {
				checkid: "${renderer.value("checkid")}"
			}
		}).done(function(data) {
			if (data.results) {
				handle_link_status_updates(data);
			}
			if (data.done) {
				link_checking_done = true;
			}
		}).always(request_link_status_update);
	};
	get_updated_link_status();
});
</script>
</%def>
