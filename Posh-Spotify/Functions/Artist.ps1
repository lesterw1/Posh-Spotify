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

Function Get-SpotifyArtist {

    <#

        .SYNOPSIS

            Get information about the specified artist(s).

        .DESCRIPTION

            Get information about the specified artist(s). An Access Token is required for this API call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/get-several-artists/

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

        .PARAMETER Ids

            An array of Spotify Ids of the artists to get information for. Maximum: 50 IDs.

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
    [OutputType('NewGuy.PoshSpotify.Artist[]')]

    Param([ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired),
          [Parameter(Mandatory)] [string[]]$Ids,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    # Maximum of 20 artists per request.
    If ($Ids.Count -gt 20) { Throw "Only 20 artists per request allowed."}

    $ArtistList = @()

    $params = @{
        ids = $Ids -join ','
    }

    $result = Invoke-SpotifyRequest -Method 'GET' -Path '/v1/artists' -AccessToken $AccessToken -QueryParameters $params -SpotifyEnv $SpotifyEnv

    Foreach ($artist In $result.artists) {
        $ArtistList += [NewGuy.PoshSpotify.Artist]::new($artist)
    }

    Return $ArtistList

}

Export-ModuleMember -Function 'Get-SpotifyArtist'

#endregion Get-SpotifyArtist

#endregion Spotify Artist API Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
