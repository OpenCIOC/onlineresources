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



# ######
# How Auth Works:
# Initially user logs in using username and password to provide public RSA key.
#
# At update time, the site POSTs to /offline/auth with LoginName=username The
# CIOC site provides a challenge which it stores in memcache associated with
# the user's name (along with a timestamp). (note, username is not checked
# here, since we don't have enough information to know this is really the
# user's agent.
#
# On subsequent operations (pull) the client provides
# LoginName=useraname&ChallengeSig=signedchallenge, the challenge expires after
# 15 minutes and a new challenge would be required for subsequent actions.
# #######
from functools import partial

from cioc.core import constants as const
from cioc.core.rootfactories import AllowSSLRootFactory


def includeme(config):
	urlprefix = '/offline/'

	factory = partial(AllowSSLRootFactory, domain=const.DM_CIC, db_area=const.DM_CIC)

	# /offline/auth
	config.add_route('offline_auth', urlprefix + 'auth', factory=factory)

	# /offline/pull
	config.add_route('offline_pull', urlprefix + 'pull', factory=factory)

	# /offline/pull2
	config.add_route('offline_pull2', urlprefix + 'pull2', factory=factory)

	# /offline/register
	config.add_route('offline_register', urlprefix + 'register', factory=factory)
