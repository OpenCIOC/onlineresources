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

import os
import json


def main(files):
	version_dict = {}
	for file in files:
		st = os.stat(file)
		if file.startswith('../'):
			file = file[3:]
		else:
			file = 'scripts/' + file

		version_dict[file] = str(int(st.st_mtime))

	print json.dumps(version_dict, sort_keys=True, indent=4)

if __name__ == '__main__':
	import sys
	main(sys.argv[1:])
