
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
import csv

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


def export(args, conn, filename, sql):
	with open(os.path.join(args.destdir, filename), 'wb') as fd:
		with conn.execute(sql) as cursor:
			writer = csv.writer(fd)
			writer.writerow([d[0] for d in cursor.description])
			while True:
				rows = cursor.fetchmany(10000)
				if not rows:
					break

				writer.writerows(tuple(x) for x in rows)


def export_distributions(args, conn):
	export(
		args, conn, 'distributions.csv',
		'''
		SELECT pr.NUM, dst.DistCode
		FROM CIC_Distribution AS dst
		INNER JOIN CIC_BT_DST AS pr ON dst.DST_ID = pr.DST_ID
		INNER JOIN dbo.CIC_BT_EXTRA_TEXT et ON et.NUM=pr.NUM AND et.FieldName='EXTRA_ICAROLFILECOUNT'
		'''
	)


def export_headings(args, conn):
	export(
		args, conn, 'headings.csv',
		'''
		SELECT pbr.NUM, pb.PubCode, CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END AS HeadingName
FROM CIC_Publication AS pb
INNER JOIN CIC_BT_PB AS pbr ON pb.PB_ID = pbr.PB_ID
INNER JOIN CIC_BT_PB_GH AS ghr ON pbr.BT_PB_ID = ghr.BT_PB_ID
INNER JOIN CIC_GeneralHeading AS gh ON gh.GH_ID = ghr.GH_ID
INNER JOIN CIC_GeneralHeading_Name AS ghn ON gh.GH_ID = ghn.GH_ID AND ghn.LangID=0
INNER JOIN dbo.CIC_BT_EXTRA_TEXT et ON et.NUM=pbr.NUM AND et.FieldName='EXTRA_ICAROLFILECOUNT'
		'''
	)


def export_publications(args, conn):
	export(
		args, conn, 'publications.csv',
		'''
		SELECT pbr.NUM, pb.PubCode, pbn.Name
		FROM CIC_Publication AS pb
		INNER JOIN CIC_BT_PB AS pbr ON pb.PB_ID = pbr.PB_ID
		LEFT JOIN CIC_Publication_Name AS pbn ON pb.PB_ID = pbn.PB_ID AND pbn.LangID=0
		INNER JOIN dbo.CIC_BT_EXTRA_TEXT et ON et.NUM=pbr.NUM AND et.FieldName='EXTRA_ICAROLFILECOUNT'
		'''
	)


def export_all(args, context):
	with context.connmgr.get_connection('admin') as conn:
		export_distributions(args, conn)
		export_headings(args, conn)
		export_publications(args, conn)


def parse_args(argv):
	parser = argparse.ArgumentParser()
	parser.add_argument('--config', dest='configfile', action='store',
						default=const._config_file)
	parser.add_argument('destdir', metavar="destdir", action='store')

	args = parser.parse_args(argv)

	return args


def main(argv):
	args = parse_args(argv)
	context = Context(args)
	export_all(args, context)


if __name__ == '__main__':
	normalstdout = sys.stdout
	normalstderr = sys.stderr
	try:
		sys.exit(main(sys.argv[1:]))
	except Exception:
		sys.stdout = normalstdout
		sys.stderr = normalstderr

		raise
