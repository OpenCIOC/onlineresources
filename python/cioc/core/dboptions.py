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


# std lib
import logging
from datetime import datetime

# 3rd party libs
from pyramid.decorator import reify

# this app
from . import constants as const

log = logging.getLogger(__name__)


class DbOptionsDescription(object):
	def __init__(self, dbopts_desc):
		self.dbopts_desc = dbopts_desc

	def __getattr__(self, key):
		try:
			return self.dbopts_desc[key]
		except KeyError:
			raise AttributeError(key)

	def __getnewargs__(self):
		return (self.dbopts_desc,)

	def get(self, key, default=None):
		return self.dbopts_desc.get(key, default)


class DbOptions(object):
	def __init__(self, domain_info, request, force_load, ssl_domains=None):
		self.dbopts = None
		self.domain_info = domain_info
		self.member_id = domain_info['MemberID']
		self._last_modified = None
		self.request = request
		self.load(force_load)
		self.ssl_domains = ssl_domains or None

	@property
	def CanStayInSSL(self):
		try:
			dns_can = self.domain_info.get('FullSSLCompatible', False)

			request = self.request
			DbArea = request.pageinfo.DbArea
			print_mode = request.viewdata.PrintMode
			if DbArea == const.DM_GLOBAL:
				if print_mode and self.DefaultPrintTemplate:
					template_can = self.dbopts['PrintFullSSLCompatible']
				else:
					template_can = self.dbopts['TemplateFullSSLCompatible']
			else:
				vd_dom = request.viewdata.dom
				if print_mode and vd_dom.PrintTemplate:
					template_can = vd_dom.PrintFullSSLCompatible
				else:
					template_can = vd_dom.TemplateFullSSLCompatible
			# log.debug('CanStayInSSL: %s, %s, %s, %s', DbArea, print_mode, template_can, dns_can)
			return template_can and dns_can
		except AttributeError:
			log.exception('********************************* attribute error in CanStayInSSL')
			raise

	@reify
	def DomainDefaultViewSSLCompatibleCIC(self):
		return self.domain_info.get('DefaultViewFullSSLCompatibleCIC', False)

	@reify
	def DomainDefaultViewSSLCompatibleVOL(self):
		return self.domain_info.get('DefaultViewFullSSLCompatibleVOL', False)

	@reify
	def SSLDomains(self):
		if self.request.config.get('ignore_ssl_domains', False):
			return None

		if not self.dbopts['TemplateFullSSLCompatible']:
			return None

		if self.domain_info['DomainName'] in self.ssl_domains:
			return None

		return self.ssl_domains

	def load(self, force=False):
		cache = self.request.cache

		cache_key = 'member_%d' % (self.member_id or 0)

		if force:
			try:
				cache.delete(cache_key)
			except Exception:
				import traceback
				traceback.print_exc()

		data = cache.get_or_create(cache_key, self._get_data)

		self._last_modified, self.dbopts, rows = data
		self.dbopts_lang = {k: DbOptionsDescription(v) for k, v in rows.iteritems()}

	def _get_data(self):
		# log.debug('getting member data')
		connmgr = self.request.connmgr
		with connmgr.get_connection('admin') as conn:
			cursor = conn.execute('''
						DECLARE @RC int, @ErrMsg nvarchar(500)

						EXEC @RC = dbo.sp_STP_Member_sb ?, @ErrMsg OUTPUT

						-- SELECT @RC AS [Return], @ErrMsg AS ErrMsg
						''', self.member_id)

			dbopts = cursor.fetchone()

			if dbopts:
				dbopts = dict(zip([d[0] for d in cursor.description], dbopts))

			cursor.nextset()

			rows = cursor.fetchall()

			rows = {row.Culture: dict(zip([d[0] for d in cursor.description], row)) for row in rows}

			cursor.close()

		return (datetime.now(), dbopts, rows)

	def _invalidate(self):
		cache = self.request.cache

		cache_key = 'member_%d' % self.member_id

		cache.delete(key=cache_key)
		cache.delete(key='domain_map')

	def __getattr__(self, key):
		try:
			return self.dbopts[key]
		except KeyError:
			log.exception('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ key error in dboptions: %s', key)
			raise AttributeError(key)

	def __getitem__(self, key):
		return self.dbopts_lang[key]

	def get_best_lang(self, key):
		culture = self.request.language.Culture

		def sortfn(x):
			return (x.Culture != culture, x.LangID)

		opts = [x for x in self.dbopts_lang.values() if x.get(key)]
		opts.sort(key=sortfn)

		if not opts:
			return None

		return getattr(opts[0], key, None)


def fetch_domain_map(request, reset_db):
	connmgr = request.connmgr

	cache = request.cache

	if reset_db:
		cache.delete('domain_map')

	def get_domain_map_values():
		# log.debug('getting domain map')
		with connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC sp_STP_Member_l_DomainMap')
			domain_map = {x.DomainName.lower(): dict(zip([d[0] for d in cursor.description], x)) for x in cursor.fetchall()}

		return domain_map

	val = cache.get_or_create('domain_map', get_domain_map_values)

	return val


def get_db_options(request):

	# maintain ResetDb so that we can force a reset
	reset_db = request.GET.get('ResetDb', None) == 'True'

	domain_map = fetch_domain_map(request, reset_db)

	# TODO something sensible when host not in map
	host = request.host.lower().rstrip('.').split(':')[0]
	domain_info = domain_map.get(host)
	if not domain_info:
		raise Exception("This domain is not associated with a Member. Maybe a ResetDb=True is required?, %s, %s" % (host, domain_map))

	ssl_domains = [y for y, x in domain_map.items() if x['MemberID'] == domain_info['MemberID'] and x.get('FullSSLCompatible', False)]

	dbopts = DbOptions(domain_info, request, reset_db, ssl_domains)

	return dbopts
