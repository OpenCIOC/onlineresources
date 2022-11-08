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
import json
from markupsafe import escape_silent as h, Markup
%>
<%inherit file="cioc.web:templates/master.mak" />

<%
required_field_marker = Markup('<span class="Alert" title="%s">*</span>') % _('Required')
%>

<span class="AlertBubble">Warning: This Tool is under development and incomplete. Please refer to the documentation to ensure you have a complete and correct shortcode.</span>

<p style="font-weight:bold">[ <a href="${request.passvars.makeLinkAdmin('setup.asp')}">${_('Return to Setup')}</a> | <a href="http://www.opencioc.org/wordpress.php" target="_blank">Wordpress Plugin Documentation</a> ]</p>

<form action="${request.current_route_path()}" method="post" class="form">
	<div class="hidden">
		${request.passvars.cached_form_vals}
	</div>

	<% languages = [(x, culture_map[x].LanguageName) for x in active_cultures] %>
	<table class="BasicBorder cell-padding-4 max-width-md" style="display: none; min-width: 40%;" data-bind="visible: true">
		<tr>
			<th class="RevTitleBox" colspan="2">
				${_('Short Code Generator')}
			</th>
		</tr>
		<tr>
			<td class="FieldLabelLeft min-width-fieldlabel">
				<label for="apikey">${_('Feed API Key')}</label>
				${required_field_marker}
			</td>
			<td>
				%if request.user.SuperUser:
				<select id="apikey" data-bind="options: key_list, optionsText: 'name', value: selectedKey, optionsCaption: '-- ${_('Choose A Key')} --'" class="form-control"></select>
				%else:
				<input type="text" data-bind="textInput: typedKey">
				%endif
			</td>
		</tr>
		<tr data-bind="visible: selectedKey">
			<th class="FieldLabelLeft">${_('Language')}</th>
			<td>${renderer.select('language', [('', '-- %s --' % _('Language'))] + languages, class_="form-control", **{'data-bind': "value: selectedLanguage"})}</td>
		</tr>
		<tr data-bind="visible: selectedKey">
			<th class="FieldLabelLeft">
				${_('Listing Type')}
				${required_field_marker}
			</th>
			<td>
				<div data-bind="visible: keyIsCIC">
					<strong>${_('Community Information')}</strong>
					<br><label for="cic-newest">
						<input id="cic-newest" type="radio" data-bind="checked: listingType, checkedValue: {type: 'newest', name: 'cioccominfo', custfield: true}">
						${_('Newest Records')}
					</label>
					<br><label for="cic-taxonomy">
						<input id="cic-taxonomy" type="radio" data-bind="checked: listingType, checkedValue: {type: 'taxonomy', name: 'cioccominfo', custfield: true, code: true, location: true}">
						${_('Specific Taxonomy Code / Service Category')}
					</label>
					<br><label for="cic-pub">
						<input id="cic-pub" type="radio" data-bind="checked: listingType, checkedValue: {type: 'pub', name: 'cioccominfo', custfield: true, code: true, location: true}">
						${_('Specific Publication')}
					</label>
				</div>
				<div data-bind="visible: keyIsVOL">
					<strong>${_('Volunteer Opportunities')}</strong>
					<br><label for="vol-newest">
						<input id="vol-newest" type="radio" data-bind="checked: listingType, checkedValue: {type: 'newest', name: 'ciocvolunteer', custfield: true}">
						${_('Newest Records')}
					</label>
					<br><label for="vol-popular-orgs">
						<input id="vol-popular-orgs" type="radio" data-bind="checked: listingType, checkedValue: {type: 'popular_orgs', name: 'ciocvolunteer'}">
						${_('Popular Organizations')}
					</label>
					<br><label for="vol-popular-interests">
						<input id="vol-popular-interests" type="radio" data-bind="checked: listingType, checkedValue: {type: 'popular_interests', name: 'ciocvolunteer'}">
						${_('Popular Categories')}
					</label>
					<br><label for="vol-org">
						<input id="vol-org" type="radio" data-bind="checked: listingType, checkedValue: {type: 'org', name: 'ciocvolunteer', custfield: true, num: true}">
						${_('Specific Organization')}
					</label>
					<br><label for="vol-interest">
						<input id="vol-interest" type="radio" data-bind="checked: listingType, checkedValue: {type: 'interest', name: 'ciocvolunteer', custfield: true, code: true}">
						${_('Specific Category')}
					</label>
				</div>
			</td>
		</tr>
		<tr data-bind="visible: selectedKey() &amp;&amp; listingType()">
			<th class="FieldLabelLeft">
				${_('Domain Name')}
				${required_field_marker}
			</th>
			<td>
				<select data-bind="options: domainNames, value: selectedDomainName, optionsText: 'name', optionsCaption: '-- ${_('Choose a Domain')} --'" class="form-control"></select>
			</td>
		</tr>
		<tr data-bind="visible: canHaveCustomField">
			<th class="FieldLabelLeft">${_('Fields')}</th>
			<td>
				<div data-bind="visible: listingIsCIC">
					<div class="checkbox">
						<label for="cic-field-desc">
							<input id="cic-field-desc" type="checkbox" data-bind="checkedValue: {value: 'description', cic: true}, checked: includeFieldList">
							${_('Shortened Description')}
						</label>
					</div>
					<div class="checkbox">
						<label for="cic-field-address">
							<input id="cic-field-address" type="checkbox" data-bind="checkedValue: {value: 'address', cic: true}, checked: includeFieldList">
							${_('Site Address (or Community name, if no Site Address)')}
						</label>
					</div>
					<div class="checkbox">
						<label for="cic-field-phone">
							<input id="cic-field-phone" type="checkbox" data-bind="checkedValue: {value: 'office_phone', cic: true}, checked: includeFieldList">
							${_('Office Phone')}
						</label>
					</div>
					<div class="checkbox">
						<label for="cic-field-email">
							<input id="cic-field-email" type="checkbox" data-bind="checkedValue: {value: 'email', cic: true}, checked: includeFieldList">
							${_('Email')}
						</label>
					</div>
					<div class="checkbox">
						<label for="cic-field-web">
							<input id="cic-field-web" type="checkbox" data-bind="checkedValue: {value: 'web', cic: true}, checked: includeFieldList">
							${_('Website')}
						</label>
					</div>
					<div class="checkbox">
						<label for="cic-field-hours">
							<input id="cic-field-hours" type="checkbox" data-bind="checkedValue: {value: 'hours', cic: true}, checked: includeFieldList">
							${_('Hours of Operation')}
						</label>
					</div>
				</div>
				<div data-bind="visible: listingIsVOL">
					<label for="vol-field-org">
						<input id="vol-field-org" type="checkbox" data-bind="checkedValue: {value: 'org', vol: true}, checked: excludeFieldList">
						${_('Organization Name')}
					</label>
					<br><label for="vol-field-location">
						<input id="vol-field-location" type="checkbox" data-bind="checkedValue: {value: 'location', vol: true}, checked: includeFieldList">
						${_('Location')}
					</label>
					<br><label for="vol-field-duties">
						<input id="vol-field-duties" type="checkbox" data-bind="checkedValue: {value: 'duties', vol: true}, checked: includeFieldList">
						${_('Duties')}
					</label>
				</div>
			</td>
		</tr>
		<tr data-bind="visible: needCode">
			<th class="FieldLabelLeft">
				<label for="code">
					${_('Code')}
					${required_field_marker}
				</label>
			</th>
			<td>
				<input type="text" maxlength="20" id="code" class="form-control" data-bind="textInput: code">
			</td>
		</tr>
		<tr data-bind="visible: canHaveCommunity">
			<th class="FieldLabelLeft">
				<label for="location">${_('Community')}</label>
			</th>
			<td>
				<div data-bind="visible: listingIsCIC">
					<label for="community-location" class="radio-inline">
						<input id="community-location" type="radio" data-bind="checked: communityType, checkedValue: 'location'">
						${_('Location')}
					</label>
					<label for="community-servicearea" class="radio-inline">
						<input id="community-servicearea" type="radio" data-bind="checked: communityType, checkedValue: 'servicearea'">
						${_('Service Area')}
					</label>
				</div>
				<input type="text" maxlength="220" id="location" class="form-control" data-bind="textInput: community">
			</td>
		</tr>
		<tr data-bind="visible: needNUM">
			<th class="FieldLabelLeft">
				<label for="num">
					${_('Organization Record #')}
					${required_field_marker}
				</label>
			</th>
			<td>
				<input type="text" maxlength="220" id="num" class="form-control" data-bind="textInput: num">
			</td>
		</tr>
		<tr data-bind="visible: selectedKey()">
			<th class="FieldLabelLeft">${_('Style')}</th>
			<td>
				<label for="style-me">
					<input id="style-me" type="checkbox" data-bind="checked: styleMe">
					${_('Use suggested list styles')}
				</label>
				<hr>
				<div class="form-group form-horizontal">
					<label for="list_id" class="control-label col-sm-3">${_('List ID')}</label>
					<div class="col-sm-9">
						<input type="text" maxlength="50" id="list_id" class="form-control" data-bind="textInput: listID">
					</div>
				</div>
				<div class="form-group form-horizontal">
					<label for="list_class" class="control-label col-sm-3">${_('List Class')}</label>
					<div class="col-sm-9">
						<input type="text" maxlength="50" id="list_class" class="form-control" data-bind="textInput: listClass">
					</div>
				</div>
			</td>
		</tr>
		<tr data-bind="visible: selectedKey()">
			<th class="FieldLabelLeft">${_('Icons')}</th>
			<td>
				<label for="has-fa">
					<input id="has-fa" type="checkbox" data-bind="checked: fontAwesome">
					${_('Enable FontAwesome icons')}
				</label>
			</td>
		</tr>
		<tr data-bind="visible: shortCode">
			<th class="FieldLabelLeft">
				${_('Generated Short Code')}
			</th>
			<td data-bind="text: shortCode" class="HighLight"></td>
		</tr>
	</table>
