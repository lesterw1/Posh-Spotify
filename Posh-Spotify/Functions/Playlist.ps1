<#

    All API functions related to the Spotify playlists.

#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

####################################
## Spotify Playlist API Functions ##
####################################

#region Spotify Playlist API Functions

#====================================================================================================================================================
#########################
## Get-SpotifyPlaylist ##
#########################

#region Get-SpotifyPlaylist

function Get-SpotifyPlaylist {

    <#

        .SYNOPSIS

            Get a list of the playlists owned or followed by the given Spotify user or current user if none is given.

        .DESCRIPTION

            Get a list of the playlists owned or followed by the given Spotify user or current user if none is given. An Access Token is required for
            this API call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/playlists/get-a-list-of-current-users-playlists/
                                  https://developer.spotify.com/documentation/web-api/reference/playlists/get-list-users-playlists/

        .PARAMETER Id

            The Spotify ID for the requested playlist. If one is not provided, all playlists will be returned.

        .PARAMETER UserId

            The user's Spotify Id used to retrieve playlist information. If none is provided the current user will be used.

        .PARAMETER PageResults

            The results will be limited to the range specified by the Limit and Offset parameters.

            NOTE: Spotify API has limits on the number of items that can be returned in a single request as well as limits on the number of requests
            that can be made in a short period of time. By default this command will retrieve all items available which may result in multiple
            requests to the Spotify API. Spotify API rate limits may apply. For more details see the following:

                https://developer.spotify.com/documentation/web-api/#rate-limiting

        .PARAMETER Limit

            The maximum number of playlists to return. Default: 20. Minimum: 1. Maximum: 50.

        .PARAMETER Offset

            The index of the first playlist to return. Default: 0 (the first object). Maximum offset: 100,000. Use with limit to get the next set of
            playlists.

        .PARAMETER SkipTrackRetrieval

            Track objects will not be retrieved for each Playlist.

            NOTE: Spotify API has limits on the number of items that can be returned in a single request as well as limits on the number of requests
            that can be made in a short period of time. By default this command will retrieve all items available which may result in multiple
            requests to the Spotify API. Spotify API rate limits may apply. For more details see the following:

                https://developer.spotify.com/documentation/web-api/#rate-limiting

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            Private playlists are only retrievable for the current user and requires the "playlist-read-private" scope to have been authorized by the
            user. Note that this scope alone will not return collaborative playlists, even though they are always private. Collaborative playlists are
            only retrievable for the current user and requires the "playlist-read-collaborative" scope to have been authorized by the user.

    #>

    [CmdletBinding(DefaultParameterSetName = 'CurrentUser')]
    [OutputType('NewGuy.PoshSpotify.Playlist[]')]

    param([Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'PlaylistId')][Alias('Playlist')] [string]$Id,
          [Parameter(ParameterSetName = 'UserId')][Alias('Username')] [string]$UserId,
          [switch]$PageResults,
          [int]$Limit = 20,
          [int]$Offset = 0,
          [switch]$SkipTrackRetrieval,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    begin {

        $PlaylistList = @()

    }

    process {

        # Retrieving only a single playlist.
        if ($PSCmdlet.ParameterSetName -eq 'PlaylistId') {

            $path = "/v1/playlists/$Id"

            # Get requested playlist.
            $result = Invoke-SpotifyRequest -Method GET -Path $path -AccessToken $AccessToken -SpotifyEnv $SpotifyEnv

            # We should have gotten back a single playlist.
            if ($result.type -eq 'playlist') { $PlaylistList += [NewGuy.PoshSpotify.Playlist]::new($result) }

        }

        # Retrieving multiple playlists wrapped in a paging info object.
        else {

            # Assume we are getting all playlists for the current user.
            $path = '/v1/me/playlists'

            # If we were given a UserId then get all playlists for that user.
            if ($PSCmdlet.ParameterSetName -eq 'UserId') { $path = "/v1/users/$Username/playlists" }

            $splat = @{ Path = $path }

            if ($PageResults) {
                $splat.Limit = $Limit
                $splat.Offset = $Offset
            } else {
                $splat.Limit = 50
                $splat.Offset = 0
            }

            $pagingObject = New-SpotifyPage @splat

            # Get requested playlists.
            if ($PageResults) {
                $PlaylistList += (Get-SpotifyPage -PagingInfo $pagingObject -RetrieveMode NextPage -AccessToken $AccessToken -SpotifyEnv $SpotifyEnv).Items
            } else {
                $PlaylistList += (Get-SpotifyPage -PagingInfo $pagingObject -RetrieveMode AllPages -AccessToken $AccessToken -SpotifyEnv $SpotifyEnv).Items
            }

        }

        # Get all Tracks if not otherwise requested or we were retrieving a specific playlist which would already have the tracks.
        if ((-not $SkipTrackRetrieval) -and ($PSCmdlet.ParameterSetName -ne 'PlaylistId')) {
            foreach ($playlist in $PlaylistList) {
                $newPageInfo = Get-SpotifyPage -PagingInfo $playlist.TrackPagingInfo -RetrieveMode AllPages -AccessToken $AccessToken -SpotifyEnv $SpotifyEnv
                $newPageInfo.Items | ForEach-Object { $playlist.Tracks.Add($_) }
            }
        }

    }

    end {

        return $PlaylistList

    }

}

