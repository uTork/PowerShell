function Reboot-Computer {
<#
.SYNOPSIS
FR
Cette fonction sert à redémarrer un ordinateur distant, une liste d’ordinateur dans un fichier CSV ou encore une partie des ordinateurs (-LIKE).
Vous devez avoir les droits administrateurs sur les ordinateurs distants afin de pouvoir les redémarrer.
EN
This function is used to restart a remote computer, a computer list in a CSV file or even a part of the computers (-LIKE). 
You must have administrator rights on remote computers before you can restart them.
.DESCRIPTION
Reboot Remote Computer | Redémarre les ordinateurs distant
.PARAMETER RemoteComputer
The name of the remote computer | Le nom de l'ordinateur distant à redémarrer
.PARAMETER CSV
Chemin du fichier CSV contenant le nom des ordinateurs. Un nom d'ordinateur par ligne. | CSV File Path. One computer name per line.
.PARAMETER LIKE
Mot contenu dans le nom des serveurs dans Active Directory. Tous les ordinateurs qui contiennent ce mot dans son nom seront redémarrés.
Word contained in the name of the servers in Active Directory. All computers that contain this word in its name will be restarted.
.PARAMETER DelaySeconds
Les nombres de secondes entre chaques démarrage des ordinateurs. | The delay in seconds between computer reboot.
.LINK
Sebastien Maltais
sebastien_maltais@hotmail.com
GIT: https://github.com/uTork/Powershell/
LinkedIn: https://www.linkedin.com/in/sebastienmaltais/
FaceBook: http://www.facebook.com/isPowerShell
#>

PARAM(
      [string]$RemoteComputer,
      [string]$CSV,
      [string]$LIKE,
      [int]$DelaySeconds
      )

if($RemoteComputer -ne ""){
    #redémarre l'ordinateur | reboot the computer server
    shutdown /r /f /m \\$RemoteComputer /t 1
    $message = "The computer $RemoteComputer is restarting"
    Write-Host $message
}

# Validation des secondes de delais entre les redémarrage des serveurs | Validation if Seconds exist

if($DelaySeconds -eq ""){$DelaySeconds = 1}




if($CSV -ne ""){

# CSV import
$cp = try{@(get-content -path $CSV -ErrorAction stop)}catch{$message = "Path not found";Write-Host $message;break}

# Redémarrage des serveurs | reboot computer list
$cp | foreach{
              $name = $_
              shutdown /r /f /m \\$name /t 1
              # Pause 5 minutes
              Start-Sleep -Seconds $DelaySeconds
              # Message 
              $message = "$name --OK"
              Write-Host $message
              }
 }


if($like -ne ""){
Function Get-MyModule{
Param([string]$name)
if(-not(Get-Module -name $name))
{
if(Get-Module -ListAvailable |
Where-Object { $_.name -eq $name })
{
Import-Module -Name $name
$true
} #end if module available then import
else { $false } #module not available
} # end if not module
else { $true } #module already loaded
} 
$message1 = "Install the ActiveDirectory module............."
$ad = get-mymodule -name "ActiveDirectory"
if($ad -eq $false){clear;write-output $message1;break}


# Active Directory computer list
$cp = (get-adcomputer -filter * -Properties * | where-object {$_.name -like $like}).name

# Redémarrage des serveurs | reboot server list
$cp | foreach{
              $name = $_
              shutdown /r /f /m \\$name /t 1

              # Pause 5 minutes
              Start-Sleep -Seconds $DelaySeconds

              # Message 
              $message = "$name --OK"
              Write-Host $message
              
              }
}
}