</form>

<%def name="bottomjs()">
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/knockout/3.4.0/knockout-min.js"></script>
<script type="text/javascript">
	// Here's my data model
	var ViewModel = function (key_list, cic_domains, vol_domains) {
		var self = this;
		self.selectedKey = ko.observable()
		if (key_list !== null) {
			self.key_list = ko.observableArray(key_list);
		} else {
			self.key_list = ko.observable(key_list);
			self.typedKey = ko.observable();
			ko.computed(function () {
				var key = self.typedKey();
				var re = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
				if (re.test(key)) {
					$.ajax({ dataType: 'json', url: '', method: 'post', data: { 'feed_key': key }, success: self.selectedKey });
				}
			});
		}
		self.selectedLanguage = ko.observable('');
		self.listingType = ko.observable();
		self.selectedDomainName = ko.observable();
		self.includeFieldList = ko.observableArray();
		self.excludeFieldList = ko.observableArray();
		self.styleMe = ko.observable(true);
		self.listID = ko.observable('');
		self.listClass = ko.observable('');
		self.fontAwesome = ko.observable();
		self.code = ko.observable('');
		self.communityType = ko.observable('location');
		self.community = ko.observable('');
		self.num = ko.observable('');

		self.keyIsCIC = ko.computed(function () {
			var key = self.selectedKey();
			return key && key.cic;
		});
		self.keyIsVOL = ko.computed(function () {
			var key = self.selectedKey();
			return key && key.vol;
		});

		self.listingIsCIC = ko.computed(function () {
			var listing = self.listingType(), key = self.selectedKey();
			if (!listing || !key) {
				return false;
			}

			if (listing.name === 'cioccominfo' && key.cic) {
				return true;
			}
			return false;
		});

		self.listingIsVOL = ko.computed(function () {
			var listing = self.listingType(), key = self.selectedKey();
			if (!listing || !key) {
				return false;
			}
			if (listing.name === 'ciocvolunteer' && key.vol) {
				return true;
			}
			return false;
		});

		self.canHaveCustomField = ko.computed(function () {
			var listing = self.listingType(), key = self.selectedKey();
			return listing && listing.custfield && key;
		});

		self.needCode = ko.computed(function () {
			var listing = self.listingType(), key = self.selectedKey();
			return listing && listing.code && key;
		});

		self.needNUM = ko.computed(function () {
			var listing = self.listingType(), key = self.selectedKey();
			return listing && listing.num && key;
		});

		self.canHaveCommunity = ko.computed(function () {
			var listing = self.listingType(), key = self.selectedKey();
			return listing && listing.location && key;
		});

		self.domainNames = ko.computed(function () {
			if (self.listingIsCIC()) {
				return cic_domains;
			} else if (self.listingIsVOL()) {
				return vol_domains;
			}

			return [];

		});
		self.shortCode = ko.computed(function () {
			var listing = self.listingType(), key = self.selectedKey(),
				language = self.selectedLanguage(), style_me = self.styleMe(), list_id = self.listID(), list_class = self.listClass(),
				domain = self.selectedDomainName(), include = self.includeFieldList(),
				exclude = self.excludeFieldList(), font_awesome = self.fontAwesome(),
				num = self.num(), needNUM = self.needNUM(), code = self.code(), needCode = self.needCode()
			canHaveCommunity = self.canHaveCommunity(), community = self.community(), communityType = self.communityType();

			if (!listing || !key || !domain || (needCode && !code) || (needNUM && !num)) {
				return '';
			}

			var args = { url: domain.url, key: key.key, type: listing.type };
			if (language) {
				args.ln = language;
			}

			if (domain.viewtype) {
				args.viewtype = domain.viewtype;
			}
			var iscic = listing.name === 'cioccominfo';
			var isvol = listing.name === 'ciocvolunteer';

			if (listing.custfield) {
				$.each(include, function (idx, field) {
					if ((iscic && field.cic) || (isvol && field.vol)) {
						args[field.value] = 'on';
					}
				});
				var possible_excludes = [];
				if (isvol) {
					possible_excludes = ['org'];
				}
				$.each(exclude, function (idx, field) {
					if ((iscic && field.cic) || (isvol && field.vol)) {
						var i = possible_excludes.indexOf(field.value);
						if (i > -1) {
							possible_excludes.splice(i, 1);
						}
					}
				});
				$.each(possible_excludes, function (idx, field) {
					args[field] = 'off';
				});
			}

			if (style_me) {
				args.style_me = 'on';
			}

			if (list_id) {
				args.list_id = list_id;
			}

			if (list_class) {
				args.list_class = list_class;
			}

			if (font_awesome) {
				args.has_fa = 'on';
			}

			if (needNUM) {
				args.num = num;
			}

			if (needCode) {
				args.code = code;
			}

			if (canHaveCommunity && community) {
				args[communityType || 'location'] = community;
			}

			args = $.map(args, function (val, key) { return key + '="' + val + '"'; });

			return '[' + listing.name + ' ' + args.join(' ') + ']'
		});

		ko.computed(function () {
			//console.log(self.selectedKey(), self.selectedLanguage(), self.listingType(), self.selectedDomainName());
		});

	};
	ko.options.deferUpdates = true;
	ko.applyBindings(new ViewModel(${ json.dumps(keys) | n }, ${ json.dumps(cic_domains) | n }, ${ json.dumps(vol_domains) | n })); // This makes Knockout get to work
</script>

</%def>
