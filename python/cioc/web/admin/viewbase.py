# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

from __future__ import absolute_import
from formencode import Schema, validators, ForEach, All, schema

from cioc.core import validators as ciocvalidators, constants as const, syslanguage
from cioc.core.viewbase import ViewBase


class AdminViewBase(ViewBase):

	def __init__(self, request, require_login=True):
		ViewBase.__init__(self, request, require_login)


domain_validator = validators.DictConverter(
	{
		str(const.DMT_CIC.id): const.DMT_CIC,
		str(const.DMT_VOL.id): const.DMT_VOL
	}, if_invalid=None, if_empty=None)


ShowCultures = All(validators.Set(use_set=True),
		ForEach(ciocvalidators.ActiveCulture(record_cultures=True)),
		if_invalid=None, if_empty=None)

ShowCulturesOnlyActive = All(validators.Set(use_set=True),
		ForEach(ciocvalidators.ActiveCulture(record_cultures=False)),
		if_invalid=None, if_empty=None)


def cull_extra_cultures(desc_key, multi_key=None, ensure_active_cultures=True, record_cultures=True):
	def inner_cull_extra_cultures(value_dict, state, self):
		cultures = value_dict.get('ShowCultures')
		validator = ShowCultures if record_cultures else ShowCulturesOnlyActive
		try:
			cultures = validator.to_python(cultures) or set()
		except validators.Invalid:
			cultures = set()

		if ensure_active_cultures:
			cultures.update(syslanguage.active_cultures())

		if multi_key:
			items = value_dict.get(multi_key) or []
		else:
			items = [value_dict]

		for item in items:
			descriptions = item.get(desc_key, {})
			for culture in set(c.replace('_', '-') for c in descriptions.keys()) - cultures:
				del descriptions[culture.replace('-', '_')]

	return schema.SimpleFormValidator(inner_cull_extra_cultures)


class ShowCulturesAndDomain(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	DM = domain_validator
	ShowCultures = ShowCultures


class ShowCulturesAndDomainOnlyActive(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	DM = domain_validator
	ShowCultures = ShowCulturesOnlyActive


def get_domain_and_show_cultures(params, ensure_active_cultures=True, record_cultures=True):
	params = params.copy()

	schema = ShowCulturesAndDomain if record_cultures else ShowCulturesAndDomainOnlyActive

	try:
		params = schema.to_python(params)
	except validators.Invalid:
		pass

	shown_cultures = params['ShowCultures'] or set()
	if ensure_active_cultures:
		shown_cultures.update(syslanguage.active_cultures())

	return params['DM'], shown_cultures


def get_domain(params):
	dm = params.get('DM')
	try:
		dm = domain_validator.to_python(dm)
	except validators.Invalid:
		pass

	return dm
