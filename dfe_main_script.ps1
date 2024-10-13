function DelGDPY
{	
	Param (
		[string]$ofp
	)
	
	if (Test-Path $ofp) {
		Write-Output "Удаление старых файлов GoodbyeDPI"
		[void](Remove-Item $ofp -Recurse -Confirm:$False -Force)
	}
}

$host.ui.RawUI.WindowTitle = "D.F.E."
Write-Host "Discord For Everyone" -ForegroundColor red
Write-Host ""

$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
function global:Write-Host() {}

Set-Variable -Name 'ConfirmPreference' -Value 'None' -Scope Global

[void]([System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms"))

$os_type = (Get-WmiObject -Class Win32_ComputerSystem).SystemType -match ‘(x64)’

$gdpi_f = "DPI"
$path = ""
if ($os_type -eq $True) {
	$path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $gdpi_f + "\x86_64"
}
else
{
	$path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $gdpi_f + "\x86"
}

Write-Output "Проверка наличия GoodbyeDPI"

$gdpi_service_exists = Get-Service -Name "D.F.E." -ErrorAction SilentlyContinue

if ($gdpi_service_exists.Length -gt 0) {
	$result = [System.Windows.Forms.MessageBox]::Show('У Вас уже установлен D.F.E.' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Удалить?' , "D.F.E." , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Error)
	if ($result -eq 'Yes') {
		Write-Output "Останавливаем и удаляем сервис D.F.E."
		[void](sc.exe stop "D.F.E.")
		[void](sc.exe delete "D.F.E.")
		DelGDPY -ofp (Split-Path $path -Parent)
		exit
	}
	if ($result -eq 'No') {
		exit
	}
}

$result = [System.Windows.Forms.MessageBox]::Show('Скрипт установит сервис D.F.E.' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Установить?' , "D.F.E." , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {

	$path = Split-Path (Split-Path $path -Parent) -Parent

	DelGDPY -ofp "$path\$gdpi_f"
	
	[void](New-Item -Path "$path\$gdpi_f" -ItemType Directory -Confirm:$False -Force)

	Write-Output "Скачивание GoodbyeDPI..."
			
	Invoke-RestMethod 'https://api.github.com/repos/ValdikSS/GoodbyeDPI/releases/latest' | % assets | ? name -like "*.zip" | % { 
		Invoke-WebRequest $_.browser_download_url -OutFile ("$path\" + $_.name) 
		$gdpi_an = $_.name
	}
	Write-Output "Распаковка архива"
	
	Expand-Archive -Path "$path\$gdpi_an" -DestinationPath $path
	$unpacked_folder = "$path\$gdpi_an".TrimEnd('.zip')
	[void](Move-Item -Path "$unpacked_folder\*" -Destination "$path\$gdpi_f" -Force -Confirm:$False)
	
	if (Test-Path "$unpacked_folder") {[void](Remove-Item "$unpacked_folder" -Confirm:$False -Force -Recurse)}
	if (Test-Path "$path\$gdpi_an") {[void](Remove-Item "$path\$gdpi_an" -Confirm:$False -Force)}

	Write-Output "Загрузка white_list.txt"

	Start-BitsTransfer -Source 'https://raw.githubusercontent.com/Sam282SD/D.F.E./main/white_list.txt' -Destination "$path\$gdpi_f"

	Write-Output "Устанавка сервиса D.F.E."
	
	if ($os_type -eq $True) {
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $gdpi_f + "\x86_64\goodbyedpi.exe"
	}
	else
	{
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $gdpi_f + "\x86\goodbyedpi.exe"
	}

	[void](cmd.exe /c "sc create `"D.F.E.`" binPath= `"$exe_path -5 --blacklist `"`"$path\$gdpi_f\white_list.txt`"`"")
	[void](sc.exe config "D.F.E." start= auto)
	[void](sc.exe description "D.F.E." "Discord for everyone.")
	
	Write-Output "Запускаем сервис D.F.E."
	[void](sc.exe start "D.F.E.")
	
	$result = [System.Windows.Forms.MessageBox]::Show('D.F.E. успешно установлен' + [System.Environment]::NewLine + [System.Environment]::NewLine + "Скрипт будет работать всегда с этого момента, пока Вы не удалите его повторным запуском D.F.E._installer.bat", "D.F.E." , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
if ($result -eq 'No') {
	exit
}

