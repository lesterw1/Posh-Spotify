<#

    All API functions related to the Spotify player.

    NOTE: As of 7/15/2017, the underlying API endpoints are still under Beta by Spotify. Spotify may change/remove these features at any time.

#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

##################################
## Spotify Player API Functions ##
##################################

#region Spotify Player API Functions

#====================================================================================================================================================
#######################
## Get-SpotifyDevice ##
#######################

#region Get-SpotifyDevice

function Get-SpotifyDevice {

    <#

        .SYNOPSIS

            Get information about a user’s available devices.

        .DESCRIPTION

            Get information about a user’s available devices. An Access Token is required for this API call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/get-a-users-available-devices/

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "user-read-playback-state" scope authorized in order to read information.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.Device')]

    param([ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    $Devices = @()

    $result = Invoke-SpotifyRequest -Method 'GET' -Path '/v1/me/player/devices' -AccessToken $AccessToken -SpotifyEnv $SpotifyEnv

    foreach ($device in $result.devices) {
        $Devices += [NewGuy.PoshSpotify.Device]::new($device)
    }

    return $Devices

}

Export-ModuleMember -Function 'Get-SpotifyDevice'

#endregion Get-SpotifyDevice

#====================================================================================================================================================
#######################
## Get-SpotifyPlayer ##
#######################

#region Get-SpotifyPlayer

function Get-SpotifyPlayer {

    <#

        .SYNOPSIS

            Get information about the user’s current playback state, including track, track progress, and active device.

        .DESCRIPTION

            Get information about the user’s current playback state, including track, track progress, and active device. An Access Token is required
            for this API call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/get-information-about-the-users-current-playback/

        .PARAMETER Market

            An ISO 3166-1 alpha-2 country code. Provide this parameter if you want to apply Track Relinking. Use "from_token" to specify the country
            code of the user associated with the given Access Token.

            https://developer.spotify.com/web-api/track-relinking-guide/

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "user-read-playback-state" scope authorized in order to read information.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.Player')]

    param([string]$Market,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    $splat = @{
        Method = 'GET'
        Path = '/v1/me/player'
        AccessToken = $AccessToken
        SpotifyEnv = $SpotifyEnv
    }

    if ($Market) { $splat['QueryParameters'] = @{ market = $Market } }

    $result = Invoke-SpotifyRequest @splat

    $player = [NewGuy.PoshSpotify.Player]::new($result)

    return $player

}

Export-ModuleMember -Function 'Get-SpotifyPlayer'

#endregion Get-SpotifyPlayer

#====================================================================================================================================================
#####################################
## Get-SpotifyCurrentPlayerContext ##
#####################################

#region Get-SpotifyCurrentPlayerContext

function Get-SpotifyCurrentPlayerContext {

    <#

        .SYNOPSIS

            Get the player context of the currently active player on the user’s Spotify account. The player context details what is playing (Album,
            Artist, Playlist) and the current progress of that context (i.e. IsPlaying, Track, Progress).

        .DESCRIPTION

            Get the player context of the currently active player on the user’s Spotify account. The player context details what is playing (Album,
            Artist, Playlist) and the current progress of that context (i.e. IsPlaying, Track, Progress). An Access Token is required for this API
            call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/get-the-users-currently-playing-track/

        .PARAMETER Market

            An ISO 3166-1 alpha-2 country code. Provide this parameter if you want to apply Track Relinking. Use "from_token" to specify the country
            code of the user associated with the given Access Token.

            https://developer.spotify.com/web-api/track-relinking-guide/

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "user-read-currently-playing" and/or "user-read-playback-state" scope authorized in order to read
            information.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.PlayerContext')]

    param([string]$Market,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    $splat = @{
        Method = 'GET'
        Path = '/v1/me/player/currently-playing'
        AccessToken = $AccessToken
        SpotifyEnv = $SpotifyEnv
    }

    if ($Market) { $splat['QueryParameters'] = @{ market = $Market } }

    $result = Invoke-SpotifyRequest @splat

    $currPlaying = [NewGuy.PoshSpotify.PlayerContext]::new($result)

    return $currPlaying

}

Export-ModuleMember -Function 'Get-SpotifyCurrentPlayerContext'

#endregion Get-SpotifyCurrentPlayerContext

#====================================================================================================================================================
#######################
## Set-SpotifyPlayer ##
#######################

#region Set-SpotifyPlayer

function Set-SpotifyPlayer {

    <#

        .SYNOPSIS

            Transfer playback to a new device and determine if it should start playing.

        .DESCRIPTION

            Transfer playback to a new device and determine if it should start playing. An Access Token is required for this API call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/transfer-a-users-playback/

        .PARAMETER Play

            If switch is provided, ensures playback happens on new device. If not provided keeps the current playback state.

        .PARAMETER DeviceId

            The device for which this command targets.

            Currently Spotify API only supports one device ID.

        .PARAMETER Device

            The device for which this command targets. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects
            returned from Get-SpotifyPlayer (Player objects contain a Device object).

            Currently Spotify API only supports one device ID.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.

    #>

    [CmdletBinding()]

    param([switch]$Play,
          [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'DeviceId')] [string[]]$DeviceId,
          [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'DeviceObj')] [NewGuy.PoshSpotify.Device[]]$Device,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    process {

        if ($PSCmdlet.ParameterSetName -eq 'DeviceObj') { $DeviceId = $Device.Id }

        $params = @{
            device_ids = $DeviceId
            play = $Play.IsPresent
        }

        $splat = @{
            Method = 'PUT'
            Path = '/v1/me/player'
            AccessToken = $AccessToken
            RequestBodyParameters = $params
            Encoding = 'JSON'
            SpotifyEnv = $SpotifyEnv
        }

        $result = Invoke-SpotifyRequest @splat

        return $result

    }

}

Export-ModuleMember -Function 'Set-SpotifyPlayer'

#endregion Set-SpotifyPlayer

#====================================================================================================================================================
###########################
## Start-SpotifyPlayback ##
###########################

#region Start-SpotifyPlayback

function Start-SpotifyPlayback {

    <#

        .SYNOPSIS

            Start a new context or resume current playback on the user’s active device.

        .DESCRIPTION

            Start a new context or resume current playback on the user’s active device. An Access Token is required for this API call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/start-a-users-playback/

        .PARAMETER ContextUri

            Spotify URI of the context to play. Valid contexts are albums, artists & playlists.

                Example: "spotify:album:1Je1IMUlBXcx1Fz0WE7oPT"

        .PARAMETER Tracks

            A JSON array of the Spotify track URIs to play.

                Example: "spotify:track:4iV5W9uYEdYUVa79Axb7Rh", "spotify:track:1301WleyT98MSxVHPZCA6M"

        .PARAMETER Offset

            Indicates from where in the context playback should start. Only available when ContextUri corresponds to an album or playlist object, or
            when the Tracks parameter is used.

            Provide either a positive integer to specify a "position" within the context or use a Spotify resource uri to specify the item to start at.

            Example 1: Start at 5th item of play context (album, playlist, etc.). Use this when using the ContextUri parameter.

                -Offset 5

            Example 2: Start at specified track uri in provided list of Tracks. Use this when using the Tracks parameter.

                -Offset "spotify:track:1301WleyT98MSxVHPZCA6M"

        .PARAMETER DeviceId

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used.

            Currently Spotify API only supports one device ID.

        .PARAMETER Device

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
            Get-SpotifyPlayer (Player objects contain a Device object).

            Currently Spotify API only supports one device ID.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.

    #>

    [CmdletBinding(DefaultParameterSetName = 'CurrentActiveDevice')]

    param([string]$ContextUri,
          [string[]]$Tracks,
          [string]$Offset,
          [Parameter(ValueFromPipeline, ParameterSetName = 'DeviceId')] [string[]]$DeviceId,
          [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'DeviceObj')] [NewGuy.PoshSpotify.Device[]]$Device,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    process {

        if ($PSCmdlet.ParameterSetName -eq 'DeviceObj') { $DeviceId = $Device.Id }

        $bodyParams = $null

        if ($ContextUri -and $Tracks) { throw 'Spotify does not support both ContextUri and Tracks parameter on the same request.' }
        elseif ($ContextUri) { $bodyParams = @{ 'context_uri' = $ContextUri } }
        elseif ($Tracks) { $bodyParams = @{ 'uris' = $Tracks } }

        if ($Offset -and ($ContextUri -or $Tracks)) {
            $parsedOffset = $null
            if ([int]::TryParse($Offset, [ref]$parsedOffset)) {
                $bodyParams['offset'] = @{ position = $parsedOffset }
            } else {
                $bodyParams['offset'] = @{ uri = $Offset }
            }
        }

        $splat = @{
            Method = 'PUT'
            Path = '/v1/me/player/play'
            AccessToken = $AccessToken
            Encoding = 'JSON'
            SpotifyEnv = $SpotifyEnv
        }

        if ($DeviceId) { $splat['QueryParameters'] = @{ device_id = $DeviceId } }
        if ($bodyParams) { $splat['RequestBodyParameters'] = $bodyParams }

        $result = Invoke-SpotifyRequest @splat

        return $result

    }

}

Export-ModuleMember -Function 'Start-SpotifyPlayback'

#endregion Start-SpotifyPlayback

#====================================================================================================================================================
##########################
## Stop-SpotifyPlayback ##
##########################

#region Stop-SpotifyPlayback

function Stop-SpotifyPlayback {

    <#

        .SYNOPSIS

            Pause playback on the user’s account.

        .DESCRIPTION

            Pause playback on the user’s account. An Access Token is required for this API call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/pause-a-users-playback/

        .PARAMETER DeviceId

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used.

            Currently Spotify API only supports one device ID.

        .PARAMETER Device

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
            Get-SpotifyPlayer (Player objects contain a Device object).

            Currently Spotify API only supports one device ID.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.

    #>

    [CmdletBinding(DefaultParameterSetName = 'CurrentActiveDevice')]

    param([Parameter(ValueFromPipeline, ParameterSetName = 'DeviceId')] [string[]]$DeviceId,
          [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'DeviceObj')] [NewGuy.PoshSpotify.Device[]]$Device,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    process {

        if ($PSCmdlet.ParameterSetName -eq 'DeviceObj') { $DeviceId = $Device.Id }

        $splat = @{
            Method = 'PUT'
            Path = '/v1/me/player/pause'
            AccessToken = $AccessToken
            SpotifyEnv = $SpotifyEnv
        }

        if ($DeviceId) { $splat['QueryParameters'] = @{ device_id = $DeviceId } }

        $result = Invoke-SpotifyRequest @splat

        return $result

    }

}

Export-ModuleMember -Function 'Stop-SpotifyPlayback'

#endregion Stop-SpotifyPlayback

#====================================================================================================================================================
###########################
## Skip-SpotifyNextTrack ##
###########################

#region Skip-SpotifyNextTrack

function Skip-SpotifyNextTrack {

    <#

        .SYNOPSIS

            Skips to next track in the user’s queue.

        .DESCRIPTION

            Skips to next track in the user’s queue. An Access Token is required for this API call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/skip-users-playback-to-next-track/

        .PARAMETER DeviceId

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used.

            Currently Spotify API only supports one device ID.

        .PARAMETER Device

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
            Get-SpotifyPlayer (Player objects contain a Device object).

            Currently Spotify API only supports one device ID.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.

    #>

    [CmdletBinding(DefaultParameterSetName = 'CurrentActiveDevice')]

    param([Parameter(ValueFromPipeline, ParameterSetName = 'DeviceId')] [string[]]$DeviceId,
          [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'DeviceObj')] [NewGuy.PoshSpotify.Device[]]$Device,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    process {

        if ($PSCmdlet.ParameterSetName -eq 'DeviceObj') { $DeviceId = $Device.Id }

        $splat = @{
            Method = 'POST'
            Path = '/v1/me/player/next'
            AccessToken = $AccessToken
            SpotifyEnv = $SpotifyEnv
        }

        if ($DeviceId) { $splat['QueryParameters'] = @{ device_id = $DeviceId } }

        $result = Invoke-SpotifyRequest @splat

        return $result

    }

}

Export-ModuleMember -Function 'Skip-SpotifyNextTrack'

#endregion Skip-SpotifyNextTrack

#====================================================================================================================================================
###############################
## Skip-SpotifyPreviousTrack ##
###############################

#region Skip-SpotifyPreviousTrack

function Skip-SpotifyPreviousTrack {

    <#

        .SYNOPSIS

            Skips to previous track in the user’s queue.

        .DESCRIPTION

            Skips to previous track in the user’s queue.

            Note that this will ALWAYS skip to the previous track, regardless of the current track’s progress. Returning to the start of the current
            track should be performed using the Set-SpotifyTrackSeek command.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/skip-users-playback-to-previous-track/

        .PARAMETER DeviceId

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used.

            Currently Spotify API only supports one device ID.

        .PARAMETER Device

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
            Get-SpotifyPlayer (Player objects contain a Device object).

            Currently Spotify API only supports one device ID.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.

    #>

    [CmdletBinding(DefaultParameterSetName = 'CurrentActiveDevice')]

    param([Parameter(ValueFromPipeline, ParameterSetName = 'DeviceId')] [string[]]$DeviceId,
          [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'DeviceObj')] [NewGuy.PoshSpotify.Device[]]$Device,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    process {

        if ($PSCmdlet.ParameterSetName -eq 'DeviceObj') { $DeviceId = $Device.Id }

        $splat = @{
            Method = 'POST'
            Path = '/v1/me/player/previous'
            AccessToken = $AccessToken
            SpotifyEnv = $SpotifyEnv
        }

        if ($DeviceId) { $splat['QueryParameters'] = @{ device_id = $DeviceId } }

        $result = Invoke-SpotifyRequest @splat

        return $result

    }

}

Export-ModuleMember -Function 'Skip-SpotifyPreviousTrack'

#endregion Skip-SpotifyPreviousTrack

#====================================================================================================================================================
##########################
## Set-SpotifyTrackSeek ##
##########################

#region Set-SpotifyTrackSeek

function Set-SpotifyTrackSeek {

    <#

        .SYNOPSIS

            Seeks to the given position in the user’s currently playing track.

        .DESCRIPTION

            Seeks to the given position in the user’s currently playing track.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/seek-to-position-in-currently-playing-track/

        .PARAMETER Minutes

            The position in minutes to seek to. Must be a positive number. Passing in a position that is greater than the length of the track
            will cause the player to start playing the next song.

            This value will be added to the total if used with other time unit parameters.

        .PARAMETER Seconds

            The position in milliseconds to seek to. Must be a positive number. Passing in a position that is greater than the length of the track
            will cause the player to start playing the next song.

            The default is 10s.

            This value will be added to the total if used with other time unit parameters.

        .PARAMETER Milliseconds

            The position in milliseconds to seek to. Must be a positive number. Passing in a position that is greater than the length of the track
            will cause the player to start playing the next song.

            The default is 10,000ms (10s).

            This value will be added to the total if used with other time unit parameters.

        .PARAMETER DeviceId

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used.

            Currently Spotify API only supports one device ID.

        .PARAMETER Device

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
            Get-SpotifyPlayer (Player objects contain a Device object).

            Currently Spotify API only supports one device ID.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.

    #>

    [CmdletBinding(DefaultParameterSetName = 'CurrentActiveDevice')]

    param([int]$Minutes = 0,
          [int]$Seconds = 0,
          [int]$Milliseconds = 0,
          [Parameter(ValueFromPipeline, ParameterSetName = 'DeviceId')] [string[]]$DeviceId,
          [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'DeviceObj')] [NewGuy.PoshSpotify.Device[]]$Device,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    process {

        if ($PSCmdlet.ParameterSetName -eq 'DeviceObj') { $DeviceId = $Device.Id }

        $total = 0
        $total += $Minutes * 60 * 1000
        $total += $Seconds * 1000
        $total += $Milliseconds

        # Seek 10s by default.
        if ($total -eq 0) { $total = 10000 }

        $splat = @{
            Method = 'PUT'
            Path = '/v1/me/player/seek'
            AccessToken = $AccessToken
            QueryParameters = @{ position_ms = $total }
            SpotifyEnv = $SpotifyEnv
        }

        if ($DeviceId) { $splat['QueryParameters']['device_id'] = $DeviceId }

        $result = Invoke-SpotifyRequest @splat

        return $result

    }

}

Export-ModuleMember -Function 'Set-SpotifyTrackSeek'

#endregion Set-SpotifyTrackSeek

#====================================================================================================================================================
#############################
## Set-SpotifyPlayerVolume ##
#############################

#region Set-SpotifyPlayerVolume

function Set-SpotifyPlayerVolume {

    <#

        .SYNOPSIS

            Set the volume for the user’s current playback device.

        .DESCRIPTION

            Set the volume for the user’s current playback device.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/set-volume-for-users-playback/

        .PARAMETER Volume

            The volume to set. Must be a value from 0 to 100 inclusive.

            The default is to set the mode to Track repeat mode.

        .PARAMETER DeviceId

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used.

            Currently Spotify API only supports one device ID.

        .PARAMETER Device

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
            Get-SpotifyPlayer (Player objects contain a Device object).

            Currently Spotify API only supports one device ID.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.

    #>

    [CmdletBinding(DefaultParameterSetName = 'CurrentActiveDevice')]

    param([Parameter(Mandatory)] [ValidateScript({ ($_ -ge 0) -and ($_ -le 100) })] [int]$Volume,
          [Parameter(ValueFromPipeline, ParameterSetName = 'DeviceId')] [string[]]$DeviceId,
          [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'DeviceObj')] [NewGuy.PoshSpotify.Device[]]$Device,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    process {

        if ($PSCmdlet.ParameterSetName -eq 'DeviceObj') { $DeviceId = $Device.Id }

        $splat = @{
            Method = 'PUT'
            Path = '/v1/me/player/volume'
            AccessToken = $AccessToken
            QueryParameters = @{ volume_percent = $Volume }
            SpotifyEnv = $SpotifyEnv
        }

        if ($DeviceId) { $splat['QueryParameters']['device_id'] = $DeviceId }

        $result = Invoke-SpotifyRequest @splat

        # TODO : Maybe use the Write-Progress command to animate the turning up of the volume.

        return $result

    }

}

Export-ModuleMember -Function 'Set-SpotifyPlayerVolume'

#endregion Set-SpotifyPlayerVolume

#====================================================================================================================================================
#################################
## Set-SpotifyPlayerRepeatMode ##
#################################

#region Set-SpotifyPlayerRepeatMode

function Set-SpotifyPlayerRepeatMode {

    <#

        .SYNOPSIS

            Set the repeat mode for the user’s playback. Options are Repeat Track, Repeat Context or Off.

        .DESCRIPTION

            Set the repeat mode for the user’s playback. Options are Repeat Track, Repeat Context or Off.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/set-repeat-mode-on-users-playback/

        .PARAMETER State

            The state of the Repeat feature. Possible values include :

                Track OR Context OR Off

            Track will repeat the current track.
            Context will repeat the current context (album, playlist, etc.).
            Off will turn repeat off.

            The default is to set the mode to Track repeat mode.

        .PARAMETER DeviceId

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used.

            Currently Spotify API only supports one device ID.

        .PARAMETER Device

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
            Get-SpotifyPlayer (Player objects contain a Device object).

            Currently Spotify API only supports one device ID.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.

    #>

    [CmdletBinding(DefaultParameterSetName = 'CurrentActiveDevice')]

    param([Parameter(Mandatory)] [ValidateSet('Track', 'Context', 'Off')] [string]$State = 'Track',
          [Parameter(ValueFromPipeline, ParameterSetName = 'DeviceId')] [string[]]$DeviceId,
          [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'DeviceObj')] [NewGuy.PoshSpotify.Device[]]$Device,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    process {

        if ($PSCmdlet.ParameterSetName -eq 'DeviceObj') { $DeviceId = $Device.Id }

        $splat = @{
            Method = 'PUT'
            Path = '/v1/me/player/repeat'
            AccessToken = $AccessToken
            QueryParameters = @{ state = $State.ToLower() }
            SpotifyEnv = $SpotifyEnv
        }

        if ($DeviceId) { $splat['QueryParameters']['device_id'] = $DeviceId }

        $result = Invoke-SpotifyRequest @splat

        return $result

    }

}

Export-ModuleMember -Function 'Set-SpotifyPlayerRepeatMode'

#endregion Set-SpotifyPlayerRepeatMode

#====================================================================================================================================================
##################################
## Set-SpotifyPlayerShuffleMode ##
##################################

#region Set-SpotifyPlayerShuffleMode

function Set-SpotifyPlayerShuffleMode {

    <#

        .SYNOPSIS

            Toggle shuffle on or off for user’s playback.

        .DESCRIPTION

            Toggle shuffle on or off for user’s playback.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/toggle-shuffle-for-users-playback/

        .PARAMETER State

            The state of the Shuffle feature. Possible values include :

                Enabled OR Disabled

            Enabled shuffles the user's playback.
            Disabled does not shuffles the user's playback.

            The default is to enable the Shuffle feature.

        .PARAMETER DeviceId

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used.

            Currently Spotify API only supports one device ID.

        .PARAMETER Device

            The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
            current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
            Get-SpotifyPlayer (Player objects contain a Device object).

            Currently Spotify API only supports one device ID.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.

    #>

    [CmdletBinding(DefaultParameterSetName = 'CurrentActiveDevice')]

    param([Parameter(Mandatory)] [ValidateSet('Enabled', 'Disabled')] [string]$State = 'Enabled',
          [Parameter(ValueFromPipeline, ParameterSetName = 'DeviceId')] [string[]]$DeviceId,
          [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'DeviceObj')] [NewGuy.PoshSpotify.Device[]]$Device,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    process {

        if ($PSCmdlet.ParameterSetName -eq 'DeviceObj') { $DeviceId = $Device.Id }

        $splat = @{
            Method = 'PUT'
            Path = '/v1/me/player/shuffle'
            AccessToken = $AccessToken
            QueryParameters = @{ state = $(if ($State -eq 'Enabled') { 'true' } else { 'false' }) }
            SpotifyEnv = $SpotifyEnv
        }

        if ($DeviceId) { $splat['QueryParameters']['device_id'] = $DeviceId }

        $result = Invoke-SpotifyRequest @splat

        return $result

    }

}

Export-ModuleMember -Function 'Set-SpotifyPlayerShuffleMode'

#endregion Set-SpotifyPlayerShuffleMode

#endregion Spotify Player API Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
