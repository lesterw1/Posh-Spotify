<#

    All module scoped variables. These variables will not be in scope to the PowerShell session this module was loaded in and once loaded are used
    internally only.

        DEFAULT PREFERENCES : Variables that are merely default values for parameters to various public commands and can be modified to suit your
                              preference.

        CONFIGURATIONS      : Variables that are used for various settings and configurations for internal operations of this module. These variables
                              can be modified to adjust for Spotify API changes and tweak performance and options of the module.

#>

#====================================================================================================================================================

#######################################
### Default User Session Management ###
#######################################

#=========================#
#== DEFAULT PREFERENCES ==#
#=========================#

# Default location for saving Spotify environment configurations (Save-SpotifyEnvironmentInfo).
# $script:SpotifyDefaultEnvironmentInfoSaveLocation = '.'  # Current directory.
$script:SpotifyDefaultEnvironmentInfoSaveLocation = $env:TEMP

# Default filename for saving Spotify environment configurations (Save-SpotifyEnvironmentInfo).
$script:SpotifyDefaultEnvironmentInfoSaveFilename = "$($env:USERNAME)_$($env:COMPUTERNAME)_SpotifyEnvironmentInfo.json"

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