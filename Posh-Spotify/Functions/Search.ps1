<#

    All API functions related to the Spotify search endpoint.

#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

##################################
## Spotify Search API Functions ##
##################################

#region Spotify Search API Functions

#====================================================================================================================================================
#######################
## Get-SpotifySearch ##
#######################

#region Get-SpotifySearch

function Get-SpotifySearch {

    <#

        .SYNOPSIS

            Get Spotify catalog information about artists, albums, tracks or playlists that match a keyword string.

        .DESCRIPTION

            Get Spotify catalog information about artists, albums, tracks or playlists that match a keyword string. An Access Token is required for
            this API call.

            If "from_token" is supplied to the Market parameter, the current user must have authorized the "user-read-private" scope.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/search/search/

        .PARAMETER Query

            The search query's keywords (and optional field filters and operators), for example 'roadhouse blues'.

            Keyword matching

                Matching of search keywords is not case-sensitive. (Operators, however, should be specified in uppercase.)

                Keywords will be matched in any order unless surrounded by double quotation marks: 'roadhouse blues' will match both
                'Blues Roadhouse' and 'Roadhouse of the Blues' while '"roadhouse blues"' will match 'My Roadhouse Blues' but not 'Roadhouse of the Blues'.

                Searching for playlists will return results where the query keyword(s) match any part of the playlist's name or description. Only
                popular public playlists are returned.

            Operators

                The operator NOT can be used to exclude results. For example 'roadhouse NOT blues' returns items that match 'roadhouse' but excludes
                those that also contain the keyword 'blues'.

                Similarly, the OR operator can be used to broaden the search: 'roadhouse OR blues' returns all results that include either of the
                terms. Only one OR operator can be used in a query.

                Note that operators must be specified in uppercase otherwise they will be treated as normal keywords to be matched.

            Wildcards

                The asterisk (*) character can, with some limitations, be used as a wildcard (maximum: 2 per query). It will match a variable number
                of non-white-space characters. It cannot be used in a quoted phrase, in a field filter, when there is a dash ("-") in the query, or
                as the first character of the keyword string.

            Field filters

                By default, results are returned when a match is found in any field of the target object type. Object type is specified by the Type
                parameter. Searches can be made more specific by specifying an album, artist or track field filter. For example, a query of type
                'Album' and a query of 'album:gold artist:abba' will only return albums with the text 'gold' in the album name and the text 'abba' in
                the artist's name.

                The field filter year can be used with album, artist and track searches to limit the results to a particular year (for example,
                'bob year:2014') or date range (for example, 'bob year:1980-2020').

                The field filter tag:new can be used in album searches to retrieve only albums released in the last two weeks. The field filter
                tag:hipster can be used in album searches to retrieve only albums with the lowest 10% popularity. Please note that this field filter
                only works with album searches.

                Other possible field filters, depending on object types being searched, include genre (applicable to tracks and artists), upc, and
                isrc. For example, a Query parameter of 'lil genre:"southern hip hop"' and Type parameter Artist. Use double quotation marks around
                the genre keyword string if it contains spaces.

        .PARAMETER Type

            An array of item types to search across. Valid types are: Album, Artist, Playlist, and Track. If no Type is given the default will be
            Track and only Track objects will be returned.

            Search results will include hits from all the specified item types; for example a query of 'name:abacab' and types of @(Album, Track) will
            return both albums and tracks with 'abacab' in their name.

        .PARAMETER Market

            An ISO 3166-1 alpha-2 country code or the string from_token.

            If a country code is given, only artists, albums, and tracks with content playable in that market will be returned. (Playlist results are
            not affected by the market parameter.)

            If "from_token" is given and a valid access token is supplied, only items with content playable in the country associated with the user's
            account will be returned. (The country associated with the user's account can be viewed by the user in their account settings at
            https://www.spotify.com/se/account/overview/). Note that the user must have granted access to the "user-read-private" scope when the
            access token was issued.

        .PARAMETER Limit

            The maximum number of results to return. Default: 20. Minimum: 1. Maximum: 50.

        .PARAMETER Offset

            The index of the first result to return. Default: 0 (i.e., the first result). Maximum offset: 100.000. Use with limit to get the next page
            of search results.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

            If Market parameter is "from_token", the current user must have authorized the "user-read-private" scope.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.Context[]')]

    param([Parameter(Mandatory, ValueFromPipeline)][ValidateNotNullOrEmpty()] [string]$Query,
          [ValidateSet('Album', 'Artist', 'Playlist', 'Track')] [string[]]$Type = 'Track',
          [Alias('Country')] [string]$Market,
          [int]$Limit = 50,
          [int]$Offset = 0,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv,
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired -SpotifyEnv $SpotifyEnv))

    begin {

        $SearchList = @()

    }

    process {

        $params = @{
            q = $Query
            type = ($Type -join ',').ToLower()
        }

        if ($PSBoundParameters.Keys -contains 'Limit') { $params['limit'] = $Limit }
        if ($PSBoundParameters.Keys -contains 'Offset') { $params['offset'] = $Offset }
        if ($Market) { $params['market'] = $Market }

        $result = Invoke-SpotifyRequest -Method 'GET' -Path '/v1/search' -AccessToken $AccessToken -QueryParameters $params -SpotifyEnv $SpotifyEnv

        # Go through each type list found and pull out the PagingInfo object.
        foreach ($itemListType in ($result | Get-Member | Where-Object { $_.MemberType -eq 'NoteProperty' } | Select-Object -ExpandProperty Name)) {
            $SearchList += [NewGuy.PoshSpotify.PagingInfo]::new($result.$itemListType)
        }

    }

    end {

        return $SearchList

    }

}

Export-ModuleMember -Function 'Get-SpotifySearch'

#endregion Get-SpotifySearch

#endregion Spotify Search API Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
