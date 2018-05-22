<#
.SYNOPSIS
    Creates a scheduled task to enable folder redirection into OneDrive
#>

# Define some variables that we need acccess to
$Url = "https://raw.githubusercontent.com/PAAM-Systems/Powershell-OneDrive-Script/master/Redirect-FoldersOneDrive.ps1"
$Target = "$env:ProgramData\Scripts"
$Script = "Redirect-FoldersOneDrive.ps1"
$Domain = "$env:UserDomain"
$UserName = "$env:UserName"

Start-Transcript -Path "$Target\Set-RedirectOneDriveTask-ps1.log"

# If local path for script doesn't exist, create it
If (!(Test-Path $Target)) { New-Item -Path $Target -Type Directory -Force }

# Download the real script from GitHub
If (Test-Path "$Target\$Script") { Remove-Item -Path "$Target\$Script" -Force }
Start-BitsTransfer -Source $Url -Destination "$Target\$Script"

# Create a scheduled task action (make sure to bypass execution policy)
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Bypass -NonInteractive -WindowStyle Hidden -File $Target\$Script"

# Define the trigger object for the scheduled task (run at user login with random delay)
$trigger =  New-ScheduledTaskTrigger -AtLogon -RandomDelay (New-TimeSpan -Minutes 1)

# Define some settings for it
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Hidden -DontStopIfGoingOnBatteries -Compatibility Win8

# Define what user account that should execute the scheduled task
$principal = New-ScheduledTaskPrincipal "$Domain\$UserName"

# Create the scheduled task
$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal

# Finally, register the scheduled task in Windows
Register-ScheduledTask -InputObject $task -TaskName "Redirect Folders to OneDrive"

Stop-Transcript