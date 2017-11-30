<#

    This file should contain the Spotify environment info. For details on the proper format of the hashtables below please see the README file.

#>

# A hashtable key used to get the default Spotify environment configuration that will be used for API requests when one is not given by the user.
# This will be set when configuring the module. (Set-SpotifyEnvironmentInfo, Import-SpotifyEnvironmentInfo)
$script:SpotifyDefaultEnv = 'Home'

# A hashtable of one or more Spotify environment configurations that will be used for API requests.
# This will be set when configuring the module. (Set-SpotifyEnvironmentInfo, Import-SpotifyEnvironmentInfo)
$script:SpotifyEnvironmentInfo = @{

    Home = @{

        # Required Keys.

        ClientId = 'yourClientIdHere'
        SecretKeyEncrypted = 'Big long protected SecureString converted to a standard string (though encrypted) all on one line here'

        # Optional keys.

        CallbackUrl = 'http://localhost:8080/callback/'
        DefaultScopes = @(
            'playlist-read-private',
            'playlist-read-collaborative',
            'playlist-modify-public',
            'playlist-modify-private',
            'ugc-image-upload',
            'user-follow-modify',
            'user-follow-read',
            'user-library-read',
            'user-library-modify',
            'user-read-private',
            'user-read-birthdate',
            'user-read-email',
            'user-top-read',
            'user-read-playback-state',
            'user-modify-playback-state',
            'user-read-currently-playing',
            'user-read-recently-played'
        )  # Basically all scopes possible.

        # ProxyServer = 'your-proxy-01.domain.local'
        # ProxyPort = 8080
        # ProxyBypassList = @('*.domain.local', '*.otherdomain.local')
        # ProxyBypassOnLocal = $true
        # ProxyUsername = 'janedoe'
        # ProxyPassword = 'YourProxySecretsHere'

    }

    # Work = @{

    #     # Required Keys.

    #     ClientId = 'yourClientIdHere'
    #     SecretKeyEncrypted = 'Big long protected SecureString converted to a standard string (though encrypted) all on one line here'

    #     # Optional keys.

    #     CallbackUrl = 'http://localhost:8080/callback/'
    #     DefaultScopes = @(
    #         'playlist-read-private',
    #         'playlist-read-collaborative',
    #         'playlist-modify-public',
    #         'playlist-modify-private',
    #         'ugc-image-upload',
    #         'user-follow-modify',
    #         'user-follow-read',
    #         'user-library-read',
    #         'user-library-modify',
    #         'user-read-private',
    #         'user-read-birthdate',
    #         'user-read-email',
    #         'user-top-read',
    #         'user-read-playback-state',
    #         'user-modify-playback-state',
    #         'user-read-currently-playing',
    #         'user-read-recently-played'
    #     )  # Basically all scopes possible.

    #     # ProxyServer = 'your-proxy-01.domain.local'
    #     # ProxyPort = 8080
    #     # ProxyBypassList = @('*.domain.local', '*.otherdomain.local')
    #     # ProxyBypassOnLocal = $true
    #     # ProxyUsername = 'janedoe'
    #     # ProxyPasswordEncrypted = 'Big long protected SecureString converted to a standard string (though encrypted) all on one line here'

    # }

    # Test = @{

    #     # Required Keys.

    #     ClientId = 'yourClientIdHere'
    #     SecretKey = 'YourSecretsHere'

    #     # Optional keys.

    #     CallbackUrl = 'http://localhost:8080/callback/'
    #     DefaultScopes = @(
    #         'user-modify-playback-state',
    #         'user-read-playback-state',
    #         'user-read-private'
    #     )

    #     # ProxyServer = 'your-proxy-01.domain.local'
    #     # ProxyPort = 8080
    #     # ProxyBypassList = @('*.domain.local', '*.otherdomain.local')
    #     # ProxyBypassOnLocal = $true
    #     # ProxyUseDefaultCredentials = $true

    # }
}