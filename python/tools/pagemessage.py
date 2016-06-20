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

import argparse
import os
import sys

from pyramid.decorator import reify

try:
	import cioc  # NOQA
except ImportError:
	sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from cioc.core import constants as const, request, config

const.update_cache_values()


class ContextBase(object):
	def __init__(self, args):
		self.params = {}
		self.args = args


class Context(request.CiocRequestMixin, ContextBase):
	@reify
	def config(self):
		return config.get_config(self.args.configfile, const._app_name)


def toggle(args, context):
	with context.connmgr.get_connection('admin') as conn:
		for msg_id in args.message_ids:
			sql = '''
			EXEC sp_%(type)s_PageMsg_Toggle ?, ?, ?
			'''
			conn.execute(sql % {'type': args.domain}, args.member_id, msg_id, args.turn_on)


def parse_args(argv):
	parser = argparse.ArgumentParser()
	parser.add_argument('--config', dest='configfile', action='store',
						default=const._config_file)
	parser.add_argument('--on', action='store_true', dest='turn_on')
	parser.add_argument('--off', action='store_false', dest='turn_on')
	parser.add_argument('message_ids', metavar="id", type=int, nargs="+", action='store')
	parser.add_argument('--vol', action='store_const', dest='domain', const='VOL', default='CIC')
	parser.add_argument('--member-id', action='store', type=int, default=None)

	args = parser.parse_args(argv)

	return args


def main(argv):
	args = parse_args(argv)
	context = Context(args)
	toggle(args, context)


if __name__ == '__main__':
	normalstdout = sys.stdout
	normalstderr = sys.stderr
	try:
		sys.exit(main(sys.argv[1:]))
	except Exception:
		sys.stdout = normalstdout
		sys.stderr = normalstderr

		raise
