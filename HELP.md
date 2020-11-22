# Documentation for Posh-Spotify
This is the combined documentation for the Posh-Spotify cmdlets.
<br/>Last updated on Sunday 11/22/2020 10:41 UTC
<br/><br/>

| Cmdlet | Synopsis |
| --- | --- |
| [Add-SpotifyCommandAlias](#add-spotifycommandalias) | Adds command aliases to the local PowerShell session. |
| [Add-SpotifyPlaylistTrack](#add-spotifyplaylisttrack) | Add tracks to the provided playlist. |
| [Add-SpotifyUserSession](#add-spotifyusersession) | Adds the provided user session information to the Spotify environment configuration. |
| [Get-SpotifyAlbum](#get-spotifyalbum) | Get information about the specified album(s). |
| [Get-SpotifyArtist](#get-spotifyartist) | Get information about the specified artist(s). |
| [Get-SpotifyCurrentPlayerContext](#get-spotifycurrentplayercontext) | Get the player context of the currently active player on the userâ€™s Spotify account. The player context details what is playing (Album,Artist, Playlist) and the current progress of that context (i.e. IsPlaying, Track, Progress). |
| [Get-SpotifyDefaultSession](#get-spotifydefaultsession) | Get the current default session information with Spotify. |
| [Get-SpotifyDevice](#get-spotifydevice) | Get information about a userâ€™s available devices. |
| [Get-SpotifyEnvironmentInfo](#get-spotifyenvironmentinfo) | Returns the current SpotifyEnvironmentInfo configuration. |
| [Get-SpotifyPage](#get-spotifypage) | Gets items for a Spotify API Paging Object. By default will retrieve the next available page. If specified can also retrieve the previouspage or all page object items from all pages. |
| [Get-SpotifyPlayer](#get-spotifyplayer) | Get information about the userâ€™s current playback state, including track, track progress, and active device. |
| [Get-SpotifyPlaylist](#get-spotifyplaylist) | Get a list of the playlists owned or followed by the given Spotify user or current user if none is given. |
| [Get-SpotifySearch](#get-spotifysearch) | Get Spotify catalog information about artists, albums, tracks or playlists that match a keyword string. |
| [Get-SpotifyTrack](#get-spotifytrack) | Get information about the specified track(s). |
| [Import-SpotifyEnvironmentInfo](#import-spotifyenvironmentinfo) | Loads the environment information with Spotify. |
| [Initialize-SpotifyAuthorizationCodeFlow](#initialize-spotifyauthorizationcodeflow) | Initializes a Spotify session using the Authorization Code Flow. If the user accepts and the authorization is successful an Access Tokenwill be returned allowing API access to Spotify commands. |
| [Initialize-SpotifySession](#initialize-spotifysession) | Initializes the user session information and authenticates with Spotify. |
| [Invoke-SpotifyRequest](#invoke-spotifyrequest) | Generates and sends a new Spotify API request. |
| [New-SpotifyPage](#new-spotifypage) | Creates a new Spotify API Paging Object. |
| [New-SpotifyPlaylist](#new-spotifyplaylist) | Creates a new Spotify playlist. |
| [Save-SpotifyEnvironmentInfo](#save-spotifyenvironmentinfo) | Saves the current environment information with Spotify. |
| [Set-SpotifyEnvironmentInfo](#set-spotifyenvironmentinfo) | Sets the current SpotifyEnvironmentInfo configuration. |
| [Set-SpotifyEnvironmentProxy](#set-spotifyenvironmentproxy) | Sets the proxy server information for a given Spotify environment configuration. |
| [Set-SpotifyPlayer](#set-spotifyplayer) | Transfer playback to a new device and determine if it should start playing. |
| [Set-SpotifyPlayerRepeatMode](#set-spotifyplayerrepeatmode) | Set the repeat mode for the userâ€™s playback. Options are Repeat Track, Repeat Context or Off. |
| [Set-SpotifyPlayerShuffleMode](#set-spotifyplayershufflemode) | Toggle shuffle on or off for userâ€™s playback. |
| [Set-SpotifyPlayerVolume](#set-spotifyplayervolume) | Set the volume for the userâ€™s current playback device. |
| [Set-SpotifyPlaylist](#set-spotifyplaylist) | Sets a Spotify playlist to the provided settings. |
| [Set-SpotifyTrackSeek](#set-spotifytrackseek) | Seeks to the given position in the userâ€™s currently playing track. |
| [Skip-SpotifyNextTrack](#skip-spotifynexttrack) | Skips to next track in the userâ€™s queue. |
| [Skip-SpotifyPreviousTrack](#skip-spotifyprevioustrack) | Skips to previous track in the userâ€™s queue. |
| [Start-SpotifyPlayback](#start-spotifyplayback) | Start a new context or resume current playback on the userâ€™s active device. |
| [Stop-SpotifyPlayback](#stop-spotifyplayback) | Pause playback on the userâ€™s account. |

---

## Add-SpotifyCommandAlias

### Synopsis

Adds command aliases to the local PowerShell session.

### Syntax

Add-SpotifyCommandAlias [[-Aliases] <String[]>] [<CommonParameters>]

### Description

Adds command aliases to the local PowerShell session such as "Play", "Pause", "Skip", "SkipBack", etc.

### Parameters

	-Aliases <String[]>
	    List of aliases to make available to the local PowerShell session. If empty all aliases will be added. Possible values include:
	    
	        Play - Starts playback of music on the current player device.
	        Pause - Pauses playback of music on the current player device.
	        Skip - Skips to the next track.
	        NextTrack - Skips to the next track.
	        SkipBack - Skips back to the previous track.
	        PreviousTrack - Skips back to the previous track.
	        Player - Returns the currently active player.



---
## Add-SpotifyPlaylistTrack

### Synopsis

Add tracks to the provided playlist.

### Syntax

Add-SpotifyPlaylistTrack -Id <String> -TrackUri <String[]> [-Position <Int32>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Add-SpotifyPlaylistTrack -Id <String> -Track <Track[]> [-Position <Int32>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

### Description

Add tracks to the provided playlist.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/playlists/add-tracks-to-playlist/

### Parameters

	-Id <String>
	    The Spotify ID for the playlist the provided tracks will be added to.

	-TrackUri <String[]>

	-Track <Track[]>

	-Position <Int32>
	    The position to insert the tracks, a zero-based index. For example, to insert the tracks in the first position specify 0 To insert the
	    tracks in the third position specify 2. If omitted, the tracks will be appended to the playlist. Tracks are added in the order they are
	    listed in the array provided to this command.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "playlist-modify-public" and "playlist-modify-private" scope authorized in order to add tracks.



---
## Add-SpotifyUserSession

### Synopsis

Adds the provided user session information to the Spotify environment configuration.

### Syntax

Add-SpotifyUserSession [[-RefreshToken] <String>] [[-AccessToken] <String>] [[-ExpiresOn] <DateTime>] [-MakeDefault] [-SpotifyEnv <String>] [<CommonParameters>]

Add-SpotifyUserSession [[-AuthenticationToken] <AuthenticationToken>] [-MakeDefault] [-SpotifyEnv <String>] [<CommonParameters>]

### Description

Adds the provided user session information to the Spotify environment configuration. To obtain user session information you must first
authenticate using one of the three Spotify authentication workflows. You can use one of the commands that comes with this modules to do
so (ex. Initialize-SpotifyAuthorizationCodeFlow).

Each Spotify environment configuration can contain an array of user sessions. The first user session in the array is used by default
when its associated environment configuration is being used to make API requests. You can manage the user session array in each
environment configuration by retrieving, modifying and setting back the current environment configuration. However, most will only ever
want to add user sessions so this command will simplify that process.

For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

### Parameters

	-RefreshToken <String>
	    The Refresh Token used to retrieve new Access Tokens. Refresh Tokens can be retrieved using the Initialize-SpotifyAuthorizationCodeFlow
	    command.

	-AccessToken <String>
	    The current Access Token for making Spotify API calls.

	-ExpiresOn <DateTime>
	    The DateTime in which the Access Token will expire.

	-AuthenticationToken <AuthenticationToken>
	    An AuthenticationToken object. AuthenticationTokens can be retrieved using one of the authentication commands such as the
	    Initialize-SpotifyAuthorizationCodeFlow command.

	-MakeDefault <SwitchParameter>
	    Sets the provided user session information as the first user session in the Spotify environment configuration which makes it the default.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.



---
## Get-SpotifyAlbum

### Synopsis

Get information about the specified album(s).

### Syntax

Get-SpotifyAlbum [-Id] <String[]> [[-Market] <String>] [[-SpotifyEnv] <String>] [[-AccessToken] <String>] [<CommonParameters>]

### Description

Get information about the specified album(s). An Access Token is required for this API call.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/albums/get-several-albums/

### Parameters

	-Id <String[]>
	    The Spotify Id of the album(s) to get information for. Maximum: 20 IDs.

	-Market <String>
	    An ISO 3166-1 alpha-2 country code. Provide this parameter if you want to apply Track Relinking. Use "from_token" to specify the country
	    code of the user associated with the given Access Token.
	    
	    https://developer.spotify.com/documentation/general/guides/track-relinking-guide/

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.



---
## Get-SpotifyArtist

### Synopsis

Get information about the specified artist(s).

### Syntax

Get-SpotifyArtist [-Id] <String[]> [[-SpotifyEnv] <String>] [[-AccessToken] <String>] [<CommonParameters>]

### Description

Get information about the specified artist(s). An Access Token is required for this API call.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/artists/get-several-artists/

### Parameters

	-Id <String[]>
	    The Spotify Ids of the artist(s) to get information for. Maximum: 50 IDs.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.



---
## Get-SpotifyCurrentPlayerContext

### Synopsis

Get the player context of the currently active player on the userâ€™s Spotify account. The player context details what is playing (Album,
Artist, Playlist) and the current progress of that context (i.e. IsPlaying, Track, Progress).

### Syntax

Get-SpotifyCurrentPlayerContext [[-Market] <String>] [[-SpotifyEnv] <String>] [[-AccessToken] <String>] [<CommonParameters>]

### Description

Get the player context of the currently active player on the userâ€™s Spotify account. The player context details what is playing (Album,
Artist, Playlist) and the current progress of that context (i.e. IsPlaying, Track, Progress). An Access Token is required for this API
call.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/web-api/get-the-users-currently-playing-track/

### Parameters

	-Market <String>
	    An ISO 3166-1 alpha-2 country code. Provide this parameter if you want to apply Track Relinking. Use "from_token" to specify the country
	    code of the user associated with the given Access Token.
	    
	    https://developer.spotify.com/documentation/general/guides/track-relinking-guide/

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "user-read-currently-playing" and/or "user-read-playback-state" scope authorized in order to read
	    information.



---
## Get-SpotifyDefaultSession

### Synopsis

Get the current default session information with Spotify.

### Syntax

Get-SpotifyDefaultSession [-RefreshIfExpired] [[-SpotifyEnv] <String>] [<CommonParameters>]

### Description

Get the current default session information with Spotify. Includes information such as Refresh and Access token. Each Spotify environment
configuration can have zero or more user sessions where the first session in the array is considered to be default.

### Parameters

	-RefreshIfExpired <SwitchParameter>
	    If the default session is expired, attempt to re-initialize the session.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.



---
## Get-SpotifyDevice

### Synopsis

Get information about a userâ€™s available devices.

### Syntax

Get-SpotifyDevice [[-SpotifyEnv] <String>] [[-AccessToken] <String>] [<CommonParameters>]

### Description

Get information about a userâ€™s available devices. An Access Token is required for this API call.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/player/get-a-users-available-devices/

### Parameters

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "user-read-playback-state" scope authorized in order to read information.



---
## Get-SpotifyEnvironmentInfo

### Synopsis

Returns the current SpotifyEnvironmentInfo configuration.

### Syntax

Get-SpotifyEnvironmentInfo [<CommonParameters>]

### Description

Returns the current SpotifyEnvironmentInfo configuration.

For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

### Parameters



---
## Get-SpotifyPage

### Synopsis

Gets items for a Spotify API Paging Object. By default will retrieve the next available page. If specified can also retrieve the previous
page or all page object items from all pages.

### Syntax

Get-SpotifyPage [-PagingInfo] <PagingInfo> [[-RetrieveMode] <String>] [[-SpotifyEnv] <String>] [[-AccessToken] <String>] [<CommonParameters>]

### Description

Gets items for a Spotify API Paging Object. By default will retrieve the next available page. If specified can also retrieve the previous
page or all page object items from all pages. An Access Token is required for this API call.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/object-model/#paging-object

### Parameters

	-PagingInfo <PagingInfo>
	    The PagingInfo object from which to retrieve more items.

	-RetrieveMode <String>
	    The page to retrieve. Valid values are NextPage, PreviousPage, AllPages. Default is NextPage.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.



---
## Get-SpotifyPlayer

### Synopsis

Get information about the userâ€™s current playback state, including track, track progress, and active device.

### Syntax

Get-SpotifyPlayer [[-Market] <String>] [[-SpotifyEnv] <String>] [[-AccessToken] <String>] [<CommonParameters>]

### Description

Get information about the userâ€™s current playback state, including track, track progress, and active device. An Access Token is required
for this API call.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/web-api/get-information-about-the-users-current-playback/

### Parameters

	-Market <String>
	    An ISO 3166-1 alpha-2 country code. Provide this parameter if you want to apply Track Relinking. Use "from_token" to specify the country
	    code of the user associated with the given Access Token.
	    
	    https://developer.spotify.com/documentation/general/guides/track-relinking-guide/

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "user-read-playback-state" scope authorized in order to read information.



---
## Get-SpotifyPlaylist

### Synopsis

Get a list of the playlists owned or followed by the given Spotify user or current user if none is given.

### Syntax

Get-SpotifyPlaylist [-PageResults] [-Limit <Int32>] [-Offset <Int32>] [-SkipTrackRetrieval] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Get-SpotifyPlaylist [-Id <String>] [-PageResults] [-Limit <Int32>] [-Offset <Int32>] [-SkipTrackRetrieval] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Get-SpotifyPlaylist [-UserId <String>] [-PageResults] [-Limit <Int32>] [-Offset <Int32>] [-SkipTrackRetrieval] [-SpotifyEnv <String>] [-AccessToken <String>] 
[<CommonParameters>]

### Description

Get a list of the playlists owned or followed by the given Spotify user or current user if none is given. An Access Token is required for
this API call.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/playlists/get-a-list-of-current-users-playlists/
                      https://developer.spotify.com/documentation/web-api/reference/playlists/get-list-users-playlists/

### Parameters

	-Id <String>
	    The Spotify ID for the requested playlist. If one is not provided, all playlists will be returned.

	-UserId <String>
	    The user's Spotify Id used to retrieve playlist information. If none is provided the current user will be used.

	-PageResults <SwitchParameter>
	    The results will be limited to the range specified by the Limit and Offset parameters.
	    
	    NOTE: Spotify API has limits on the number of items that can be returned in a single request as well as limits on the number of requests
	    that can be made in a short period of time. By default this command will retrieve all items available which may result in multiple
	    requests to the Spotify API. Spotify API rate limits may apply. For more details see the following:
	    
	        https://developer.spotify.com/documentation/web-api/#rate-limiting

	-Limit <Int32>
	    The maximum number of playlists to return. Default: 20. Minimum: 1. Maximum: 50.

	-Offset <Int32>
	    The index of the first playlist to return. Default: 0 (the first object). Maximum offset: 100,000. Use with limit to get the next set of
	    playlists.

	-SkipTrackRetrieval <SwitchParameter>
	    Track objects will not be retrieved for each Playlist.
	    
	    NOTE: Spotify API has limits on the number of items that can be returned in a single request as well as limits on the number of requests
	    that can be made in a short period of time. By default this command will retrieve all items available which may result in multiple
	    requests to the Spotify API. Spotify API rate limits may apply. For more details see the following:
	    
	        https://developer.spotify.com/documentation/web-api/#rate-limiting

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    Private playlists are only retrievable for the current user and requires the "playlist-read-private" scope to have been authorized by the
	    user. Note that this scope alone will not return collaborative playlists, even though they are always private. Collaborative playlists are
	    only retrievable for the current user and requires the "playlist-read-collaborative" scope to have been authorized by the user.



---
## Get-SpotifySearch

### Synopsis

Get Spotify catalog information about artists, albums, tracks or playlists that match a keyword string.

### Syntax

Get-SpotifySearch [-Query] <String> [[-Type] <String[]>] [[-Market] <String>] [[-Limit] <Int32>] [[-Offset] <Int32>] [[-SpotifyEnv] <String>] [[-AccessToken] <String>] 
[<CommonParameters>]

### Description

Get Spotify catalog information about artists, albums, tracks or playlists that match a keyword string. An Access Token is required for
this API call.

If "from_token" is supplied to the Market parameter, the current user must have authorized the "user-read-private" scope.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/search/search/

### Parameters

	-Query <String>
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

	-Type <String[]>
	    An array of item types to search across. Valid types are: Album, Artist, Playlist, and Track. If no Type is given the default will be
	    Track and only Track objects will be returned.
	    
	    Search results will include hits from all the specified item types; for example a query of 'name:abacab' and types of @(Album, Track) will
	    return both albums and tracks with 'abacab' in their name.

	-Market <String>
	    An ISO 3166-1 alpha-2 country code or the string from_token.
	    
	    If a country code is given, only artists, albums, and tracks with content playable in that market will be returned. (Playlist results are
	    not affected by the market parameter.)
	    
	    If "from_token" is given and a valid access token is supplied, only items with content playable in the country associated with the user's
	    account will be returned. (The country associated with the user's account can be viewed by the user in their account settings at
	    https://www.spotify.com/se/account/overview/). Note that the user must have granted access to the "user-read-private" scope when the
	    access token was issued.

	-Limit <Int32>
	    The maximum number of results to return. Default: 20. Minimum: 1. Maximum: 50.

	-Offset <Int32>
	    The index of the first result to return. Default: 0 (i.e., the first result). Maximum offset: 100.000. Use with limit to get the next page
	    of search results.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    If Market parameter is "from_token", the current user must have authorized the "user-read-private" scope.



---
## Get-SpotifyTrack

### Synopsis

Get information about the specified track(s).

### Syntax

Get-SpotifyTrack [-Id] <String[]> [[-Market] <String>] [[-SpotifyEnv] <String>] [[-AccessToken] <String>] [<CommonParameters>]

### Description

Get information about the specified track(s). An Access Token is required for this API call.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/tracks/get-several-tracks/

### Parameters

	-Id <String[]>
	    The Spotify Ids of the track(s) to get information for. Maximum: 50 IDs.

	-Market <String>
	    An ISO 3166-1 alpha-2 country code. Provide this parameter if you want to apply Track Relinking. Use "from_token" to specify the country
	    code of the user associated with the given Access Token.
	    
	    https://developer.spotify.com/documentation/general/guides/track-relinking-guide/

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.



---
## Import-SpotifyEnvironmentInfo

### Synopsis

Loads the environment information with Spotify.

### Syntax

Import-SpotifyEnvironmentInfo [[-FilePath] <String>] [<CommonParameters>]

### Description

Loads the environment information with Spotify.

### Parameters

	-FilePath <String>
	    The path to load the environment information with Spotify from.



---
## Initialize-SpotifyAuthorizationCodeFlow

### Synopsis

Initializes a Spotify session using the Authorization Code Flow. If the user accepts and the authorization is successful an Access Token
will be returned allowing API access to Spotify commands.

### Syntax

Initialize-SpotifyAuthorizationCodeFlow [-CallbackUrl <String>] [-State <String>] [-Scopes <String[]>] [-ShowDialog] [-SpotifyEnv <String>] [<CommonParameters>]

Initialize-SpotifyAuthorizationCodeFlow [-RefreshToken <String>] [-SpotifyEnv <String>] [<CommonParameters>]

### Description

Initializes a Spotify session using the Authorization Code Flow. If the user accepts and the authorization is successful an Access Token
will be returned allowing API access to Spotify commands. If the user declines or there is an error, null will be returned and an error
written to the error stream.

For details on the Authorization Code Flow see the following for details.

    https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow

### Parameters

	-CallbackUrl <String>
	    The URI to redirect to after the user grants/denies permission. This URI needs to have been entered in the Redirect URI whitelist that you
	    specified when you registered your application. The value of CallbackUrl here must exactly match one of the values you entered when you
	    registered your application, including upper/lowercase, terminating slashes, etc.

	-State <String>
	    The state can be useful for correlating requests and responses. Because your CallbackUrl can be guessed, using a state value can increase
	    your assurance that an incoming connection is the result of an authentication request. If you generate a random string or encode the hash
	    of some client state (e.g., a cookie) in this state variable, you can validate the response to additionally ensure that the request and
	    response originated in the same browser. This provides protection against attacks such as cross-site request forgery. See RFC-6749.
	    
	    By default, this command will generate a new GUID and use that as the state. If you wish no state parameter be sent to the Spotify API,
	    use null or an empty string to disable the feature.

	-Scopes <String[]>
	    A list of scopes for which authorization is being requested.
	    
	    See the Spotify documentation for details: https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes

	-ShowDialog <SwitchParameter>
	    Whether or not to force the user to approve the app again if theyâ€™ve already done so. If false (default), a user who has already approved
	    the application may be automatically redirected to the URI specified by CallbackUrl. If true, the user will not be automatically
	    redirected and will have to approve the app again.

	-RefreshToken <String>
	    If an Access Token was retrieved previously and is now expired, a new Access Token can be retrieved by providing the Refresh Token here.
	    Aside from SpotifyEnv, no other parameters may be specified along with this parameter as they are not valid for a token refresh operation.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.



---
## Initialize-SpotifySession

### Synopsis

Initializes the user session information and authenticates with Spotify.

### Syntax

Initialize-SpotifySession [[-AuthenticationToken] <AuthenticationToken>] [-ForceAuth] [-ForceRefresh] [-PassThru] [[-SpotifyEnv] <String>] [<CommonParameters>]

### Description

Initializes the user session information and authenticates with Spotify. Authentication and authorization will occur in following ways:

- If a previously acquired user session's AuthenticationToken is given, that token will be updated with the newly initialized session. If
  the provided user session has not yet expired it will not be refreshed by default.

- If no user session is not provided then the default user session's AuthenticationToken of the Spotify environment configuration will be
  updated. If the default user session has not yet expired it will not be refreshed by default.

- If the environment does not have any initialized sessions, an entirely new session will be initialized which will result in a user login
  to Spotify via the user's default browser. This process will progress as follows:

    - The user will be directed to the Spotify login page via their default browser where the user will login to Spotify. This module
      will block the return of the command line while this happens. If the user is already logged into Spotify they will be immediately
      directed to the authorization page.

    - After login, the authorization page will ask the user to approve your application (i.e. this module). A list of user permission
      scopes configured through the environment configuration will be presented to the user for approval. If the user has already accepted
      your application and the requested scopes previously, the user will be immediately redirected to your CallbackUrl.

    - After authorization, the user will be directed to your CallbackUrl configured through the environment configuration.

For details on Spotify authentication please see https://github.com/The-New-Guy/Posh-Spotify.

### Parameters

	-AuthenticationToken <AuthenticationToken>
	    An AuthenticationToken object. AuthenticationTokens, which represent user sessions, can be retrieved using one of the authentication
	    commands such as the Initialize-SpotifyAuthorizationCodeFlow command.

	-ForceAuth <SwitchParameter>
	    Forces a full re-authentication with the user which will result in a user login request.

	-ForceRefresh <SwitchParameter>
	    Forces a refresh of the provided user session (AuthenticationToken) or the environment's default user session even if the session has not
	    yet expired. This should only be used if there is a need to refresh the token before it has expired. No user login is required.

	-PassThru <SwitchParameter>
	    If the AuthenticationToken parameter was used, the updated token will be returned to the pipeline.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.



---
## Invoke-SpotifyRequest

### Synopsis

Generates and sends a new Spotify API request.

### Syntax

Invoke-SpotifyRequest [-Path] <String> [-Method] <String> [[-QueryParameters] <Hashtable>] [[-RequestBodyParameters] <Hashtable>] [[-Encoding] <String>] [[-AccessToken] 
<String>] [[-RequestType] <String>] [-ReturnRawBytes] [[-SpotifyEnv] <String>] [<CommonParameters>]

### Description

Generates and sends a new Spotify API request based on the provided parameters. For details on what calls can be made please review the
Spotify documentation found at the following locations.

    Spotify API : https://developer.spotify.com/documentation/web-api/

### Parameters

	-Path <String>
	    The Spotify API path for a given API call.
	    
	    EX: '/v1/browse/categories'

	-Method <String>
	    The HTTP method by which to submit the Spotify API call.
	    
	    EX: 'GET' or 'POST' or 'PUT' or 'DELETE'

	-QueryParameters <Hashtable>
	    A hashtable which contains key/value pairs of each Spotify API request that needs to be encoded and added to the query string of the
	    request (i.e. The parameters are place in the URL of the request).
	    
	    EX: @{
	           country = 'US'
	           locale = 'en_US'
	         }

	-RequestBodyParameters <Hashtable>
	    A hashtable which contains key/value pairs of each Spotify API request that needs to be encoded as JSON and added to the body of the
	    request (i.e. The parameters are place in the the body request as additional content).
	    
	    EX: @{
	           country = 'US'
	           locale = 'en_US'
	         }

	-Encoding <String>
	    The method by which the request body parameters should be encoded. Possible values include:
	    
	         UrlEncoding OR JSON
	    
	    Default value is UrlEncoding.

	-AccessToken <String>
	    If provided, the Authorization header will be of type 'Bearer' and will contain this Access Token. If not provided the Authorization
	    header will be of type 'Basic' and will contain the client id and secret key as specified by the given or default environment
	    configuration.

	-RequestType <String>
	    Specifies the type of Spotify API request. This essentially controls which Spotify API hostname to use. Possible values include:
	    
	         'WebAPI' or 'AccountsAPI'
	    
	    Default is 'WebAPI'.

	-ReturnRawBytes <SwitchParameter>
	    If this switch is set, the response body to the Spotify request will be returned as raw bytes. By default the response is converted from
	    its native JSON format into a PSObject.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.



---
## New-SpotifyPage

### Synopsis

Creates a new Spotify API Paging Object.

### Syntax

New-SpotifyPage -Path <String> [-Limit <Int32>] [-Offset <Int32>] [<CommonParameters>]

New-SpotifyPage -PagingInfo <PagingInfo> [<CommonParameters>]

### Description

Creates a new Spotify API Paging Object. This command does not make any Spotify API calls but merely creates a Spotify API Paging Object
represented in this module as a PagingInfo object. This is mostly used by internal commands but can be used Get-SpotifyPage to craft
custom Spotify API calls that will return paging objects.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/object-model/#paging-object

### Parameters

	-PagingInfo <PagingInfo>
	    If a PagingInfo object is provided then a new PagingInfo object with the same values will be returned.

	-Path <String>
	    The Spotify API path for a given API call. This API call should return a Spotify API Paging Objects.
	    
	    EX: '/v1/me/playlists'

	-Limit <Int32>
	    The maximum number of items to return. Default: <Depends on the Spotify API call>. Minimum: 1. Maximum: <Depends on the Spotify API call>.

	-Offset <Int32>
	    The index of the first playlist to return. Default: 0 (the first object). Maximum offset: <Depends on the Spotify API call>. Use with
	    limit to get the next set of items.



---
## New-SpotifyPlaylist

### Synopsis

Creates a new Spotify playlist.

### Syntax

New-SpotifyPlaylist -Id <String> -Name <String> [-Description <String>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

New-SpotifyPlaylist -Id <String> -Name <String> [-Public] [-Description <String>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

New-SpotifyPlaylist -Id <String> -Name <String> [-Collaborative] [-Description <String>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

### Description

Creates a new Spotify playlist.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/playlists/create-playlist/

### Parameters

	-Id <String>
	    The Spotify ID for the user account the playlist will be created in.

	-Name <String>
	    The name of the new playlist.

	-Public <SwitchParameter>
	    This switch will set the playlist to Public. By default it is will be created as Private.

	-Collaborative <SwitchParameter>
	    This switch will set the playlist to Collaborative. Other users who have access to the playlist URI or are following the playlist will be
	    able to make changes to the playlist. A Collaborative playlist is always private. Therefore a playlist cannot be both Public and
	    Collaborative.

	-Description <String>
	    A description for the new playlist.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "playlist-modify-public" and "playlist-modify-private" scope authorized in order to add tracks.



---
## Save-SpotifyEnvironmentInfo

### Synopsis

Saves the current environment information with Spotify.

### Syntax

Save-SpotifyEnvironmentInfo [[-FilePath] <String>] [-NoTimestampAppend] [<CommonParameters>]

### Description

Saves the current environment information with Spotify.

### Parameters

	-FilePath <String>
	    The path to save the environment information with Spotify to.

	-NoTimestampAppend <SwitchParameter>
	    By default this command appends the current date and time onto the filename of the save. This switch will prevent the appending of the
	    timestamp.



---
## Set-SpotifyEnvironmentInfo

### Synopsis

Sets the current SpotifyEnvironmentInfo configuration.

### Syntax

Set-SpotifyEnvironmentInfo [-SpotifyEnvironmentInfo] <Hashtable> [-SpotifyDefaultEnv] <String> [<CommonParameters>]

### Description

Sets the current SpotifyEnvironmentInfo configuration.

For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

### Parameters

	-SpotifyEnvironmentInfo <Hashtable>
	    The new SpotifyEnvironmentInfo configuration you would like to set.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-SpotifyDefaultEnv <String>
	    The default environment to use in the specified SpotifyEnvironmentInfo configuration. If not specified the current default will remain unchanged.



---
## Set-SpotifyEnvironmentProxy

### Synopsis

Sets the proxy server information for a given Spotify environment configuration.

### Syntax

Set-SpotifyEnvironmentProxy -UseSystemSettings [-Credentials <PSCredential>] [-UseDefaultCredentials] [-SpotifyEnv <String>] [<CommonParameters>]

Set-SpotifyEnvironmentProxy -Server <String> [-Port <Int32>] [-BypassList <Array>] [-BypassOnLocal] [-Credentials <PSCredential>] [-UseDefaultCredentials] [-SpotifyEnv 
<String>] [<CommonParameters>]

### Description

Sets the proxy server information for a given Spotify environment configuration. The specified Spotify configuration must already exist in the current configuration hashtable.

For details on environment configurations and proxy settings please see https://github.com/The-New-Guy/Posh-Spotify.

### Parameters

	-UseSystemSettings <SwitchParameter>
	    If this switch is specified, the command will attempt to retrieve proxy settings from system and then assigns those settings to the specified Spotify environment configuration. The system settings referenced here are typically set via the 'netsh winhttp' command context.
	    
	    NOTE: Depending on your proxy server configuration you may or may not still need to provide credentials when using the system settings or specify the UseDefaultCredentials switch.

	-Server <String>
	    The proxy server hostname that will be used to connect to Spotify.
	    
	    This setting will be assigned to the specified Spotify environment configuration.

	-Port <Int32>
	    The port used to connect to the proxy server.
	    
	    This setting will be assigned to the specified Spotify environment configuration.

	-BypassList <Array>
	    The list of URIs that will not use the proxy server.
	    
	    This setting will be assigned to the specified Spotify environment configuration.

	-BypassOnLocal <SwitchParameter>
	    The switch to indicate whether short name hosts will bypass the proxy. By default this will be set to false.
	    
	    This setting will be assigned to the specified Spotify environment configuration.

	-Credentials <PSCredential>
	    The credentials to be used when authenticating to the proxy server.
	    
	    This setting will be assigned to the specified Spotify environment configuration.

	-UseDefaultCredentials <SwitchParameter>
	    The switch to indicate whether or not to use Windows default credentials when authenticating to the proxy server. By default this will be set to false.
	    
	    This setting will be assigned to the specified Spotify environment configuration.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.



---
## Set-SpotifyPlayer

### Synopsis

Transfer playback to a new device and determine if it should start playing.

### Syntax

Set-SpotifyPlayer [-Play] -DeviceId <String[]> [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Set-SpotifyPlayer [-Play] -Device <Device[]> [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

### Description

Transfer playback to a new device and determine if it should start playing. An Access Token is required for this API call.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/web-api/transfer-a-users-playback/

### Parameters

	-Play <SwitchParameter>
	    If switch is provided, ensures playback happens on new device. If not provided keeps the current playback state.

	-DeviceId <String[]>
	    The device for which this command targets.
	    
	    Currently Spotify API only supports one device ID.

	-Device <Device[]>
	    The device for which this command targets. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects
	    returned from Get-SpotifyPlayer (Player objects contain a Device object).
	    
	    Currently Spotify API only supports one device ID.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.



---
## Set-SpotifyPlayerRepeatMode

### Synopsis

Set the repeat mode for the userâ€™s playback. Options are Repeat Track, Repeat Context or Off.

### Syntax

Set-SpotifyPlayerRepeatMode -State <String> [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Set-SpotifyPlayerRepeatMode -State <String> [-DeviceId <String[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Set-SpotifyPlayerRepeatMode -State <String> [-Device <Device[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

### Description

Set the repeat mode for the userâ€™s playback. Options are Repeat Track, Repeat Context or Off.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/web-api/set-repeat-mode-on-users-playback/

### Parameters

	-State <String>
	    The state of the Repeat feature. Possible values include :
	    
	        Track OR Context OR Off
	    
	    Track will repeat the current track.
	    Context will repeat the current context (album, playlist, etc.).
	    Off will turn repeat off.
	    
	    The default is to set the mode to Track repeat mode.

	-DeviceId <String[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used.
	    
	    Currently Spotify API only supports one device ID.

	-Device <Device[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
	    Get-SpotifyPlayer (Player objects contain a Device object).
	    
	    Currently Spotify API only supports one device ID.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.



---
## Set-SpotifyPlayerShuffleMode

### Synopsis

Toggle shuffle on or off for userâ€™s playback.

### Syntax

Set-SpotifyPlayerShuffleMode -State <String> [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Set-SpotifyPlayerShuffleMode -State <String> [-DeviceId <String[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Set-SpotifyPlayerShuffleMode -State <String> [-Device <Device[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

### Description

Toggle shuffle on or off for userâ€™s playback.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/web-api/toggle-shuffle-for-users-playback/

### Parameters

	-State <String>
	    The state of the Shuffle feature. Possible values include :
	    
	        Enabled OR Disabled
	    
	    Enabled shuffles the user's playback.
	    Disabled does not shuffles the user's playback.
	    
	    The default is to enable the Shuffle feature.

	-DeviceId <String[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used.
	    
	    Currently Spotify API only supports one device ID.

	-Device <Device[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
	    Get-SpotifyPlayer (Player objects contain a Device object).
	    
	    Currently Spotify API only supports one device ID.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.



---
## Set-SpotifyPlayerVolume

### Synopsis

Set the volume for the userâ€™s current playback device.

### Syntax

Set-SpotifyPlayerVolume -Volume <Int32> [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Set-SpotifyPlayerVolume -Volume <Int32> [-DeviceId <String[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Set-SpotifyPlayerVolume -Volume <Int32> [-Device <Device[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

### Description

Set the volume for the userâ€™s current playback device.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/web-api/set-volume-for-users-playback/

### Parameters

	-Volume <Int32>
	    The volume to set. Must be a value from 0 to 100 inclusive.
	    
	    The default is to set the mode to Track repeat mode.

	-DeviceId <String[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used.
	    
	    Currently Spotify API only supports one device ID.

	-Device <Device[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
	    Get-SpotifyPlayer (Player objects contain a Device object).
	    
	    Currently Spotify API only supports one device ID.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.



---
## Set-SpotifyPlaylist

### Synopsis

Sets a Spotify playlist to the provided settings.

### Syntax

Set-SpotifyPlaylist -Id <String> [-Name <String>] [-Description <String>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Set-SpotifyPlaylist -Id <String> [-Name <String>] [-Public] [-Description <String>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Set-SpotifyPlaylist -Id <String> [-Name <String>] [-Private] [-Description <String>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Set-SpotifyPlaylist -Id <String> [-Name <String>] [-Collaborative] [-Description <String>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

### Description

Sets a Spotify playlist to the provided settings.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/documentation/web-api/reference/playlists/change-playlist-details/

### Parameters

	-Id <String>
	    The Spotify ID for the playlist to set.

	-Name <String>
	    The name of the playlist to set.

	-Public <SwitchParameter>
	    This switch will set the playlist to Public.

	-Private <SwitchParameter>
	    This switch will set the playlist to Private.

	-Collaborative <SwitchParameter>
	    This switch will set the playlist to Collaborative. Other users who have access to the playlist URI or are following the playlist will be
	    able to make changes to the playlist. A Collaborative playlist is always private. Therefore a playlist cannot be both Public and
	    Collaborative.

	-Description <String>
	    A description for the playlist to set.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "playlist-modify-public" and "playlist-modify-private" scope authorized in order to add tracks.



---
## Set-SpotifyTrackSeek

### Synopsis

Seeks to the given position in the userâ€™s currently playing track.

### Syntax

Set-SpotifyTrackSeek [-Minutes <Int32>] [-Seconds <Int32>] [-Milliseconds <Int32>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Set-SpotifyTrackSeek [-Minutes <Int32>] [-Seconds <Int32>] [-Milliseconds <Int32>] [-DeviceId <String[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Set-SpotifyTrackSeek [-Minutes <Int32>] [-Seconds <Int32>] [-Milliseconds <Int32>] [-Device <Device[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

### Description

Seeks to the given position in the userâ€™s currently playing track.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/web-api/seek-to-position-in-currently-playing-track/

### Parameters

	-Minutes <Int32>
	    The position in minutes to seek to. Must be a positive number. Passing in a position that is greater than the length of the track
	    will cause the player to start playing the next song.
	    
	    This value will be added to the total if used with other time unit parameters.

	-Seconds <Int32>
	    The position in milliseconds to seek to. Must be a positive number. Passing in a position that is greater than the length of the track
	    will cause the player to start playing the next song.
	    
	    The default is 10s.
	    
	    This value will be added to the total if used with other time unit parameters.

	-Milliseconds <Int32>
	    The position in milliseconds to seek to. Must be a positive number. Passing in a position that is greater than the length of the track
	    will cause the player to start playing the next song.
	    
	    The default is 10,000ms (10s).
	    
	    This value will be added to the total if used with other time unit parameters.

	-DeviceId <String[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used.
	    
	    Currently Spotify API only supports one device ID.

	-Device <Device[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
	    Get-SpotifyPlayer (Player objects contain a Device object).
	    
	    Currently Spotify API only supports one device ID.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.



---
## Skip-SpotifyNextTrack

### Synopsis

Skips to next track in the userâ€™s queue.

### Syntax

Skip-SpotifyNextTrack [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Skip-SpotifyNextTrack [-DeviceId <String[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Skip-SpotifyNextTrack [-Device <Device[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

### Description

Skips to next track in the userâ€™s queue. An Access Token is required for this API call.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/web-api/skip-users-playback-to-next-track/

### Parameters

	-DeviceId <String[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used.
	    
	    Currently Spotify API only supports one device ID.

	-Device <Device[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
	    Get-SpotifyPlayer (Player objects contain a Device object).
	    
	    Currently Spotify API only supports one device ID.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.



---
## Skip-SpotifyPreviousTrack

### Synopsis

Skips to previous track in the userâ€™s queue.

### Syntax

Skip-SpotifyPreviousTrack [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Skip-SpotifyPreviousTrack [-DeviceId <String[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Skip-SpotifyPreviousTrack [-Device <Device[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

### Description

Skips to previous track in the userâ€™s queue.

Note that this will ALWAYS skip to the previous track, regardless of the current trackâ€™s progress. Returning to the start of the current
track should be performed using the Set-SpotifyTrackSeek command.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/web-api/skip-users-playback-to-previous-track/

### Parameters

	-DeviceId <String[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used.
	    
	    Currently Spotify API only supports one device ID.

	-Device <Device[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
	    Get-SpotifyPlayer (Player objects contain a Device object).
	    
	    Currently Spotify API only supports one device ID.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.



---
## Start-SpotifyPlayback

### Synopsis

Start a new context or resume current playback on the userâ€™s active device.

### Syntax

Start-SpotifyPlayback [-ContextUri <String>] [-Tracks <String[]>] [-Offset <String>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Start-SpotifyPlayback [-ContextUri <String>] [-Tracks <String[]>] [-Offset <String>] [-DeviceId <String[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Start-SpotifyPlayback [-ContextUri <String>] [-Tracks <String[]>] [-Offset <String>] [-Device <Device[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

### Description

Start a new context or resume current playback on the userâ€™s active device. An Access Token is required for this API call.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/web-api/start-a-users-playback/

### Parameters

	-ContextUri <String>
	    Spotify URI of the context to play. Valid contexts are albums, artists & playlists.
	    
	        Example: "spotify:album:1Je1IMUlBXcx1Fz0WE7oPT"

	-Tracks <String[]>
	    A JSON array of the Spotify track URIs to play.
	    
	        Example: "spotify:track:4iV5W9uYEdYUVa79Axb7Rh", "spotify:track:1301WleyT98MSxVHPZCA6M"

	-Offset <String>
	    Indicates from where in the context playback should start. Only available when ContextUri corresponds to an album or playlist object, or
	    when the Tracks parameter is used.
	    
	    Provide either a positive integer to specify a "position" within the context or use a Spotify resource uri to specify the item to start at.
	    
	    Example 1: Start at 5th item of play context (album, playlist, etc.). Use this when using the ContextUri parameter.
	    
	        -Offset 5
	    
	    Example 2: Start at specified track uri in provided list of Tracks. Use this when using the Tracks parameter.
	    
	        -Offset "spotify:track:1301WleyT98MSxVHPZCA6M"

	-DeviceId <String[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used.
	    
	    Currently Spotify API only supports one device ID.

	-Device <Device[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
	    Get-SpotifyPlayer (Player objects contain a Device object).
	    
	    Currently Spotify API only supports one device ID.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.



---
## Stop-SpotifyPlayback

### Synopsis

Pause playback on the userâ€™s account.

### Syntax

Stop-SpotifyPlayback [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Stop-SpotifyPlayback [-DeviceId <String[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

Stop-SpotifyPlayback [-Device <Device[]>] [-SpotifyEnv <String>] [-AccessToken <String>] [<CommonParameters>]

### Description

Pause playback on the userâ€™s account. An Access Token is required for this API call.

For details on this Spotify API endpoint and its response format please review the Spotify documentation found at the following locations.

    Spotify Web API : https://developer.spotify.com/web-api/pause-a-users-playback/

### Parameters

	-DeviceId <String[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used.
	    
	    Currently Spotify API only supports one device ID.

	-Device <Device[]>
	    The device for which this command targets. If neither DeviceId nor Device parameters are given then the currently active device of the
	    current user will be used. This parameter accepts either Device objects returned from Get-SpotifyDevice or Player objects returned from
	    Get-SpotifyPlayer (Player objects contain a Device object).
	    
	    Currently Spotify API only supports one device ID.

	-SpotifyEnv <String>
	    A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
	    not specified it will use the current default environment configuration.
	    
	    For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

	-AccessToken <String>
	    The Access Token provided during the authorization process.
	    
	    The Access Token must have the "user-modify-playback-state" scope authorized in order to read information.



---

*This combined documentation page was created using https://github.com/lesterw1/AzureExtensions/tree/master/Ax.Markdown cmdlet.*
