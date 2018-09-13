import os
import argparse
import shutil
import subprocess

site_root = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))


def parse_args():
	default_site_name = os.path.basename(site_root)
	parser = argparse.ArgumentParser(description='Configure IIS Site for CIO')
	parser.add_argument('domain', default='localhost',
						help='domain to serve traffic from')
	parser.add_argument('--site-name', dest='site_name',
						default=default_site_name,
						help='name of site in IIS')
	parser.add_argument('--port', default=None, help='port for python process to listen on')

	return parser.parse_args()


def make_pythonport_config(args):
	pythonport_config = os.path.join(site_root, 'pythonport.config')
	src = os.path.join(site_root, 'pythonport-sample.config')
	if not os.path.exists(pythonport_config):
		if args.port and args.port != '6543':
			fsrc = open(src)
			fdst = open(pythonport_config, 'w')
			with fsrc, fdst:
				for line in fsrc:
					if 'SetPythonPort' in line:
						line = line.replace('6543', args.port)
					fdst.write(line)
		else:
			shutil.copyfile(src, pythonport_config)


def main():
	args = parse_args()
	make_pythonport_config(args)

	appcmd_exe = os.path.join(os.environ['systemroot'], 'system32/inetsrv/appcmd.exe')

	subprocess.call([
		appcmd_exe, 'add', 'apppool' '/name:' + args.site_name,
		'/managedPipelineMode:Integrated',
		'/commit:MACHINE/WEBROOT/APPHOST'
	])
	subprocess.call([
		appcmd_exe,
		'set', 'apppool', '/apppool.name:' + args.site_name,
		'/enable32BitAppOnWin64:true'
	])
	subprocess.call([
		appcmd_exe,
		'add', 'site', '/name:' + args.site_name,
		'/physicalPath:' + site_root,
		'/bindings:http/*:80:' + args.domain
	])
	subprocess.call([
		appcmd_exe,
		'set', 'site', args.site_name,
		'''/[path='/'].applicationPool:''' + args.site_name
	])

	subprocess.call([
		appcmd_exe, 'set', 'config', args.site_name,
		'-section:system.webServer/asp', '/session.allowSessionState:False',
		'/enableParentPaths:True', '/codePage:65001', '/commit:apphost'
	])
	subprocess.call([
		appcmd_exe, 'set', 'config', args.site_name,
		' -section:system.webServer/security/requestFiltering', '/requestLimits.maxQueryString:8192', '/requestLimits.maxUrl:8192', '/commit:apphost'
	])

	for header in 'HTTP_CIOC_FRIENDLY_RECORD_URL HTTP_CIOC_FRIENDLY_RECORD_URL_ROOT HTTP_X_FORWARDED_PROTO HTTP_CIOC_USING_SSL HTTP_CIOC_SSL_POSSIBLE RESPONSE_LOCATION HTTP_CIOC_SSL_HSTS'.split():
		subprocess.call([
			appcmd_exe, 'set', 'config', args.site_name,
			'-section:system.webServer/rewrite/allowedServerVariables',
			"/+[name='{}']".format(header), "/commit:apphost"
		])

if __name__ == '__main__':
	main()
