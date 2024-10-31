function DeleteLeftoverFiles
{	
	Param (
		[string]$old_folder_path
	)
	
	# Delete existing installation folder
	if (Test-Path $old_folder_path) {
		Write-Output "Удаление устаревших файлов"
		[void](Remove-Item $old_folder_path -Recurse -Confirm:$False -Force)
	}
}

# Set title and advertisement
$host.ui.RawUI.WindowTitle = "D.F.E"
Write-Host "Discord For Every one" -ForegroundColor yellow
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

$result = [System.Windows.Forms.MessageBox]::Show('Вопрос:' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Вы отключили VPN, GoodbyeDPI, туннели и прочие приблуды?' , "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
	if ($result -eq 'No') 
	{
		exit
	}

# Checking if Winws is already installed. Ask to uninstall. If not accepted, exit script.
Write-Output "Проверка наличия GoodbyeDPI"
$goodbyedpi = Get-Process goodbyedpi

if ($goodbyedpi) {
	$result = [System.Windows.Forms.MessageBox]::Show('Найден работающий GoodbyeDPI.' + [System.Environment]::NewLine + [System.Environment]::NewLine + "Выключите GoodbyeDPI. Сейчас он будет принудительно выключен.", "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
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
Write-Output "Проверка наличия установленного DFE"

$winws_service_exists = Get-Service -Name "DFE" -ErrorAction SilentlyContinue

if ($winws_service_exists.Length -gt 0) {
	$result = [System.Windows.Forms.MessageBox]::Show('Найден установленный сервис DFE' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Удалить?' , "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Error)
	if ($result -eq 'Yes') {
		# Deleting existing Winws service
		Write-Output "Удаление DFE"
		[void](sc.exe stop "DFE")
		[void](sc.exe delete "DFE")
		DeleteLeftoverFiles -old_folder_path "$path"
		exit
	}
	if ($result -eq 'No') {
		exit
	}
}

$result = [System.Windows.Forms.MessageBox]::Show('Скрипт установит DFE для восстановления доступа к Discord и Youtube' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Разрешить установку?' , "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {

	$path = Split-Path $path -Parent

	DeleteLeftoverFiles -old_folder_path "$path\$winws_folder"
	
	[void](New-Item -Path "$path\$winws_folder" -ItemType Directory -Confirm:$False -Force)

	# Downloading latest Winws to installtion folder
	Write-Output "Загрузка последней версии Winws"
	
	Invoke-WebRequest -Uri "https://github.com/bol-van/zapret-win-bundle/archive/refs/heads/master.zip" -OutFile "$path\zapret-win-bundle-master.zip"
	
	$winws_archive_name = "zapret-win-bundle-master.zip"

	# Unpack downloaded archive
	Write-Output "Распаковка архива"
	
	Expand-Archive -Path "$path\$winws_archive_name" -DestinationPath $path
	$unpacked_folder = "$path\$winws_archive_name".TrimEnd('.zip')
	[void](Move-Item -Path "$unpacked_folder\zapret-winws\*" -Destination "$path\$winws_folder" -Force -Confirm:$False)
	
	# Delete leftovers
	if (Test-Path "$unpacked_folder") {[void](Remove-Item "$unpacked_folder" -Confirm:$False -Force -Recurse)}
	if (Test-Path "$path\$winws_archive_name") {[void](Remove-Item "$path\$winws_archive_name" -Confirm:$False -Force)}
	
	# Download SCP:SL and Discord domains list File
	Write-Output "Загрузка sosalka_list.txt"
		
	Start-BitsTransfer -Source 'https://raw.githubusercontent.com/Sam282SD/D.F.E/refs/heads/main/sosalka_list.txt' -Destination "$path\$winws_folder"
		
	# Install Service
	Write-Output "Установка DFE..."
	
	if ($os_type -eq $True) {
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $winws_folder + "\winws.exe"
	}
	else
	{
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $winws_folder + "\winws.exe"
	}


	$binaryPathName = "$exe_path --wf-tcp=80,443 --wf-udp=443,50000-50100 --filter-udp=443 --hostlist=`"$path\$winws_folder\sosalka_list.txt`" --dpi-desync=fake --dpi-desync-udplen-increment=10 --dpi-desync-repeats=6 --dpi-desync-udplen-pattern=0xDEADBEEF --dpi-desync-fake-quic=`"$path\$winws_folder\quic_initial_www_google_com.bin`" --new --filter-udp=50000-50100 --dpi-desync=fake,tamper --dpi-desync-any-protocol --dpi-desync-fake-quic=`"$path\$winws_folder\quic_initial_www_google_com.bin`" --new --filter-tcp=80 --hostlist=`"$path\$winws_folder\sosalka_list.txt`" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new --filter-tcp=443 --hostlist=`"$path\$winws_folder\sosalka_list.txt`" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls=`"$path\$winws_folder\tls_clienthello_www_google_com.bin`""
	[void](New-Service -Name "DFE" -BinaryPathName $binaryPathName -StartupType Automatic -Description "Обход DPI by Sam")
	
	Write-Output "Запуск DFE"
	[void](Start-Service -Name "DFE")
	
	$result = [System.Windows.Forms.MessageBox]::Show('DFE успешно установлен' + [System.Environment]::NewLine + [System.Environment]::NewLine + "Чтобы удалить скрипт, запустите снова данный файл, где вам предложат удалить D.F.E", "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
if ($result -eq 'No') {
	exit
}