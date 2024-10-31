function DeleteLeftoverFiles
{	
	Param (
		[string]$old_folder_path
	)
	
	# Delete existing installation folder
	if (Test-Path $old_folder_path) {
		Write-Output "Óäàëåíèå óñòàðåâøèõ ôàéëîâ Winws"
		[void](Remove-Item $old_folder_path -Recurse -Confirm:$False -Force)
	}
}

# Set title and advertisement
$host.ui.RawUI.WindowTitle = "D.F.E"
Write-Host "Çàãðóç÷èê è èíñòàëëÿòîð ñåðâèñà Winws " -ForegroundColor white -nonewline
Write-Host "282" -ForegroundColor yellow
Write-Host "ÐÓÑÑÊÈÉ ËÅÑ" -ForegroundColor yellow -BackgroundColor darkred
Write-Host ""

# Disable warnings and errors output
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
function global:Write-Host() {}

# Do not prompt for confirmations
Set-Variable -Name 'ConfirmPreference' -Value 'None' -Scope Global

[void]([System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms"))

# Determining Windows architecture
$os_type = (Get-WmiObject -Class Win32_ComputerSystem).SystemType -match ‘(x64)’

$result = [System.Windows.Forms.MessageBox]::Show('Âíèìàíèå!' + [System.Environment]::NewLine + [System.Environment]::NewLine + "Âûêëþ÷èòå VPN/òóííåëü/ïðî÷èå ïðèáëóäû ïåðåä óñòàíîâêîé ñêðèïòà", "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

# Checking if Winws is already installed. Ask to uninstall. If not accepted, exit script.
Write-Output "Ïðîâåðêà íàëè÷èÿ GoodbyeDPI"
$goodbyedpi = Get-Process goodbyedpi

if ($goodbyedpi) {
	$result = [System.Windows.Forms.MessageBox]::Show('Íàéäåí ðàáîòàþùèé GoodbyeDPI.' + [System.Environment]::NewLine + [System.Environment]::NewLine + "Âûêëþ÷èòå GoodbyeDPI, òàê êàê îí êîíôëèêòóåò ñ Winws. Ñåé÷àñ îí áóäåò ïðèíóäèòåëüíî âûêëþ÷åí.", "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
	[void]($goodbyedpi | Stop-Process -Force)
}

# Finding Winws folder
$winws_folder = "DFE"
$path = ""
if ($os_type -eq $True) {
	$path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $winws_folder
}
else
{
	$path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $winws_folder
}

# Checking if Winws is already installed. Ask to uninstall. If not accepted, exit script.
Write-Output "Ïðîâåðêà íàëè÷èÿ óñòàíîâëåííîãî DFE"

$winws_service_exists = Get-Service -Name "DFE" -ErrorAction SilentlyContinue

if ($winws_service_exists.Length -gt 0) {
	$result = [System.Windows.Forms.MessageBox]::Show('Íàéäåí óñòàíîâëåííûé ðàíåå ñåðâèñ DFE' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Óäàëèòü?' , "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Error)
	if ($result -eq 'Yes') {
		# Deleting existing Winws service
		Write-Output "Óäàëåíèå DFE"
		[void](sc.exe stop "DFE")
		[void](sc.exe delete "DFE")
		DeleteLeftoverFiles -old_folder_path "$path"
		exit
	}
	if ($result -eq 'No') {
		exit
	}
}

$result = [System.Windows.Forms.MessageBox]::Show('Ñêðèïò óñòàíîâèò DFE äëÿ âîññòàíîâëåíèÿ äîñòóïà ê Discord è Youtube' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Ðàçðåøèòü óñòàíîâêó?' , "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') 
{

	$path = Split-Path $path -Parent

	DeleteLeftoverFiles -old_folder_path "$path\$winws_folder"
	
	[void](New-Item -Path "$path\$winws_folder" -ItemType Directory -Confirm:$False -Force)

	# Downloading latest Winws to installtion folder
	Write-Output "Çàãðóçêà ïîñëåäíåé âåðñèè Winws"
	
	Invoke-WebRequest -Uri "https://github.com/bol-van/zapret-win-bundle/archive/refs/heads/master.zip" -OutFile "$path\zapret-win-bundle-master.zip"
	
	$winws_archive_name = "zapret-win-bundle-master.zip"

	# Unpack downloaded archive
	Write-Output "Ðàñïàêîâêà àðõèâà"
	
	Expand-Archive -Path "$path\$winws_archive_name" -DestinationPath $path
	$unpacked_folder = "$path\$winws_archive_name".TrimEnd('.zip')
	[void](Move-Item -Path "$unpacked_folder\zapret-winws\*" -Destination "$path\$winws_folder" -Force -Confirm:$False)
	
	# Delete leftovers
	if (Test-Path "$unpacked_folder") {[void](Remove-Item "$unpacked_folder" -Confirm:$False -Force -Recurse)}
	if (Test-Path "$path\$winws_archive_name") {[void](Remove-Item "$path\$winws_archive_name" -Confirm:$False -Force)}
	
	# Download SCP:SL and Discord domains list File
	Write-Output "Çàãðóçêà sosalka_list.txt"
		
	Start-BitsTransfer -Source 'https://raw.githubusercontent.com/Sam282SD/D.F.E/refs/heads/main/sosalka_list.txt' -Destination "$path\$winws_folder"
		
	# Install Service
	Write-Output "Óñòàíîâêà DFE..."
	
	if ($os_type -eq $True) {
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $winws_folder + "\winws.exe"
	}
	else
	{
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $winws_folder + "\winws.exe"
	}
	
	$binaryPathName = "$exe_path --wf-tcp=80,443 --wf-udp=443,50000-50100 --filter-udp=443 --hostlist=`"$path\$winws_folder\sosalka_list.txt`" --dpi-desync=fake --dpi-desync-udplen-increment=10 --dpi-desync-repeats=6 --dpi-desync-udplen-pattern=0xDEADBEEF --dpi-desync-fake-quic=`"$path\$winws_folder\quic_initial_www_google_com.bin`" --new --filter-udp=50000-50100 --dpi-desync=fake,tamper --dpi-desync-any-protocol --dpi-desync-fake-quic=`"$path\$winws_folder\quic_initial_www_google_com.bin`" --new --filter-tcp=80 --hostlist=`"$path\$winws_folder\sosalka_list.txt`" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new --filter-tcp=443 --hostlist=`"$path\$winws_folder\sosalka_list.txt`" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls=`"$path\$winws_folder\tls_clienthello_www_google_com.bin`""
	[void](New-Service -Name "DFE" -BinaryPathName $binaryPathName -StartupType Automatic -Description "Îáõîä DPI by Sam")
	
	Write-Output "Çàïóñê DFE"
	[void](Start-Service -Name "DFE")
	
	$result = [System.Windows.Forms.MessageBox]::Show('DFE óñïåøíî óñòàíîâëåí' + [System.Environment]::NewLine + [System.Environment]::NewLine + "×òîáû óäàëèòü ñêðèïò, çàïóñòèòå ñíîâà äàííûé ôàéë, ãäå âàì ïðåäëîæàò óäàëèòü D.F.E", "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
if ($result -eq 'No') 
{
	exit
}