function Set-ADuserTsprofile {
<#
.SYNOPSIS

FR
Cette fonction permet de changé le path du profile terminal serveur sur les utilisateurs members d'un groupe Active Directory.
Cette fonction sera utiliser dans une tâches planifié qui s'exécute au 15minutes.

EN
This function allows you to change the path of the terminal server profile on users who are members of an Active Directory group.
This function will be used in a scheduled task that runs at 15 minutes.

.DESCRIPTION
Configure le Path du profile Terminal Server des utilsateur AD | Configure the Path of the AD User Terminal Profile
.PARAMETER ADGroup
Groupe Source Active Directory qui contient les membres a configurer | Active Directory Source Group that contains the members to configure
.PARAMETER TSProfilePath
PATH UNC du chemin du profile TS | The profil path . Ex: "\\server\share$\%username%"
.LINK
Sebastien Maltais
sebastien_maltais@hotmail.com
GIT: https://github.com/uTork/Powershell/
LinkedIn: https://www.linkedin.com/in/sebastienmaltais/
FaceBook: http://www.facebook.com/isPowerShell
#>

PARAM(
      [string]$ADGroup,
      [string]$TSProfilePath
      )

# ImportExcel module installation validation
# Validation de l'installation du module ImportExcel
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


# Extraction des membres du groupe active directory
# Ad group member extraction
$goupmember = get-adgroup -Identity $ADGroup | Get-ADGroupMember | where-object {$_.objectClass -eq "user"}


# Ajout du chemin du profil à l'attribut AD de l'usager | set aduser profil
Foreach ($user in $goupmember) {
                                $AD = get-aduser $user.samaccountname | select -ExpandProperty disting*
                                $ADUser = [ADSI]"LDAP://$AD"
                                $ADUser.psbase.InvokeSet("terminalservicesprofilepath",$TSProfilePath)
                                $ADuser.setinfo()
                                }
                                }
