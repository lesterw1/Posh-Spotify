#Requires -Version 3.0

# This is the module script file that will be executed first upon importing this module. For simplicity this file should reamin
# fairly minimalistic and should mostly just dot source other files to bring in definitions for this module.

#==================================================================================================================================

#####################
# Module Parameters #
#####################

# The Spotify environment info can be passed to the module during the Import-Modue command using the -ArguementList parameter.
Param([hashtable]$SpotifyEnvironmentInfo = @{},
      [string]$SpotifyDefaultEnv)

# Hashtables pass by reference. So we have to recreate/clone them to prevent the user from modifying the hashtable they passed in
# and in turn modifying the hashtable stored in this module without a proper validation tests being performed on it.
# If the user did not provide any environment info during the Import-Module command then the SpotifyEnvironmentInfo.ps1 file will be
# used. If the user provided environment info but did not provide a default Spotify environment then throw an error.
$userEnvironmentInfo = @{}
$SpotifyEnvironmentInfo.Keys | ForEach-Object { $userEnvironmentInfo[$_] = $SpotifyEnvironmentInfo[$_].Clone() }
$script:SpotifyEnvironmentInfo = $userEnvironmentInfo
$script:SpotifyDefaultEnv = If (($SpotifyEnvironmentInfo.Count -gt 1) -and ($SpotifyDefaultEnv.Length -eq 0)) { Throw 'Must provide a default Spotify environment key with argument list.' } Else { $SpotifyDefaultEnv }

#==================================================================================================================================

#########################
# Module Initialization #
#########################

# Load the Spotify environment info such as the client id and secret key.
# Either use the info provided by the user on import of the module via the -ArguementList parameter or load from a file.
# The file will define the $SpotifyEnvironmentInfo variable in the script scope (a.k.a. module scope in this case).

If ($script:SpotifyEnvironmentInfo.Count -eq 0) {
    . "$PSScriptRoot\SpotifyEnvironmentInfo\SpotifyEnvironmentInfo.ps1"
}

# Using the System.Web.HttpUtility .Net library.
[System.Reflection.Assembly]::Load('System.Web, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a') | Out-Null

# LoadWithPartialName is deprecated...but so less problematic for simple applications like this.
# However, it is still useful in determining what string to use above.
# ([System.Reflection.Assembly]::LoadWithPartialName('System.Web')).FullName

#==================================================================================================================================

######################
# Add Custom Content #
######################

# ~~~ Variables ~~~ #

. "$PSScriptRoot\Variables\ModuleVariables.ps1"

# ~~~ Types ~~~ #

. "$PSScriptRoot\Model\Import-ObjectModel.ps1"

# ~~~ Functions ~~~ #

. "$PSScriptRoot\Functions\Album.ps1"
. "$PSScriptRoot\Functions\Artist.ps1"
. "$PSScriptRoot\Functions\DefaultSession.ps1"
. "$PSScriptRoot\Functions\Environment.ps1"
. "$PSScriptRoot\Functions\Initialize-SpotifyAuthorizationCodeFlow.ps1"
. "$PSScriptRoot\Functions\Invoke-SpotifyRequest.ps1"
. "$PSScriptRoot\Functions\PagingInfo.ps1"
. "$PSScriptRoot\Functions\Player.ps1"
. "$PSScriptRoot\Functions\Playlist.ps1"
. "$PSScriptRoot\Functions\Search.ps1"
. "$PSScriptRoot\Functions\Track.ps1"

#==================================================================================================================================

#######################
# Module Finalization #
#######################

# Verify the Spotify environment info is in proper format.

Test-SpotifyEnvInfoFormat
