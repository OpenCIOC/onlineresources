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
import cioc.core.config as config
import os

this_dir = os.path.dirname(__file__)
config_1 = os.path.join(this_dir, 'config.ini')
config_2 = os.path.join(this_dir, 'config2.ini')
def change_config1():
	inf = open(config_1, 'rU')
	data = inf.read()
	inf.close()

	outf = open(config_1, 'w')
	outf.write(data)
	outf.close()

def test_config():
	cnf_mgr = config.ConfigManager(config_1)
	assert cnf_mgr.config_dict['a'] == 'a'

	last_change = cnf_mgr._changed

	cnf_mgr.maybe_reload()
	assert last_change == cnf_mgr._changed

	change_config1()

	cnf_mgr.maybe_reload()
	assert last_change != cnf_mgr._changed


	cnf_mgr.maybe_reload(config_2)

	assert cnf_mgr.config_dict['b'] == 'b'

def test_getconfig():
	cnf = config.get_config(config_1)

	assert cnf['a'] == 'a'

	del config._config.config_dict['a']

	cnf, changed = config.get_config(config_1, True)

	assert 'a' not in cnf
	assert not changed

	cnf = config.get_config(config_1)

	change_config1()

	cnf = config.get_config(config_1)
	assert cnf['a'] == 'a'

	change_config1()

	cnf, changed = config.get_config(config_1, True)
	assert changed

	cnf, changed = config.get_config(config_2, True)
	assert changed
	assert cnf['b'] == 'b'


