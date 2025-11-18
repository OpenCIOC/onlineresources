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

<table class="BasicBorder cell-padding-3" id="record-table">
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
<tr id="record-${num}" class="record-row" data-record-num="${num}" data-can-edit="${record["CanEdit"]}">
	<td><a href="${request.passvars.makeDetailsLink(num)}" target="_blank">${num}</a></td>
	<td>
		<a class="url-link" target="_blank" href="${(protocol or 'http://') if address else ''}${address}">${(protocol or 'http://') if address else ''}${address}</a>
		<div class="url-edit" style="display:None">
			${renderer.proto_url("url", id="url-" + num, value=((protocol or 'http://') + address) if address else '')}
			<button class="btn url-accept-suggestion" data-suggestion="" style="display:None">${_('Apply Suggestion')}</button>
			<button class="btn btn-primary url-save">${_('Save')}</button>
		</div>
	</td>
	<td id="check-status-${num}" class="check-status${" pending" if address else ""}">${_('Check Pending') if address else _('No Address to Check')}</td>
	<td>
	%if record["CanEdit"]:
	<button class="btn url-toggle-edit">${_('Edit')}</button>
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
			var status_element = $('#check-status-' + result.NUM), 
				seen_result = status_element.data('result')
			if (seen_result) {
				// already 
				continue;
			}
			status_element.data('result', result);
			if (!status_element.hasClass('pending')) {
				continue;
			}

			var status = result.result, row = $('#record-' + result.NUM);
			if (status.startsWith('has_update')) {
				row.find('.url-accept-suggestion').show().data('suggestion', result.final_link);
			}
			var result_holder = $('<div>');
			if (status === 'success') {
				result_holder.addClass('alert alert-success').prop('role', 'alert').append('<span class="glyphicon glyphicon glyphicon-ok-sign" aria-hidden="true"></span>').append($.parseHTML($('<div>').text(' Success.').html()));
			} else if (status === 'has_updated_protocol') {
				result_holder.addClass('alert alert-info').prop('role', 'alert').append('<span class="glyphicon glyphicon glyphicon-info-sign" aria-hidden="true"></span>').append($.parseHTML($('<div>').text(' Protocol needs update:').html())).append($('<div>').append($('<a>').prop({href: result.final_link, target: '_blank'}).css('word-break', 'break-all').text(result.final_link)));
			} else if (status === 'has_update') {
				result_holder.addClass('alert alert-info').prop('role', 'alert').append('<span class="glyphicon glyphicon glyphicon-info-sign" aria-hidden="true"></span>').append($.parseHTML($('<div>').text(' Address redirects, check if an update is needed:').html())).append($('<div>').append($('<a>').prop({href: result.final_link, target: '_blank'}).css('word-break', 'break-all').text(result.final_link)));
			} else {
				result_holder.addClass('alert alert-error').prop('role', 'alert').append('<span class="glyphicon glyphicon glyphicon-remove-sign" aria-hidden="true"></span>').append($.parseHTML($('<div>').text(' Request to address failed.').html())).append($('<div class="well"></div>').text(result.error));
			}
			status_element.empty().append(result_holder).removeClass('pending');
				
		}
	};

	$('#record-table').on('click', '.url-toggle-edit', function(event) {
		event.stopPropagation();
		var self = $(this), row = self.parents('tr').first();
		row.find('.url-edit').show();
	}).on('click', '.url-accept-suggestion', function(event) {
		event.stopPropagation();
		var self = $(this), row = self.parents('tr').first(), num = row.data('recordNum');
		$('#url-' + num).val(self.data('suggestion'));
	}).on('click', '.url-save', function(event) {
		event.stopPropagation();
		var self = $(this), row = self.parents('tr').first(), num = row.data('recordNum'), url = $('#url-' + num).val();
		
		$.ajax({
			dataType: 'json', 
			url: '${request.passvars.route_url('cic_checklinks', action='update')}', 
			method: 'POST',
			data: {
				NUM: num, url: url
			}
		}).done(function(data) {
			if (data.status == 'success') {
				row.find('.url-edit').hide();
				row.find('.url-link').prop('href', url).text(url);

			} else {
				var parent = self.parents('td').first(), edit_errors = $('<div class="error-wrapper"></div>').appendTo(parent); 
				edit_errors.append($('<div class="Alert"></div>').text(data.error));
				if (data.errorlist) {
					edit_errors.append($.parseHTML.append(data.errorlist));
				}
			}
		}).fail(function() {
			// XXX todo
		});
	});

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
