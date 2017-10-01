<#

    All API functions related to the Spotify tracks.

#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#################################
## Spotify Track API Functions ##
#################################

#region Spotify Track API Functions

#====================================================================================================================================================
######################
## Get-SpotifyTrack ##
######################

#region Get-SpotifyTrack

Function Get-SpotifyTrack {

    <#

        .SYNOPSIS

            Get information about the specified track(s).

        .DESCRIPTION

            Get information about the specified track(s). An Access Token is required for this API call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/get-several-tracks/

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

        .PARAMETER Ids

            An array of Spotify Ids of the tracks to get information for. Maximum: 50 IDs.

        .PARAMETER Market

            An ISO 3166-1 alpha-2 country code. Provide this parameter if you want to apply Track Relinking. Use "from_token" to specify the country
            code of the user associated with the gieven Access Token.

            https://developer.spotify.com/web-api/track-relinking-guide/

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.Track[]')]

    Param([ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired),
          [Parameter(Mandatory)] [string[]]$Ids,
          [Alias('Country')] [string]$Market,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    # Maximum of 50 tracks per request.
    If ($Ids.Count -gt 50) { Throw "Only 50 tracks per request allowed."}

    $TrackList = @()

    $params = @{
        ids = $Ids -join ','
    }

    If ($Market) { $params['market'] = $Market }

    $result = Invoke-SpotifyRequest -Method 'GET' -Path '/v1/tracks' -AccessToken $AccessToken -QueryParameters $params -SpotifyEnv $SpotifyEnv

    Foreach ($track In $result.tracks) {
        $TrackList += [NewGuy.PoshSpotify.Track]::new($track)
    }

    Return $TrackList

}

Export-ModuleMember -Function 'Get-SpotifyTrack'

#endregion Get-SpotifyTrack

#endregion Spotify Track API Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
