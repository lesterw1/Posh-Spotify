<#

    This file should contain the Spotify environment info. For details on the proper format of the hashtables below please see the README file.

#>

# If the -SpotifyEnv parameter is not used during an API call then the SpotifyDefaultEnv value below will be used to determine which Spotify
# environment configuration to use.
$script:SpotifyDefaultEnv = 'Prod'

$script:SpotifyEnvironmentInfo = @{

    Prod = @{

        # Required Keys.

        ClientId = 'xxxxxxxxxxxxxxxxxxxx'
        SecretKey = 'YourSecretsHere'

        # Optional keys.

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
        SecretKeyEncrypted = 'Big long protected SecureString represented as a string on 1 line here'

        # Optional keys.

        # ProxyServer = 'your-proxy-01.domain.local'
        # ProxyPort = 8080
        # ProxyBypassList = @('*.domain.local', '*.otherdomain.local')
        # ProxyBypassOnLocal = $true
        # ProxyUsername = 'janedoe'
        # ProxyPasswordEncrypted = 'Big long protected SecureString represented as a string on 1 line here'

    }

    Dev = @{

        # Required Keys.

        ClientId = 'xxxxxxxxxxxxxxxxxxxx'
        SecretKeyEncrypted = 'Big long protected SecureString represented as a string on 1 line here'

        # Optional keys.

        # ProxyServer = 'your-proxy-01.domain.local'
        # ProxyPort = 8080
        # ProxyBypassList = @('*.domain.local', '*.otherdomain.local')
        # ProxyBypassOnLocal = $true
        # ProxyUseDefaultCredentials = $true

    }
}