Export-ModuleMember -Function 'Get-SpotifyPlaylist'

#endregion Get-SpotifyPlaylist

#====================================================================================================================================================
#########################
## New-SpotifyPlaylist ##
#########################

#region New-SpotifyPlaylist

function New-SpotifyPlaylist {

    <#

        .SYNOPSIS

            Creates a new Spotify playlist.

        .DESCRIPTION

            Creates a new Spotify playlist.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/playlists/create-playlist/

        .PARAMETER Id

            The Spotify ID for the user account the playlist will be created in.

        .PARAMETER Name

            The name of the new playlist.

        .PARAMETER Public

            This switch will set the playlist to Public. By default it is will be created as Private.

        .PARAMETER Collaborative

            This switch will set the playlist to Collaborative. Other users who have access to the playlist URI or are following the playlist will be
            able to make changes to the playlist. A Collaborative playlist is always private. Therefore a playlist cannot be both Public and
            Collaborative.

        .PARAMETER Description

            A description for the new playlist.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "playlist-modify-public" and "playlist-modify-private" scope authorized in order to add tracks.

    #>

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType('NewGuy.PoshSpotify.Playlist')]

    param([Parameter(Mandatory)][Alias('User')] [string]$Id,
          [Parameter(Mandatory)] [string]$Name,
          [Parameter(ParameterSetName = 'Public')] [switch]$Public,
          [Parameter(ParameterSetName = 'Collaborative')] [switch]$Collaborative,
          [string]$Description,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    end {

        $path = "/v1/users/$Id/playlists"

        $body = @{ name = $Name }

        if ($Public) { $body['public'] = $true }
        else { $body['public'] = $false }

        # If $Collaborative is $true then $Public has to be false due to the ParameterSet restrictions.
        if ($Collaborative) { $body['collaborative'] = $true }

        if ($Description) { $body['description'] = $Description }

        $playlist = Invoke-SpotifyRequest -Method POST -Path $path -RequestBodyParameters $body -Encoding JSON -AccessToken $AccessToken -SpotifyEnv $SpotifyEnv

        $playlistObj = [NewGuy.PoshSpotify.Playlist]::new($playlist)

        return $playlistObj

    }

}

Export-ModuleMember -Function 'New-SpotifyPlaylist'

#endregion New-SpotifyPlaylist

#====================================================================================================================================================
#########################
## Set-SpotifyPlaylist ##
#########################

#region Set-SpotifyPlaylist

