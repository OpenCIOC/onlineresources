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

from datetime import datetime

from formencode import Schema, Invalid
from pyramid.view import view_config

from Crypto.PublicKey import RSA
from Crypto.Hash import SHA256
from Crypto import Random

import json
from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding

from cioc.core import validators as ciocvalidators, i18n
from cioc.web.cic import viewbase

_ = i18n.gettext


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
			return {'fail': True, 'reason': _('Offline Tools not enabled', request)}

		model_state = request.model_state
		model_state.schema = StartSchema()

		if not model_state.validate():
			return {'fail': True, 'reason': _('invalid request', request)}

		rng = Random.new().read

		token = rng(64)

		challenge = token.encode('base64')

		machine_name = model_state.value('MachineName').encode('utf-8').encode('hex')
		request.cache.set('-'.join(['OfflineKey', machine_name]), (challenge, datetime.now()))

		return {'fail': False, 'challenge': challenge}


def verify_auth(request):
	schema = VerifySchema()

	if not request.dboptions.UseOfflineTools:
		raise AuthFailure({'fail': True, 'reason': _('Offline Tools not enabled', request)})

	try:
		data = schema.to_python(request.POST)
	except Invalid:
		raise AuthFailure({'fail': True, 'reason': _('invalid request', request)})

	machine_name = data['MachineName'].encode('utf-8')
	val = request.cache.get('-'.join(['OfflineKey', machine_name.encode('hex')]))

	if not val:
		raise AuthFailure({'fail': True, 'reason': _('Can\'t find auth request record', request)})

	challenge, time = val
	delta = time - datetime.now()

	if delta.total_seconds() > 900:
		# 15 minutes past, token expired
		raise AuthFailure({'fail': True, 'reason': _('Auth token expired', request)})

	with request.connmgr.get_connection('admin') as conn:
		user_type = conn.execute('EXEC sp_GBL_LoginCheck_Offline ?, ?', request.dboptions.MemberID, machine_name).fetchone()

	if not user_type:
		raise AuthFailure({'fail': True, 'reason': _('not authorized', request)})

	tocheck = ''.join([challenge.decode('base64'), machine_name.encode('utf-8')])
	if data['AuthVersion'] == 2:
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
	else:
		challengedigest = SHA256.new(tocheck).digest()

		key = RSA.importKey(user_type.PublicKey)
		if not key.verify(challengedigest, json.loads(data['ChallengeSig'])):
			raise AuthFailure({'fail': True, 'reason': _('not authorized', request)})

		return user_type
