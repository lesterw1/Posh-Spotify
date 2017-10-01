<#

    All API functions related to the Spotify albums.

#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#################################
## Spotify Album API Functions ##
#################################

#region Spotify Album API Functions

#====================================================================================================================================================
######################
## Get-SpotifyAlbum ##
######################

#region Get-SpotifyAlbum

Function Get-SpotifyAlbum {

    <#

        .SYNOPSIS

            Get information about the specified album(s).

        .DESCRIPTION

            Get information about the specified album(s). An Access Token is required for this API call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/get-several-albums/

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

        .PARAMETER Ids

            An array of Spotify Ids of the albums to get information for. Maximum: 50 IDs.

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
    [OutputType('NewGuy.PoshSpotify.Album[]')]

    Param([ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired),
          [Parameter(Mandatory)] [string[]]$Ids,
          [Alias('Country')] [string]$Market,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    # Maximum of 50 albums per request.
    If ($Ids.Count -gt 50) { Throw "Only 50 albums per request allowed."}

    $AlbumList = @()

    $params = @{
        ids = $Ids -join ','
    }

    If ($Market) { $params['market'] = $Market }

    $result = Invoke-SpotifyRequest -Method 'GET' -Path '/v1/albums' -AccessToken $AccessToken -QueryParameters $params -SpotifyEnv $SpotifyEnv

    Foreach ($album In $result.albums) {
        $AlbumList += [NewGuy.PoshSpotify.Album]::new($album)
    }

    Return $AlbumList

}

Export-ModuleMember -Function 'Get-SpotifyAlbum'

#endregion Get-SpotifyAlbum

#endregion Spotify Album API Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
