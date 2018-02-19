#Requires -Version 3.0

# This is the module script file that will be executed first upon importing this module. For simplicity this file should remain
# fairly minimalistic and should mostly just dot source other files to bring in definitions for this module.

#==================================================================================================================================

#########################
# Module Initialization #
#########################

# Load the Spotify environment info such as the client id and secret key.
# The file will define the $SpotifyEnvironmentInfo variable in the script scope (a.k.a. module scope in this case).

. "$PSScriptRoot\SpotifyEnvironmentInfo\SpotifyEnvironmentInfo.ps1"

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
