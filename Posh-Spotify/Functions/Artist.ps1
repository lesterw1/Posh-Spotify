<#

    All API functions related to the Spotify artists.

#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

##################################
## Spotify Artist API Functions ##
##################################

#region Spotify Artist API Functions

#====================================================================================================================================================
#######################
## Get-SpotifyArtist ##
#######################

#region Get-SpotifyArtist

function Get-SpotifyArtist {

    <#

        .SYNOPSIS

            Get information about the specified artist(s).

        .DESCRIPTION

            Get information about the specified artist(s). An Access Token is required for this API call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/artists/get-several-artists/

        .PARAMETER Id

            The Spotify Ids of the artist(s) to get information for. Maximum: 50 IDs.

        .PARAMETER Market

            An ISO 3166-1 alpha-2 country code. Provide this parameter if you want to apply Track Relinking. Use "from_token" to specify the country
            code of the user associated with the given Access Token.

            https://developer.spotify.com/documentation/general/guides/track-relinking-guide/

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.Artist[]')]

    param([Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)] [string[]]$Id,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    begin {

        $ArtistList = @()

    }

    process {

        # Maximum of 50 artists per request.
        if ($Id.Count -gt 50) { throw "Only 50 artists per request allowed." }

        $params = @{
            ids = $Id -join ','
        }

        $result = Invoke-SpotifyRequest -Method 'GET' -Path '/v1/artists' -AccessToken $AccessToken -QueryParameters $params -SpotifyEnv $SpotifyEnv

        foreach ($artist in $result.artists) {
            $ArtistList += [NewGuy.PoshSpotify.Artist]::new($artist)
        }

    }

    end {

        return [NewGuy.PoshSpotify.Artist[]]$ArtistList

    }

}

Export-ModuleMember -Function 'Get-SpotifyArtist'

#endregion Get-SpotifyArtist

#endregion Spotify Artist API Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
