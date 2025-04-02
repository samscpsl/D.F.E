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

$result = [System.Windows.Forms.MessageBox]::Show('джжжж!' + [System.Environment]::NewLine + [System.Environment]::NewLine + "парпр VPN, TUN, Proxy парпр", "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

# Checking if Winws is already installed. Ask to uninstall. If not accepted, exit script.
Write-Output "я шок.."
$goodbyedpi = Get-Process goodbyedpi

if ($goodbyedpi) {
	$result = [System.Windows.Forms.MessageBox]::Show('Пока' + [System.Environment]::NewLine + [System.Environment]::NewLine + "вы человек?", "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
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

# Checking if Winws is already installed. Ask to uninstall. If not accepted, exit script.
Write-Output "бегите D.F.E"

$winws_service_exists = Get-Service -Name "D.F.E" -ErrorAction SilentlyContinue

if ($winws_service_exists.Length -gt 0) {
	$result = [System.Windows.Forms.MessageBox]::Show('беслан? D.F.E!' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'ааапппууу' , "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Error)
	if ($result -eq 'Yes') {
		# Deleting existing Winws service
		Write-Output "секкс1 D.F.E"
		[void](sc.exe stop "D.F.E")
		[void](sc.exe delete "D.F.E")
		DeleteLeftoverFiles -old_folder_path "$path"
	}
	if ($result -eq 'No') {
		exit
	}
}

$result = [System.Windows.Forms.MessageBox]::Show('ппппппппп DS, YT.' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'пиппа' , "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {

	$path = Split-Path $path -Parent

	DeleteLeftoverFiles -old_folder_path "$path\$winws_folder"
	
	[void](New-Item -Path "$path\$winws_folder" -ItemType Directory -Confirm:$False -Force)

	# Downloading latest Winws to installtion folder
	Write-Output "Идёт загрузка скрипта..."
	
	Invoke-WebRequest -Uri "https://github.com/bol-van/zapret-win-bundle/archive/refs/heads/master.zip" -OutFile "$path\zapret-win-bundle-master.zip"
	
	$winws_archive_name = "zapret-win-bundle-master.zip"

	# Unpack downloaded archive
	Write-Output "Распакоука архива..." -ForegroundColor red
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

	Start-BitsTransfer -Source 'https://private-user-images.githubusercontent.com/184440682/429591771-5b47ad5a-e697-43a1-904e-e5dde049c5a5.jpg?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NDM2MTQyNzAsIm5iZiI6MTc0MzYxMzk3MCwicGF0aCI6Ii8xODQ0NDA2ODIvNDI5NTkxNzcxLTViNDdhZDVhLWU2OTctNDNhMS05MDRlLWU1ZGRlMDQ5YzVhNS5qcGc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwNDAyJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDQwMlQxNzEyNTBaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT0xOTkwY2ZkYTgyMmI4MjY5M2ZmY2RjMWY3YjJhZGJjYzcyYjhkYzIzNmM1ZmViODk0ZDFhMDJjM2ZjZTJmMmZkJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.9Gcf-exKtDIB53t5rLwHAMVrJZ3klaqXiKrMKC0UxbE' -Destination "$path\$winws_folder"


	# Install Service
	Write-Output "Установка сервиса D.F.E"
	
	if ($os_type -eq $True) {
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $winws_folder + "\D.F.E_starter.cmd"
		$icon_path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $winws_folder + "\D.F.E_starter.cmd"
	}
	else
	{
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $winws_folder + "\D.F.E_starter.cmd"
		$icon_path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $winws_folder + "\D.F.E_starter.cmd"
	}
	
	

	$shortcutLocation = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), 'D.F.E_starter.lnk')

	$shell = New-Object -ComObject WScript.Shell

	$shortcut = $shell.CreateShortcut($shortcutLocation)

	$shortcut.TargetPath = $exe_path
	$shortcut.IconLocation = $exe_path  
	$shortcut.Save()

	
	$result = [System.Windows.Forms.MessageBox]::Show('D.F.E установлен!' + [System.Environment]::NewLine + [System.Environment]::NewLine + "пенис", "D.F.E" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
if ($result -eq 'No') {
	exit
}