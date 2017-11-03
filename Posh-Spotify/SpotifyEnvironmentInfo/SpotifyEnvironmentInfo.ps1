<#

    This file should contain the Spotify environment info. For details on the proper format of the hashtables below please see the README file.

#>

# A hashtable key used to get the default Spotify environment configuration that will be used for API requests when one is not given by the user.
# This will be set when configuring the module. (Set-SpotifyEnvironmentInfo, Import-SpotifyEnvironmentInfo)
$script:SpotifyDefaultEnv = 'Prod'

# A hashtable of one or more Spotify environment configurations that will be used for API requests.
# This will be set when configuring the module. (Set-SpotifyEnvironmentInfo, Import-SpotifyEnvironmentInfo)
$script:SpotifyEnvironmentInfo = @{

    Prod = @{

        # Required Keys.

        ClientId = 'xxxxxxxxxxxxxxxxxxxx'
        SecretKey = 'YourSecretsHere'

        # Optional keys.

        CallbackUrl = 'http://localhost:8080/callback/'
        Scopes = @(
            'user-modify-playback-state',
            'user-read-playback-state',
            'user-read-private',
            'user-modify-playback-state',
            'user-read-playback-state',
            'user-read-private'
        )

        # ProxyServer = 'your-proxy-01.domain.local'
        # ProxyPort = 8080
        # ProxyBypassList = @('*.domain.local', '*.otherdomain.local')
        # ProxyBypassOnLocal = $true
        # ProxyUsername = 'janedoe'
        # ProxyPassword = 'YourProxySecretsHere'

    }

    Test = @{

        # Required Keys.

        ClientId = 'xxxxxxxxxxxxxxxxxxxx'
        SecretKeyEncrypted = 'Big long protected SecureString converted to a standard string (though encrypted) all on one line here'

        # Optional keys.

        CallbackUrl = 'http://localhost:8080/callback/'
        Scopes = @(
            'user-modify-playback-state',
            'user-read-playback-state',
            'user-read-private',
            'user-modify-playback-state',
            'user-read-playback-state',
            'user-read-private'
        )

        # ProxyServer = 'your-proxy-01.domain.local'
        # ProxyPort = 8080
        # ProxyBypassList = @('*.domain.local', '*.otherdomain.local')
        # ProxyBypassOnLocal = $true
        # ProxyUsername = 'janedoe'
        # ProxyPasswordEncrypted = 'Big long protected SecureString converted to a standard string (though encrypted) all on one line here'

    }

    Dev = @{

        # Required Keys.

        ClientId = 'xxxxxxxxxxxxxxxxxxxx'
        SecretKeyEncrypted = 'Big long protected SecureString converted to a standard string (though encrypted) all on one line here'

        # Optional keys.

        CallbackUrl = 'http://localhost:8080/callback/'
        Scopes = @(
            'user-modify-playback-state',
            'user-read-playback-state',
            'user-read-private',
            'user-modify-playback-state',
            'user-read-playback-state',
            'user-read-private'
        )

        # ProxyServer = 'your-proxy-01.domain.local'
        # ProxyPort = 8080
        # ProxyBypassList = @('*.domain.local', '*.otherdomain.local')
        # ProxyBypassOnLocal = $true
        # ProxyUseDefaultCredentials = $true

    }
}