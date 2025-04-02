function DeleteLeftoverFiles
{	
	Param (
		[string]$old_folder_path
	)
	
	# Delete existing installation folder
	if (Test-Path $old_folder_path) {
		Write-Output "Winws"
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

$result = [System.Windows.Forms.MessageBox]::Show('Внимание!' + [System.Environment]::NewLine + [System.Environment]::NewLine + "Вы выключили VPN, TUN, Proxy и прочие приблуды?", "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)


$goodbyedpi = Get-Process goodbyedpi

if ($goodbyedpi) {
	$result = [System.Windows.Forms.MessageBox]::Show('Найден работающий GoodbyeDPI.' + [System.Environment]::NewLine + [System.Environment]::NewLine + "Вам необходимо удалить, либо временно выключить GoodbyeDPI так как он конфликтует с Winws. Сейчас он будет принудительно выключен.", "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
	[void]($goodbyedpi | Stop-Process -Force)
}

# Finding Winws folder
$winws_folder = "D.F.E_Folder"
$path = ""
if ($os_type -eq $True) {
	$path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $winws_folder
}
else
{
	$path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $winws_folder
}

Write-Output "Проверяем, есть ли D.F.E на устройстве"

$winws_service_exists = Get-Service -Name "D.F.E" -ErrorAction SilentlyContinue

if ($winws_service_exists.Length -gt 0) {
	$result = [System.Windows.Forms.MessageBox]::Show('Найден установленный ранее сервис D.F.E!' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Удалить?' , "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Error)
	if ($result -eq 'Yes') {
		# Deleting existing Winws service
		Write-Output "Останавливаем и удаляем сервис D.F.E"
		[void](sc.exe stop "D.F.E")
		[void](sc.exe delete "D.F.E")
		DeleteLeftoverFiles -old_folder_path "$path"
	}
	if ($result -eq 'No') {
		exit
	}
}

$result = [System.Windows.Forms.MessageBox]::Show('Скрипт установит сервис D.F.E для обхода блокировки DS, YT.' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Разрешить установку?' , "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {

	$path = Split-Path $path -Parent

	DeleteLeftoverFiles -old_folder_path "$path\$winws_folder"
	
	[void](New-Item -Path "$path\$winws_folder" -ItemType Directory -Confirm:$False -Force)

	# Downloading latest Winws to installtion folder
	Write-Output "Идёт загрузка скрипта..."
	
	Invoke-WebRequest -Uri "https://github.com/bol-van/zapret-win-bundle/archive/refs/heads/master.zip" -OutFile "$path\zapret-win-bundle-master.zip"
	
	$winws_archive_name = "zapret-win-bundle-master.zip"

	# Unpack downloaded archive
	Write-Output "Распаковка архива..."
	Write-Host ""
	
	Expand-Archive -Path "$path\$winws_archive_name" -DestinationPath $path
	$unpacked_folder = "$path\$winws_archive_name".TrimEnd('.zip')
	[void](Move-Item -Path "$unpacked_folder\zapret-winws\*" -Destination "$path\$winws_folder" -Force -Confirm:$False)
	
	# Delete leftovers
	if (Test-Path "$unpacked_folder") {[void](Remove-Item "$unpacked_folder" -Confirm:$False -Force -Recurse)}
	if (Test-Path "$path\$winws_archive_name") {[void](Remove-Item "$path\$winws_archive_name" -Confirm:$False -Force)}
	
	# Download SCP:SL, Discord and YouTube domains list File
	Write-Output "Загрузка доменов для обхода блокировки"
		
	Start-BitsTransfer -Source 'https://raw.githubusercontent.com/Sam282SD/D.F.E/refs/heads/main/sosalka_list.txt' -Destination "$path\$winws_folder"
	Start-BitsTransfer -Source 'https://raw.githubusercontent.com/Sam282SD/D.F.E/refs/heads/main/D.F.E_starter.cmd' -Destination "$path\$winws_folder"
	Start-BitsTransfer -Source 'https://raw.githubusercontent.com/Sam282SD/D.F.E/refs/heads/main/dfe.ico' -Destination "$path\$winws_folder"



	# Install Service
	Write-Output "Установка сервиса D.F.E"
	
	if ($os_type -eq $True) {
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $winws_folder + "\D.F.E_starter.cmd"
		$icon_path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $winws_folder + "\dfe.ico"
	}
	else
	{
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $winws_folder + "\D.F.E_starter.cmd"
		$icon_path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $winws_folder + "\dfe.ico"
	}
	
	
	[void](New-Service -Name "D.F.E" -BinaryPathName $binaryPathName -StartupType Disabled -Description "Обход by Sam")

	$shortcutLocation = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), 'D.F.E_starter.lnk')

	$shell = New-Object -ComObject WScript.Shell

	$shortcut = $shell.CreateShortcut($shortcutLocation)

	$shortcut.TargetPath = $exe_path
	$shortcut.IconLocation = $icon_path  
	$shortcut.Save()

	
	$result = [System.Windows.Forms.MessageBox]::Show('D.F.E успешно установлен. Запустите D.F.E_starter на вашем рабочем столе, чтобы обход заработал. Чтобы удалить его, запустите скрипт снова. Вам предложат его удалить. Удачи!' + [System.Environment]::NewLine, "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
if ($result -eq 'No') {
	exit
}