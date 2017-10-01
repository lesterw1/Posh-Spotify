# User agent used during Spotify Auth API requests.
$script:SpotifyUserAgent = 'Posh-Spotify/0.1'

# Buffer size used when using the -ReturnRawBytes switch on some commands.
$script:SpotifyBufferSize = 8192

# Spotify Web API Hostname
$script:SpotifyWebApiHostname = 'api.spotify.com'

# Spotify Accounts API Hostname
$script:SpotifyAccountsApiHostname = 'accounts.spotify.com'

#====================================================================================================================================================

# Default Use Session Management

# Authentication Token
$script:SpotifyDefaultAuthenticationToken = $null

# Current Spotify Environment Info
$script:SpotifyDefaultEnvironmentInfo = $null