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


# stdlib
import os
import textwrap

# 3rd party
from markupsafe import Markup, escape_silent
from marrow.mailer import Mailer, Message
from marrow.mailer.exc import DeliveryException

DeliveryException

# this app
from cioc.core.i18n import gettext as _

_mailer = None


def _get_mailer():
	global _mailer

	if not _mailer:
		transport = {
			'use': 'smtp',
			'host': os.environ.get('CIOC_MAIL_HOST', '127.0.0.1'),
			'username': os.environ.get('CIOC_MAIL_USERNAME'),
			'password': os.environ.get('CIOC_MAIL_PASSWORD'),
			'port': os.environ.get('CIOC_MAIL_PORT'),
			'tls': 'ssl' if os.environ.get('CIOC_MAIL_USE_SSL') else None,
		}
		# print transport['host']
		transport = {k: v for k, v in transport.iteritems() if v}
		_mailer = Mailer({
			'transport': transport,
			'manager': {'use': 'immediate'}
		})
		_mailer.start()

	return _mailer


def send_email(request, author, to, subject, message, reply=None, ignore_block=False):

	if not isinstance(to, (list, tuple, set)):
		to = [x.strip() for x in to.split(',')]

	to = [unicode(x) for x in to if x]
	TrainingMode = request.dboptions.TrainingMode
	NoEmail = request.dboptions.NoEmail
	if TrainingMode:
		# XXX Fill message
		request.email_notice(
			Markup(
				'''
				<p>Sending Email...<br><br>
				<strong>From:</strong> %s<br><br>
				<strong>To:</strong> %s<br><br>
				<strong>Reply-To:</strong> %s<br><br>
				<strong>Subject:</strong> %s<br><br>
				<strong>Message:</strong><br>%s</p>'''
			) % (
				author, ', '.join(to), reply or '',
				subject,
				escape_silent(message).replace('\n', Markup('<br>')).replace('\r', '')))

	elif not ignore_block and NoEmail:
		# XXX Fill message
		request.email_notice(_('This database has been configured to block all outgoing Email.', request))

	if (not TrainingMode or ignore_block) and (not NoEmail or ignore_block) and to and author:
		mailer = _get_mailer()
		args = dict(author=[unicode(author)], to=to, subject=subject, plain=message)
		if reply:
			args['reply'] = [unicode(reply)]
		message = Message(**args)
		mailer.send(message)


def format_message(message):
	return '\n\n'.join(textwrap.fill(x, width=80) for x in message.split('\n\n'))
