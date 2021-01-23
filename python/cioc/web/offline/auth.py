# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#	   http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

from __future__ import absolute_import
from datetime import datetime
import logging

import os
import base64
import binascii

import isodate
from formencode import Schema, Invalid
from pyramid.view import view_config

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding

from cioc.core import validators as ciocvalidators, i18n
from cioc.web.cic import viewbase

_ = i18n.gettext
log = logging.getLogger(__name__)


def get_nonce():
	return base64.b64encode(os.urandom(64)).decode('ascii')


def decode_base64_nonce(nonce):
	return base64.b64decode(nonce.encode('ascii'))


def encode_machine_name(machine_name):
	return binascii.hexlify(machine_name.encode('utf-8')).decode('ascii')


class StartSchema(Schema):
	MachineName = ciocvalidators.UnicodeString(max=255, not_empty=True)


class VerifySchema(StartSchema):
	allow_extra_fields = True
	filter_extra_fields = True

	ChallengeSig = ciocvalidators.String(not_empty=True)
	AuthVersion = ciocvalidators.Int(max=2, not_empty=False)


class AuthFailure(Exception):
	def __init__(self, result_info):
		self.result_info = result_info


@view_config(route_name='offline_auth', renderer='json')
class Auth(viewbase.CicViewBase):
	def __call__(self):
		request = self.request
		if not request.dboptions.UseOfflineTools:
			log.debug('Offline tools not enabled')
			return {'fail': True, 'reason': _('Offline Tools not enabled', request)}

		model_state = request.model_state
		model_state.schema = StartSchema()

		if not model_state.validate():
			log.debug('invalid request')
			return {'fail': True, 'reason': _('invalid request', request)}

		challenge = get_nonce()

		machine_name = encode_machine_name(model_state.value('MachineName'))
		request.cache.set('-'.join(['OfflineKey', machine_name]), (challenge, datetime.now().isoformat()))

		log.debug('challenge sent')
		return {'fail': False, 'challenge': challenge}


def verify_auth(request):
	schema = VerifySchema()

	if not request.dboptions.UseOfflineTools:
		log.debug('Verify Offline tools not enabled')
		raise AuthFailure({'fail': True, 'reason': _('Offline Tools not enabled', request)})

	try:
		data = schema.to_python(request.POST)
	except Invalid:
		log.debug('verify invalid request')
		raise AuthFailure({'fail': True, 'reason': _('invalid request', request)})

	machine_name = data['MachineName']
	cache_key = '-'.join(['OfflineKey', encode_machine_name(machine_name)])
	val = request.cache.get(cache_key)

	if not val:
		log.debug('verify cant find request record')
		raise AuthFailure({'fail': True, 'reason': _('Can\'t find auth request record', request)})

	challenge, time = val
	delta = isodate.parse_datetime(time) - datetime.now()

	if delta.total_seconds() > 900:
		# 15 minutes past, token expired
		request.cache.delete(cache_key)
		log.debug('expired request')
		raise AuthFailure({'fail': True, 'reason': _('Auth token expired', request)})

	with request.connmgr.get_connection('admin') as conn:
		user_type = conn.execute('EXEC sp_GBL_LoginCheck_Offline ?, ?', request.dboptions.MemberID, machine_name).fetchone()

	if not user_type:
		request.cache.delete(cache_key)
		log.debug('not authorized user "%s"', machine_name)
		raise AuthFailure({'fail': True, 'reason': _('not authorized', request)})

	tocheck = b''.join([decode_base64_nonce(challenge), machine_name.encode('utf-8')])
	public_key = serialization.load_pem_public_key(
		user_type.PublicKey.encode('ascii'),
	)
	try:
		public_key.verify(
			base64.b64decode(data['ChallengeSig']), tocheck,
			padding.PSS(
				mgf=padding.MGF1(hashes.SHA256()),
				salt_length=padding.PSS.MAX_LENGTH
			),
			hashes.SHA256()
		)
	except InvalidSignature:
		request.cache.delete(cache_key)
		log.debug('sig failure')
		raise AuthFailure({'fail': True, 'reason': _('not authorized', request)})

	return user_type
