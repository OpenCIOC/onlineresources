param (
		[string]$domain='localhost',
		[string]$sitename=$null
)
$mydir = split-path -parent $MyInvocation.MyCommand.Definition
$siteroot =  split-path -parent $mydir
if ($null -eq $sitename){
	$sitename = split-path -Leaf $siteroot
}
Start-Process -File 'C:\Program Files\Git\usr\bin\bash.exe' ('-l', "$mydir\preflight.sh", "--domain", "$domain", "--site-name", "$sitename") -verb RunAs -Wait

