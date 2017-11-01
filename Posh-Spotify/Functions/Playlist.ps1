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

Function Get-SpotifyPlaylist {

    <#

        .SYNOPSIS

            Get a list of the playlists owned or followed by the given Spotify user or current user if none is given.

        .DESCRIPTION

            Get a list of the playlists owned or followed by the given Spotify user or current user if none is given. An Access Token is required for
            this API call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/get-a-list-of-current-users-playlists/
                                  https://developer.spotify.com/web-api/get-list-users-playlists/

        .PARAMETER Id

            The user's Spotify Id used to retrieve playlist information. If none is provided the current user will be used.

        .PARAMETER PageResults

            The results will be limited to the range specified by the Limit and Offset parameters.

            NOTE: Spotify API has limits on the number of items that can be returned in a single request as well as limits on the number of requests
            that can be made in a short period of time. By default this command will retrieve all items available which may result in multiple
            requests to the Spotify API. Spotify API rate limits may apply. For more details see the following:

                https://developer.spotify.com/web-api/user-guide/#rate-limiting

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

                https://developer.spotify.com/web-api/user-guide/#rate-limiting

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            The Access Token must have the "playlist-read-collaborative" and "playlist-read-private" scope authorized in order to read information.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.Playlist[]')]

    Param([Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias('Username')] [string]$Id,
          [switch]$PageResults,
          [int]$Limit = 20,
          [int]$Offset = 0,
          [switch]$SkipTrackRetrieval,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    Begin {

        $PlaylistList = @()

    }

    Process {

        $path = '/v1/me/playlists'

        If ($Username.Length -gt 0) { $path = "/v1/users/$Username/playlists" }

        $splat = @{ Path = $path }

        If ($PageResults) {
            $splat.Limit = $Limit
            $splat.Offset = $Offset
        } Else {
            $splat.Limit = 50
            $splat.Offset = 0
        }

        $pagingObject = New-SpotifyPage @splat

        # Get requested playlists.
        If ($PageResults) {
            $PlaylistList += (Get-SpotifyPage -PagingInfo $pagingObject -RetrieveMode NextPage -AccessToken $AccessToken -SpotifyEnv $SpotifyEnv).Items
        } Else {
            $PlaylistList += (Get-SpotifyPage -PagingInfo $pagingObject -RetrieveMode AllPages -AccessToken $AccessToken -SpotifyEnv $SpotifyEnv).Items
        }

        # Get all Tracks if not otherwise requested.
        If (-not $SkipTrackRetrieval) {
            Foreach ($playlist In $PlaylistList) {
                $newPageInfo = Get-SpotifyPage -PagingInfo $playlist.TrackPagingInfo -RetrieveMode AllPages -AccessToken $AccessToken -SpotifyEnv $SpotifyEnv
                $newPageInfo.Items | ForEach-Object { $playlist.Tracks.Add($_) }
            }
        }

    }

    End {

        Return $PlaylistList

    }

}

Export-ModuleMember -Function 'Get-SpotifyPlaylist'

#endregion Get-SpotifyPlaylist

#endregion Spotify Playlist API Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
