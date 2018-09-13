import os
import sys
import subprocess
from urllib import urlretrieve
from tempfile import gettempdir


def main():
	# depends on python2.7 x86 and pywin32 being installed first
	# https://www.python.org/ftp/python/2.7.15/python-2.7.15.msi
	# https://sourceforge.net/projects/pywin32/files/pywin32/Build%20219/pywin32-219.win32-py2.7.exe/download

	#env_root = os.path.join(os.environ['HOMEPATH'], 'Envs')
	#for env_var, value in [
	#	('CIOC_ENV_ROOT', env_root), ('CIOC_MAIL_HOST', 'localhost'),
	#	('CIOC_MAIL_PORT', '1025')
	#]:
	#	subprocess.call(['setx', env_var, value])

	#msis = [
	#	'https://download.microsoft.com/download/5/7/2/57249A3A-19D6-4901-ACCE-80924ABEB267/ENU/x64/msodbcsql.msi',
	#	'http://download.microsoft.com/download/F/E/D/FEDB200F-DE2A-46D8-B661-D019DFE9D470/ENU/x64/sqlncli.msi',
	#	'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x64/sqlncli.msi',
	#	"https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.2.4/wkhtmltox-0.12.2.4_msvc2013-win32.exe",
	#	"http://download.microsoft.com/download/C/F/F/CFF3A0B8-99D4-41A2-AE1A-496C08BEB904/WebPlatformInstaller_amd64_en-US.msi",
	#	'https://github.com/MicrosoftArchive/redis/releases/download/win-3.0.504/Redis-x64-3.0.504.msi',
	#	'https://superb-sea2.dl.sourceforge.net/project/pywin32/pywin32/Build%20219/pywin32-219.win32-py2.7.exe'
	#]
	#tempdir = gettempdir()
	#for installer in msis:
	#	filename = os.path.join(tempdir, os.path.basename(installer))
	#	urlretrieve(installer, filename)
	#	if filename.endswith('.msi'):
	#		subprocess.call(['msiexec', '/i', filename])
	#	else:
	#		subprocess.call([filename])

	#gencache = [['2A75196C-D9EB-4129-B803-931327F72D5C', '0', '2', '8'], ['00000300-0000-0010-8000-00AA006D2EA4', '0', '2', '8'], ['00000600-0000-0010-8000-00AA006D2EA4', '0', '2', '8'], ['B691E011-1797-432E-907A-4D8C69339129', '0', '6', '1'], ['D97A6DA0-A85C-11CF-83AE-00A0C90C2BD8', '0', '3', '0'], ['D97A6DA0-9C1C-11D0-9C3C-00A0C922E764', '0', '3', '0']]
	#for uuid, rev, maj, min in gencache:
	#	subprocess.call([sys.executable, '-c', "from win32com.client import gencache; gencache.EnsureModule('{%(uuid)s}', %(rev)s, %(maj)s, %(min)s)" % {'uuid': uuid, 'rev': rev, 'maj': maj, 'min': min}])

	#subprocess.call([sys.executable, '-m', 'ensurepip'])
	#subprocess.call([sys.executable, '-m', 'pip', 'install', 'virtualenv'])
	#subprocess.call([sys.executable, '-m', 'pip', 'install', 'virtualenvwrapper-win'])
	redis_dir = os.path.join(os.environ['ProgramFiles'], 'redis')
	print "redis_dir", redis_dir

	subprocess.call(
		[
			'"' + os.path.join(redis_dir, 'redis-server.exe') + '"',
		'--service-install', 'redis.windows.conf', '--service-name', 'redis'
		],
		cwd=redis_dir
	)

	features = 'IIS-WebServerRole IIS-WebServer IIS-ISAPIExtensions IIS-ASP IIS-ASPNET45 IIS-HttpCompressionDynamic IIS-Performance Smtpsvc-Service-Update-Name Smtpsvc-Admin-Update-Name IIS-IPSecurity IIS-CGI IIS-ManagementScriptingTools IIS-LegacyScripts IIS-HttpTracing IIS-RequestMonitor'.split()
	features = ['/FeatureName:' + x for x in features]
	subprocess.call(['dism', '/Online', '/EnableFeature'] + features + ['/All'])

	webpi_exe = os.path.join(os.environ['ProgramW6432'], 'Microsoft/Web Platform Installer/WebpiCmd.exe')

	subprocess.call([webpi_exe, '/Install', '/products:ARRv3_0', '/supressreboot', '/accepteula'])
	appcmd_exe = os.path.join(os.environ['systemroot'], 'system32/inetsrv/appcmd.exe')
	subprocess.call([
		appcmd_exe, 'set', 'config', '-section:system.webServer/proxy',
		'/enabled:True', '/includePortInXForwardedFor:False',
		'/preserveHostHeader:True', '/arrResponseHeader:False',
		'/reverseRewriteHostInResponseHeaders:False', '/timeout:"01:00:00"',
		'/commit:apphost'
	])

if __name__ == '__main__':
	main()
