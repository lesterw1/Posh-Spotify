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

function Get-SpotifyTrack {

    <#

        .SYNOPSIS

            Get information about the specified track(s).

        .DESCRIPTION

            Get information about the specified track(s). An Access Token is required for this API call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/get-several-tracks/

        .PARAMETER Id

            The Spotify Ids of the track(s) to get information for. Maximum: 50 IDs.

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

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.Track[]')]

    param([Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)] [string[]]$Id,
          [Alias('Country')] [string]$Market,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    begin {

        $TrackList = @()

    }

    process {

        # Maximum of 50 tracks per request.
        if ($Id.Count -gt 50) { throw "Only 50 tracks per request allowed."}

        $params = @{
            ids = $Id -join ','
        }

        if ($Market) { $params['market'] = $Market }

        $result = Invoke-SpotifyRequest -Method 'GET' -Path '/v1/tracks' -AccessToken $AccessToken -QueryParameters $params -SpotifyEnv $SpotifyEnv

        foreach ($track in $result.tracks) {
            $TrackList += [NewGuy.PoshSpotify.Track]::new($track)
        }

    }

    end {

        return $TrackList

    }

}

Export-ModuleMember -Function 'Get-SpotifyTrack'

#endregion Get-SpotifyTrack

#endregion Spotify Track API Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
