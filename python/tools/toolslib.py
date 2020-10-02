from __future__ import absolute_import
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

