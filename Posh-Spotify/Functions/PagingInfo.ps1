<#

    All API functions related to the Spotify Paging Object. Whenever Spotify has a large list of tracks to send it will do so by wrapping them in a
    Paging Object. This API module will use a .NET object PagingInfo to keep track of this Paging Object.

#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

######################################
## Spotify PagingInfo API Functions ##
######################################

#region Spotify PagingInfo API Functions

#====================================================================================================================================================
#####################
## Get-SpotifyPage ##
#####################

#region Get-SpotifyPage

Function Get-SpotifyPage {

    <#

        .SYNOPSIS

            Gets items for a Spotify API Paging Object. By default will retrieve the next available page. If specified can also retrieve the previous
            page or all page object items from all pages.

        .DESCRIPTION

            Gets items for a Spotify API Paging Object. By default will retrieve the next available page. If specified can also retrieve the previous
            page or all page object items from all pages. An Access Token is required for this API call.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/object-model/#paging-object

        .PARAMETER PagingInfo

            The PagingInfo object from which to retrieve more items.

        .PARAMETER RetrieveMode

            The page to retrieve. Valid values are NextPage, PreviousPage, AllPages. Default is NextPage.

        .PARAMETER AccessToken

            The Access Token provided during the authorization process.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.PagingInfo')]

    Param([Parameter(Mandatory, ValueFromPipeline)] [NewGuy.PoshSpotify.PagingInfo]$PagingInfo,
          [ValidateSet('NextPage', 'PreviousPage', 'AllPages')] [string]$RetrieveMode = 'NextPage',
          [ValidateNotNullOrEmpty()] [string]$AccessToken = $(Get-SpotifyDefaultAccessToken -IsRequired),
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    Process {

        If ($RetrieveMode -eq 'NextPage') {

            If (($PagingInfo.NextPage -eq '') -or ($PagingInfo.NextPage -eq $null)) { $path = $PagingInfo.FullDetailUri }
            Else { $path = $PagingInfo.NextPage }

            $result = Invoke-SpotifyRequest -Method 'GET' -Path $path -AccessToken $AccessToken -SpotifyEnv $SpotifyEnv

            If (($result.href -ne $null) -and ($result.href -ne '')) {
                $pagingObject = [NewGuy.PoshSpotify.PagingInfo]::new($result)
            } Else {
                # If there is no HREF property then it is likely a multi page object.
                # It has members like artists, albums or tracks that contain PagingInfo objects.
                $type = $result | Get-Member | Where-Object { $_.MemberType -eq 'NoteProperty' } | Select-Object -ExpandProperty Name
                $type = $type -replace 's$',''  # Remove plural form 's'.
                $pagingObject = [NewGuy.PoshSpotify.PagingInfo]::new($result, [Enum]::Parse([NewGuy.PoshSpotify.ItemType], $type, $true))
            }

        } ElseIf ($RetrieveMode -eq 'PreviousPage') {

            If (($PagingInfo.PreviousPage -eq '') -or ($PagingInfo.PreviousPage -eq $null)) { $path = $PagingInfo.FullDetailUri }
            Else { $path = $PagingInfo.PreviousPage }

            $result = Invoke-SpotifyRequest -Method 'GET' -Path $path -AccessToken $AccessToken -SpotifyEnv $SpotifyEnv

            If (($result.href -ne $null) -and ($result.href -ne '')) {
                $pagingObject = [NewGuy.PoshSpotify.PagingInfo]::new($result)
            } Else {
                # If there is no HREF property then it is likely a multi page object.
                # It has members like artists, albums or tracks that contain PagingInfo objects.
                $type = $result | Get-Member | Where-Object { $_.MemberType -eq 'NoteProperty' } | Select-Object -ExpandProperty Name
                $type = $type -replace 's$',''  # Remove plural form 's'.
                $pagingObject = [NewGuy.PoshSpotify.PagingInfo]::new($result, [Enum]::Parse([NewGuy.PoshSpotify.ItemType], $type, $true))
            }

        } ElseIf ($RetrieveMode -eq 'AllPages') {

            # We always start with a fresh paging object on the first page.
            $pagingObject = [NewGuy.PoshSpotify.PagingInfo]::new()
            $pagingObject.FullDetailUri = $PagingInfo.FullDetailUri
            $pagingObject.Total = $PagingInfo.Total
            $newPage = $pagingObject

            # TODO : Find away to determine type based max limits and use maximum limit on calls to reduce number of calls to Spotify API.

            Do {
                $currPage = $newPage
                $newPage = Get-SpotifyPage -PagingInfo $currPage -RetrieveMode NextPage -AccessToken $AccessToken -SpotifyEnv $SpotifyEnv
                $pagingObject.Items += $newPage.Items
            } While ($newPage.NextPage.Length -gt 0)

        }

        Return $pagingObject

    }

}

Export-ModuleMember -Function 'Get-SpotifyPage'

#endregion Get-SpotifyPage

#====================================================================================================================================================
#####################
## New-SpotifyPage ##
#####################

#region New-SpotifyPage

Function New-SpotifyPage {

    <#

        .SYNOPSIS

            Creates a new Spotify API Paging Object.

        .DESCRIPTION

            Creates a new Spotify API Paging Object. This command does not make any Spotify API calls but merely creates a Spotify API Paging Object
            represented in this module as a PagingInfo object. This is mostly used by internal commands but can be used Get-SpotifyPage to craft
            custom Spotify API calls that will return paging objects.

            For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

                Spotify Web API : https://developer.spotify.com/web-api/object-model/#paging-object

        .PARAMETER PagingInfo

            If a PagingInfo object is provided then a new PagingInfo object with the same values will be returned.

        .PARAMETER Path

            The Spotify API path for a given API call. This API call should return a Spotify API Paging Objects.

            EX: '/v1/me/playlists'

        .PARAMETER Limit

            The maximum number of items to return. Default: <Depends on the Spotify API call>. Minimum: 1. Maximum: <Depends on the Spotify API call>.

        .PARAMETER Offset

            The index of the first playlist to return. Default: 0 (the first object). Maximum offset: <Depends on the Spotify API call>. Use with
            limit to get the next set of items.

    #>

    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType('NewGuy.PoshSpotify.PagingInfo')]

    Param([Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'PagingInfo')] [NewGuy.PoshSpotify.PagingInfo]$PagingInfo,
          [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Path')][ValidateNotNullOrEmpty()] [string]$Path,
          [Parameter(ParameterSetName = 'Path')] [int]$Limit,
          [Parameter(ParameterSetName = 'Path')] [int]$Offset)

    Process {

        # Clone the given PagingInfo object.
        If ($PSCmdlet.ParameterSetName -eq 'PagingInfo') {

            $pagingObject = [NewGuy.PoshSpotify.PagingInfo]::new()
            $pagingObject.FullDetailUri = $PagingInfo.FullDetailUri
            $pagingObject.Limit = $PagingInfo.Limit
            $pagingObject.Offset = $PagingInfo.Offset
            $pagingObject.Total = $PagingInfo.Total
            $pagingObject.NextPage = $PagingInfo.NextPage
            $pagingObject.PreviousPage = $PagingInfo.PreviousPage
            ## TODO : Would need a deep clone to copy Items property.

        # Build a new PagingInfo object from the given parameters.
        } Else {

            $pagingObject = [NewGuy.PoshSpotify.PagingInfo]::new()
            $params = @{}
            $queryStr = ''

            # Build FullDetailUri property from path and parameters.
            If ($PSBoundParameters['Limit']) { $params['limit'] = $Limit }
            If ($PSBoundParameters['Offset']) { $params['offset'] = $Offset }

            If ($params.Count -gt 0) {
                $queryParams = Get-SpotifyEncodedParameter -RequestParameters $params -Encoding UrlEncoding
                $queryStr = '?' + $queryParams
            }

            # Add a leading slash to the path if not present unless it's full URL.
            If (($Path -notmatch '^/') -and ($Path -notmatch '^https?://')) { $Path = '/' + $Path }

            $pagingObject.FullDetailUri = 'https://' + $script:SpotifyWebApiHostname + $Path + $queryStr

            If ($PSBoundParameters['Limit']) { $pagingObject.Limit = $Limit }
            If ($PSBoundParameters['Offset']) { $pagingObject.Offset = $Offset }

        }

        Return $pagingObject

    }

}

Export-ModuleMember -Function 'New-SpotifyPage'

#endregion New-SpotifyPage

#endregion Spotify PagingInfo API Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
