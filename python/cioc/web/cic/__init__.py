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
from functools import partial

from cioc.core import constants as const
from cioc.core.rootfactories import BasicRootFactory


def includeme(config):
	urlprefix = '/'

	gbl_factory = factory = partial(BasicRootFactory, domain=const.DM_GLOBAL, db_area=const.DM_CIC)
	config.add_route('cic_basic_search', urlprefix, factory=factory)

	factory = partial(BasicRootFactory, domain=const.DM_CIC, db_area=const.DM_CIC)
	config.add_route('cic_csearch', urlprefix + 'csrch', factory=factory)

	config.add_route('download', urlprefix + 'downloads/{filename}', factory='cioc.web.cic.download.DownloadRootFactory')

	config.add_route('cic_details', urlprefix + r'record/{num:[A-Z]{3}\d{4,5}}', factory=gbl_factory)
	config.add_route(
		'cic_pdf_details', urlprefix + r'record/{num:[A-Z]{3}\d{4,5}}/pdf',
		factory=partial(BasicRootFactory, domain=const.DM_GLOBAL, db_area=const.DM_CIC, force_print_mode=True))

	# /generalheading/*
	factory = partial(BasicRootFactory, domain=const.DM_CIC, db_area=const.DM_CIC)
	config.add_route('cic_generalheading_index', urlprefix + 'generalheading', factory=factory)
	config.add_route('cic_generalheading', urlprefix + 'generalheading/{action}', factory=factory)

	# /publication/*
	factory = partial(BasicRootFactory, domain=const.DM_CIC, db_area=const.DM_CIC)
	config.add_route('cic_publication_index', urlprefix + 'publication', factory=factory)
	config.add_route('cic_publication', urlprefix + 'publication/{action}', factory=factory)

	# /updatepubs/*
	config.add_route('cic_updatepubs', urlprefix + 'updatepubs/{action}', factory=factory)

	# /taxonomy/*
	config.add_route('cic_taxonomy', urlprefix + 'taxonomy/{action}', factory=factory)

	# /topicsearch/*
	config.add_route('cic_topicsearch_index', urlprefix + 'topicsearch', factory=factory)
	config.add_route('cic_topicsearch', urlprefix + 'topicsearch/{tag}', factory=factory)

	config.add_route('reminder_add', urlprefix + 'reminders/add', factory='cioc.web.cic.reminders.ReminderRootFactory')
	config.add_route('reminder_index', urlprefix + 'reminders', factory='cioc.web.cic.reminders.ReminderRootFactory')
	config.add_route('reminder', urlprefix + r'reminders/{id:\d+}', factory='cioc.web.cic.reminders.ReminderRootFactory')
	config.add_route('reminder_action', urlprefix + r'reminders/{action}/{id:\d+}', factory='cioc.web.cic.reminders.ReminderRootFactory')
