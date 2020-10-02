from __future__ import absolute_import
from __future__ import print_function
import argparse
import hashlib
import os
import sys
import traceback

import boto
import boto.s3

import sass

try:
	import cioc  # NOQA
except ImportError:
	sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from cioc.core import constants as const, config

const.update_cache_values()
files = [
	('fontello.eot', 'application/x-font-opentype'),
	('fontello.svg', 'image/svg+xml'),
	('fontello.ttf', 'application/x-font-ttf'),
	('fontello.woff', 'application/font-woff'),
	('fontello.woff2', 'application/font-woff2'),
]

bootstrap_files = [
	('glyphicons-halflings-regular.eot', 'application/x-font-opentype'),
	('glyphicons-halflings-regular.svg', 'image/svg+xml'),
	('glyphicons-halflings-regular.ttf', 'application/x-font-ttf'),
	('glyphicons-halflings-regular.woff', 'application/font-woff'),
	('glyphicons-halflings-regular.woff2', 'application/font-woff2'),
]


class DEFAULT(object):
	pass


def get_config_item(args, key, default=DEFAULT):
	if default is DEFAULT:
		return args.config[key]

	return args.config.get(key, default)


def parse_args(argv):
	parser = argparse.ArgumentParser()
	parser.add_argument('--config', dest='configfile', action='store',
						default=const._config_file)

	args = parser.parse_args(argv)

	return args


def upload_file(bucket, location, filename, mime_type, content=None, filebase=None):
	print('Uploading %s ' % (filename,), end=' ')

	def percent_cb(complete, total):
		sys.stdout.write('.')
		sys.stdout.flush()

	k = bucket.new_key(location + filename)
	k.content_type = mime_type
	if content:
		k.set_contents_from_string(content, policy='public-read')
	else:
		k.set_contents_from_filename(os.path.join(filebase, filename), cb=percent_cb, num_cb=10, policy='public-read')

	print()


def gethash():
	h = hashlib.sha256()
	for fname, mime_type in files:
		with open(os.path.join(const._app_path, 'fonts', fname)) as f:
			h.update(f.read())

	return h.hexdigest()[:15]


def main(argv):
	args = parse_args(argv)
	try:
		args.config = config.get_config(args.configfile, const._app_name)
	except Exception:
		sys.stderr.write('ERROR: Could not process config file:\n')
		sys.stderr.write(traceback.format_exc())
		return 1

	# AWS ACCESS DETAILS
	AWS_ACCESS_KEY_ID = get_config_item(args, 'aws_access_key_id')
	AWS_SECRET_ACCESS_KEY = get_config_item(args, 'aws_secret_access_key')

	bucket_name = get_config_item(args, 'bucket_name', 'cioc-cdn')
	conn = boto.connect_s3(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
	bucket = conn.get_bucket(bucket_name)
	location = 'fontello/' + gethash() + '/'

	print('Uploading to Amazon S3 path', location)
	filebase = os.path.join(const._app_path, 'fonts')

	for filename, mime_type in files:
		upload_file(bucket, location, filename, mime_type, filebase=filebase)

	top = open(os.path.join(const._app_path, 'fonts', 'fontello.css')).read().split('}', 1)[0] + '}'
	bottom = open(os.path.join(const._app_path, 'styles', 'sass', '_fontello.scss')).read().split('}', 1)[1]

	css = sass.compile(string=top + bottom, output_style='compressed')
	upload_file(bucket, location, 'fontello.css', 'text/css', css)

	scss = '''
	$bootstrap-sass-asset-helper: false;
	$icon-font-path: "./";
	$icon-font-name:          "glyphicons-halflings-regular" !default;
	$icon-font-svg-id:        "glyphicons_halflingsregular" !default;
	@import "bootstrap/glyphicons";
	'''
	location = 'bootstrap-3.3.5/'
	filebase = os.path.join(const._app_path, 'fonts', 'bootstrap')

	print('Uploading to Amazon S3 path', location)
	for filename, mime_type in bootstrap_files:
		upload_file(bucket, location, filename, mime_type, filebase=filebase)

	css = sass.compile(string=scss, include_paths=[const._sass_dir], output_style='compressed')
	upload_file(bucket, location, 'glyphicons.css', 'text/css', css)

	return 0

if __name__ == '__main__':
	sys.exit(main(sys.argv[1:]))
