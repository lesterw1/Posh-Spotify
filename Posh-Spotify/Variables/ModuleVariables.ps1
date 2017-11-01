<#

    All module scoped variables. These variables will not be in scope to the PowerShell session this module was loaded in. Some variables are used
    to store values throughout the operation of the script and should only be modified by the module. These variables will be marked as DO NOT MODIFY.
    Some variables are merely default values for parameters to various public commands and can be modified to suit your preference. These variables
    will be marked as DEFAULT PREFERENCES.

        DO NOT MODIFY       : Variables that are used to store values throughout the operation of the script and should NOT be modified.

        DEFAULT PREFERENCES : Variables that are merely default values for parameters to various public commands and can be modified to suit your
                              preference.

        CONFIGURATIONS      : Variables that are used for various settings and configurations for internal operations of this module. These variables
                              can be modified to adjust for Spotify API changes and tweak performance and optoins of the module.

#>

#====================================================================================================================================================

#######################################
### Default User Session Management ###
#######################################

#=========================#
#== DEFAULT PREFERENCES ==#
#=========================#

# Default location for saving EnvironmentInfo (Save-SpotifyEnvironmentInfo).
$script:SpotifyDefaultEnvironmentInfoSaveLocation = $env:TEMP
# $script:SpotifyDefaultEnvironmentInfoSaveLocation = '.'  # Current directory.

# Default filename for saving EnvironmentInfo (Save-SpotifyEnvironmentInfo).
$script:SpotifyDefaultEnvironmentInfoSaveFilename = "$($env:USERNAME)_$($env:COMPUTERNAME)_SpotifyEnvironmentInfo.json"

#===================#
#== DO NOT MODIFY ==#
#===================#

# Current Spotify Environment Info (Set-SpotifyEnvironmentInfo).
$script:SpotifyDefaultEnvironmentInfo = $null

#====================================================================================================================================================

#############################
### Invoke-SpotifyRequest ###
#############################

# Invoke-SpotifyRequest is the primary command used behind all other commands making a call to the Spotify API. Modify these configurations only if
# you are familiar with how the Invoke-SpotifyRequest command works.

#====================#
#== CONFIGURATIONS ==#
#====================#

# Default Invoke-SpotifyRequest configurations.

# User agent used during Spotify Auth API requests.
$script:SpotifyUserAgent = 'Posh-Spotify/0.1'

# Buffer size used when using the -ReturnRawBytes switch on some commands.
$script:SpotifyBufferSize = 8192

# Spotify Web API Hostname.
$script:SpotifyWebApiHostname = 'api.spotify.com'

# Spotify Accounts API Hostname.
$script:SpotifyAccountsApiHostname = 'accounts.spotify.com'

#====================================================================================================================================================