function Set-SpotifyPlaylist {

    <#

        .SYNOPSIS

            Sets a Spotify playlist to the provided settings.

        .DESCRIPTION

            Sets a Spotify playlist to the provided settings.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/playlists/change-playlist-details/

        .PARAMETER Id

            The Spotify ID for the playlist to set.

        .PARAMETER Name

            The name of the playlist to set.

        .PARAMETER Public

            This switch will set the playlist to Public.

        .PARAMETER Private

            This switch will set the playlist to Private.

        .PARAMETER Collaborative

            This switch will set the playlist to Collaborative. Other users who have access to the playlist URI or are following the playlist will be
            able to make changes to the playlist. A Collaborative playlist is always private. Therefore a playlist cannot be both Public and
            Collaborative.

        .PARAMETER Description

            A description for the playlist to set.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "playlist-modify-public" and "playlist-modify-private" scope authorized in order to add tracks.

    #>

    [CmdletBinding(DefaultParameterSetName = 'Default')]

    param([Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias('User')] [string]$Id,
          [string]$Name,
          [Parameter(ParameterSetName = 'Public')] [switch]$Public,
          [Parameter(ParameterSetName = 'Private')] [switch]$Private,
          [Parameter(ParameterSetName = 'Collaborative')] [switch]$Collaborative,
          [string]$Description,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    end {

        $path = "/v1/playlists/$Id"

        $body = @{}

        if ($Name) { $body['name'] = $Name }

        if ($Public) { $body['public'] = $true }
        elseif ($Private) { $body['public'] = $false }
        elseif ($Collaborative) { $body['collaborative'] = $true }

        if ($Description) { $body['description'] = $Description }

        Invoke-SpotifyRequest -Method PUT -Path $path -RequestBodyParameters $body -Encoding JSON -AccessToken $AccessToken -SpotifyEnv $SpotifyEnv

    }

}

Export-ModuleMember -Function 'Set-SpotifyPlaylist'

#endregion Set-SpotifyPlaylist

#====================================================================================================================================================
##############################
## Add-SpotifyPlaylistTrack ##
##############################

#region Add-SpotifyPlaylistTrack

function Add-SpotifyPlaylistTrack {

    <#

        .SYNOPSIS

            Add tracks to the provided playlist.

        .DESCRIPTION

            Add tracks to the provided playlist.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/playlists/add-tracks-to-playlist/

        .PARAMETER Id

            The Spotify ID for the playlist the provided tracks will be added to.

        .PARAMETER TackUri

            The Spotify URIs for the tracks to be added to the playlist. Example below:

                spotify:track:5VnDkUNyX6u5Sk0yZiP8XB

        .PARAMETER Tack

            The NewGuy.PoshSpotify.Track objects to be added to the playlist.

        .PARAMETER Position

            The position to insert the tracks, a zero-based index. For example, to insert the tracks in the first position specify 0 To insert the
            tracks in the third position specify 2. If omitted, the tracks will be appended to the playlist. Tracks are added in the order they are
            listed in the array provided to this command.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "playlist-modify-public" and "playlist-modify-private" scope authorized in order to add tracks.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.Snapshot')]

    param([Parameter(Mandatory)][Alias('Playlist')] [string]$Id,
          [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'TrackUri')] [string[]]$TrackUri,
          [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'TrackObj')] [NewGuy.PoshSpotify.Track[]]$Track,
          [int]$Position,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    process {

        $path = "/v1/playlists/$Id/tracks"

        if ($PSCmdlet.ParameterSetName -eq 'TrackUri') { $body = @{ uris = [array]($TrackUri) } }
        elseif ($PSCmdlet.ParameterSetName -eq 'TrackObj') { $body = @{ uris = [array]($Track.Uri) } }

        if ($PSBoundParameters.Keys.Contains('Position')) {
            $body.position = $Position
        }

        $playlistSnapshot = Invoke-SpotifyRequest -Method POST -Path $path -RequestBodyParameters $body -Encoding JSON -AccessToken $AccessToken -SpotifyEnv $SpotifyEnv

        $snapshotObj = [NewGuy.PoshSpotify.Snapshot]::new($playlistSnapshot)

        return $snapshotObj

    }

}

Export-ModuleMember -Function 'Add-SpotifyPlaylistTrack'

#endregion Add-SpotifyPlaylistTrack

#endregion Spotify Playlist API Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
