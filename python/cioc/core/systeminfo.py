import sys
import os
import win32api
from markupsafe import Markup


def get_system_version_info():
	pth = os.path.join(os.path.dirname(win32api.__file__), '..')
	pywin32ver = open(os.path.join(pth, "pywin32.version.txt")).read().strip()

	return [
		('Python Version', sys.version),
		('pywin32 Version', pywin32ver),
		('Virtualenv Location', os.environ.get('VIRTUAL_ENV', 'No Virtualenv Used')),
	]


def get_system_version_info_html():
	item_tmpl = Markup('<b>%s</b>: %s')

	return Markup('<br>').join(item_tmpl % x for x in get_system_version_info())
