# Posh-Spotify

This is a PowerShell module that contains a set of wrapper functions for retrieving and managing Spotify content via the Spotify Web API. Authentication is required for all Spotify API requests whether you are accessing public resources or not. After authentication you will be provided with a temporary Access Token that must be provided on every API request. The core command this module provides is `Invoke-SpotifyRequest` which will handle the formatting and proper encoding of your Access Token as well as any other parameters needed for the API request. This command can be used for most all Spotify Web API endpoints.

This module also provides a number of commands used to automatically keep track of your current application's credentials, your current Access Token and associated Refresh Token, as well as several commands for initiating authentication and acquiring these tokens. Once the module is configured with these parameters the configurations can be exported to disk in a secure manner allowing you to easily re-import them between PowerShell sessions. See the [Optional Profile Configuration](#Profile) section below for details.

The bulk of the commands provided by this module are wrappers around the individual Spotify Web API endpoints and all use the `Invoke-SpotifyRequest` command mentioned above. Some of the features these additional commands provide are listed below. There are plans to add many more featues later (ex. Playlist Modification, Search Features, etc.). In the meantime any feature this module does not have a command for should be possible via the `Invoke-SpotifyRequest` command and the appropriate Spotify Web API endpoint.

Current Command Support

- Retrieve devices connected to Spotify.
- Control playback of active player (ex. Play/Pause, Volume, Skip/Previous, Shuffle/Repeat, Get Current Track).
- Get detailed artist, album, playlist or track information.

###### ***NOTE**: Use `Invoke-SpotifyRequest` for unsupported features.

Documentation on Spotify Web API can be found at the following locations:

- Spotify API - https://developer.spotify.com/web-api/
- Spotify Authorization - https://developer.spotify.com/web-api/authorization-guide/
- Spotify Scopes - https://developer.spotify.com/web-api/using-scopes/

For details on installing and using this module please refer to the following sections:

- [Register With Spotify](#Register)
- [Installation](#Install)
- [Spotify Environment Configuration](#SpotifyEnvConfig)
- [Spotify Authentication and Access Tokens](#Authentication)
- [Optional Profile Configuration](#Profile)
- [Examples](#Examples)

## <a name="Register"></a> Register With Spotify

Since Spotify Web API requires authentication for all requests you must first authenticate with Spotify in order to retrieve an Access Token that will be used for all API requests. In order to authenticate you must first register with Spotify. Instructions to do so are below:

1. Go to https://developer.spotify.com/my-applications

2. Login. You can either use your standard Spotify account to login or create a new account to be the registered "developer" for the application. The only thing that matters here is that this account will be able to make modifications to the application display, description, client ids/secret, etc. It is the admin of the application registration. If you are using this for personal use then just login with your normal Spotify account.

3. Make sure that *My Applications* is selected on the navigation sidebar on the left. Then click *Create An App* button at the top right.

4. Fill in the desired *Application Name* and *Application Description* and click *Create* button. This information will be visible to any user who registers your application with their account (which will just be you if this is for personal use only).

5. After creating the application registration you will be able to adjust any of the settings from earlier as well as add a *Website* to be displayed with your application. Again, this will only be seen by you if this is for personal use only.

6. Take note of the *Client ID* and *Client Secret* fields as these are the credentials your application will need to authenticate and retrieve an Access Token. See the [Spotify Environment Configuration](#SpotifyEnvConfig) section for details on configuring the module to use these values.

7. Most will also want to add some *Redirect URIs* at this step. The *Authorization Code* (most common) and *Implicit Grant* authorization workflows both require a URI for which the user will be redirected back to after logging in to Spotify. This URI must have an HTTP listener prepared to accept the authorization response and corresponding Access Token. The authentication commands provided by this module will do this for you and use the default value `http://localhost:8080/callback/` if one is not provided. If you plan to use these commands and their defaults add `http://localhost:8080/callback/` as one of the *Redirect URIs*.

For more details on getting started with Spotify Web API see the following: https://developer.spotify.com/web-api/tutorial/

## <a name="Install"></a> Installation

Once you have registered with Spotify you can install the module. If you have not yet registered with Spotify please see the previous section before continuing ([Register With Spotify](#Register)). The module will not work until you have configured it with the proper information retrieved from the Spotify registration process.

1. Download the module (git clone or download the zip).

2. Place the module in your PSModulePath. Read more about PSModulePath [Here](https://msdn.microsoft.com/en-us/library/dd878324%28v=vs.85%29.aspx).

    ``` powershell
    Write-Host $env:PSModulePath
    ```

3. Configure the module using one of the methods detailed in the [Spotify Environment Configuration](#SpotifyEnvConfig) section that follows.

## <a name="SpotifyEnvConfig"></a> Spotify Environment Configuration

### Quick Start

This module has two required pramaters needed for configuration and several optional parameters. There are a few different methods in which these parameters can be configured but the quick start instructions are below. Note that [registration](#Register) of you app is still required.

1. Import the module and configure your ClientId and SecretKey.

```powershell
# Import the module.
Import-Module Posh-Spotify

# Gather your ClientId and SecretKey. It can be plain text or encrypted SecureString as seen below.
$ClientId = 'xxxxxxxxxxxxxxxxxxxx'
$SecretKeyEncrypted = ConvertFrom-SecureString (ConvertTo-SecureString -String 'yourSecretKeyHere' -AsPlainText -Force)

# Get a copy of the default module configuration (includes pre-configured CallbackUrl and Scopes).
$EnvInfo = Get-SpotifyEnvironmentInfo

# Add your ClientId and SecretKey.
$EnvInfo.Home.ClientId = $ClientId
$EnvInfo.Home.SecretKeyEncrypted = $SecretKeyEncrypted

# Set your modified copy of the environment configuration back to the module.
Set-SpotifyEnvironmentInfo $EnvInfo Home
```

2. Initialize a session. This will require user login to Spotify. The command below will open the user's default browser and direct them to the Spotify login page. Once the user has logged in and accepted the requested user permission scopes they will be redirected back to a CallbackUrl. The default for CallbackUrl for this module is `http://localhost:8080/callback/`.

```powershell
Initialize-SpotifySession
```

3. Assuming the user authenticated and accepted the authorization request, your module is now ready to run commands. Try the following to make sure everything works.

```powershell
# List your devices registered with Spotify.
Get-SpotifyDevice

# List your environment and new acquired tokens.
(Get-SpotifyEnvironmentInfo).Home

# List your current default user session.
Get-SpotifyDefaultSession
```

4. Use the following to save your environment configuration and newly acquired AccessToken/RefreshToken pair so that you can easily reload between PowerShell sessions.

```powershell
# This will save your configuration to $env:APPDATA by default.
# Timestamps are added to the end of the filename for saved configuration files by default.
# Use -FilePath to specify a custom location.
Save-SpotifyEnvironmentInfo
```

5. Later you can use the following to reload your configuration in a new PowerShell session.

```powershell
# This will by default look in the $env:APPDATA location for your configuration.
Import-SpotifyEnvironmentInfo

# Run commands.
```

6. **[OPTIONAL]** Add command aliases (ex. Play/Pause, Skip/SkipBack).

```powershell
Add-SpotifyCommandAlias
```

This is just the quick start to getting a personal environment setup and configured. There are many other ways to configure the module and a few more options that can be modified as needed. To get more details on advanced configuration of the module and profile customization continue to the following sections.

### Module Configuration Explanation

**STILL WORKING ON THIS SECTION**


In order to make Spotify API calls this module will need on each request an Access Token


 the *Client ID* and *Secret Key* provided to you for your application during the registration process. If you do not have a Spotify Client ID and Secret Key please refer the previous section, [Register With Spotify](#Register), for details.

For convenience this module will not request this id and secret key on every request but instead will require prior configuration :

- **Spotify API Client ID Key** - Application specific API client id key retrieved from your Spotify Developer registration.
- **Spotify API Secret Key** - Secret key associated with the client id key.

To avoid typing in this information for every Spotify API call, this module will use an internal hashtable to maintain this information for each application environment. The hashtable will support multiple application environments (integration keys) and will support the Spotify Secret Key being stored as either a plain text string or an encrypted SecureString. This hashtable will have the following format where the keys to the main hashtable are the application environments:

``` powershell
SpotifyEnvironmentInfo = @{

    Home = @{

        # Required Keys.

        ClientId = 'DIxxxxxxxxxxxxxxxxxx'
        SecretKeyEncrypted = 'Big long protected SecureString represented as a string on 1 line here'

        # Optional keys.

        # ProxyServer = 'your-proxy-01.domain.local'
        # ProxyPort = 8080
        # ProxyBypassList = @('*.domain.local', '*.otherdomain.local')
        # ProxyBypassOnLocal = $true
        # ProxyUsername = 'janedoe'
        # ProxyPassword = 'YourProxySecretsHere'

    }

    Work = @{

        # Required Keys.

        ClientId = 'DIxxxxxxxxxxxxxxxxxx'
        SecretKeyEncrypted = 'Big long protected SecureString represented as a string on 1 line here'

        # Optional keys.

        # ProxyServer = 'your-proxy-01.domain.local'
        # ProxyPort = 8080
        # ProxyBypassList = @('*.domain.local', '*.otherdomain.local')
        # ProxyBypassOnLocal = $true
        # ProxyUsername = 'janedoe'
        # ProxyPasswordEncrypted = 'Big long protected SecureString represented as a string on 1 line here'

    }

    Test = @{

        # Required Keys.

        ClientId = 'DIxxxxxxxxxxxxxxxxxx'
        SecretKey = 'YourSecretsHere'

        # Optional keys.

        # ProxyServer = 'your-proxy-01.domain.local'
        # ProxyPort = 8080
        # ProxyBypassList = @('*.domain.local', '*.otherdomain.local')
        # ProxyBypassOnLocal = $true
        # ProxyUseDefaultCredentials = $true

    }
}
```

1. The main hashtable must contain at least one properly formatted hashtable. If any of the nested hashtables are not in the proper format an error will be thrown.

2. The main hashtable must contain a key that matches the default Spotify environment. The default Spotify environment must be provided during the Spotify environment configuration. See details below on how this is done.

3. The inner hashtable must have the following keys:

    1. **ClientId** - The Spotify integration key.
    2. **SecretKey/SecretKeyEncrypted** - The Spotify secret key associated with the integration key. If the **SecretKey** key is used then the secret key is in plain text. If the **SecretKeyEncrypted** key is used then the secret key is a string representation of a standard *SecureString*. If both keys are used only the **SecretKeyEncrypted** key will be used.

4. The inner hashtable can optionally have the following keys:

    1. **ProxyServer** - The hostname of the proxy server used to connect to Spotify if a proxy server is required. All other proxy related keys will be ignored if this key is not present.
    2. **ProxyPort** - The port to use when connecting through the specified proxy server. Port 80 will be chosen if this key is not present.
    3. **ProxyBypassList** - The list of URIs that will not use the proxy. No bypass list will be used if this key is not present.
    4. **ProxyBypassOnLocal** - The switch to indicate whether shortname hosts will bypass the proxy. By default this will be set to false.
    5. **ProxyUsername** - The username used to authenticate to the specified proxy server. By default anonymous authentication is used.
    6. **ProxyPassword/ProxyPasswordEncrypted** - The password used to authenticate to the specified proxy server. If the **ProxyPassword** key is used then the password is in plain text. If the **ProxyPasswordEncrypted** key is used then the password is a string representation of a standard *SecureString*. If both keys are used only the **ProxyPasswordEncrypted** key will be used.
    7. **ProxyUseDefaultCredentials** - The switch to indicate whether or not to use Windows default credentials when authenticating to the specified proxy server. If this switch is given then the **ProxyUsername** and **ProxyPassword/ProxyPasswordEncrypted** keys are ignored. By default anonymous authentication is used.

Once this information has been given to the module you can make Spotify API calls by specifying the environment you wish to use. If an environment is not provided during the call the default environment key will be used. The default environment key must be provided when configuring the Spotify application environment details.

The Spotify application environment details can be provided in one of the following ways:

- [SpotifyEnvironmentInfo.ps1 File](#SpotifyEnvFile) - Provide environment info prior to importing the module. This is the only method that will persist in new PowerShell sessions.
- [Set-SpotifyEnvironmentInfo](#SpotifyEnvArgumentList) - Provide environment info after the module has been imported.
- [Proxy Configuration](#Proxy) - Provide proxy server conifguration info after the environment info has already be configured.

##### <a name="SpotifyEnvFile"></a> Configure SpotifyEnvironmentInfo.ps1 File

Using the *SpotifyEnvironmentInfo.ps1* file that comes with the module is the easiest way to configure the module. It is also the only method that persists between PowerShell sessions. For details on the format of the data in this file see the above section: [Spotify Environment Configuration](#SpotifyEnvConfig).

1. Open the module folder, then open the folder named *SpotifyEnvironmentInfo*.

2. Open the file named *SpotifyEnvironmentInfo.ps1*.

3. Fill in the fake values with your information. Add/Remove environments as needed.

4. Update the default environment key variable at the top to one of the environments in your hashtable.

5. Save file and import module.

When importing the module a check will be ran to ensure the hashtable is in the proper format as described in the section above.

##### <a name="SpotifyEnvArgumentList"></a> ArgumentList Configuration

You can pass in the Spotify application environment details during the import of the module itself by using the `-ArgumentList` property of the `Import-Module` command to provide the hashtable and default environment key to the module. Specifying the environment details in this manner will override any info stored in the *SpotifyEnvironmentInfo.ps1* file mentioned in the above section.

Once the hashtable is stored in a variable you can pass the environment info and the default environment key to the module on import using the command below.

###### Example : Using the $SpotifyEnvironmentInfo hashtable above and specifying the environment set 'Test' as the default environment.

``` powershell
Import-Module Posh-Spotify -ArgumentList @($SpotifyEnvironmentInfo, 'Test')
```

##### <a name="SetSpotifyEnvInfo"></a> Set-SpotifyEnvironmentInfo Command

The module has a SpotifyEnvironmentInfo.ps1 file that comes with pre-filled in with fake values. This means that you can import the module without modifying the file or without specifying a configuration via the Import-Module -ArgumentList parameter. However, since the values are fake, you will not be able to successfully execute any API calls until it has been updated. At any point after importing the module you can change the current Spotify environment configuration by using the `Set-SpotifyEnvironmentInfo` command and providing it a hashtable and default environment key as described in the above section ([Spotify Environment Configuration](#SpotifyEnvConfig)). There is also a `Get-SpotifyEnvironmentInfo` that can be used to retrieve and view the current settings.

To set the Spotify environment details at any time use the following command:

###### Example : Using the $SpotifyEnvironmentInfo hashtable above and specifying the environment set 'Test' as the default environment.

``` powershell
Set-SpotifyEnvironmentInfo -SpotifyEnvironmentInfo $SpotifyEnvironmentInfo -SpotifyDefaultEnv 'Test'
```

##### <a name="Proxy"></a> Proxy Server Configuration

By default this module will use the proxy settings from Internet Explorer for the current user. Therefore, it is typically not needed for you to manually configure the proxy settings for this module. However, if you are attempting to use this module as a user that does not have proxy settings in Internet Explorer configured (i.e. a service running as SYSTEM) and a proxy server is required to reach the Spotify API servers, then you will need to configure the proxy settings for this module as described below.

Proxy server configuration information can be configured using any of the above methods for environment configuration by adding the proxy server info to the environment hashtable of each Spotify application environment. For details on properly formatting the Spotify application environment hashtable with proxy information see the above section: ([Spotify Environment Configuration](#SpotifyEnvConfig)). You can also set the proxy server info at any time after the Spotify application environment has been configured by using the `Set-SpotifyEnvironmentProxy` command.

To set the Spotify environment proxy server details at any time use the following command (only *-ProxyServer* is required):

``` powershell
Set-SpotifyEnvironmentProxy -ProxyServer 'your-proxy-01.domain.local' -ProxyPort 8080 -ProxyBypassList @('*.domain.local', '*.otherdomain.local') -ProxyBypassOnLocal -ProxyUseDefaultCredentials -SpotifyEnv 'Test'
```

## <a name="Examples"></a> Examples

Once the module is imported and the Spotify environment info has been configured as detailed in the section above ([Spotify Environment Configuration](#SpotifyEnvConfig)), you can begin using the Spotify commands to make Spotify API calls. Below are a few examples.

###### Example 1 : Ping Spotify API servers to ensure they are up and accepting API requests.

``` powershell
If (Test-SpotifyPing) {
    # Perform more Spotify API calls.
} Else {
    Throw 'Spotify servers are down.'
}
```

###### Example 2 : Verify the Spotify integration key and secret key are validating against the Spotify API host. Use the *Test* application environment.

``` powershell
If (Test-SpotifyCheckKeys -SpotifyEnv 'Test') {
    # Perform more Spotify API calls.
} Else {
    Throw 'API keys are invalid.'
}
```

###### Example 3 : Authenticate a user.

``` powershell

# Get user device information and make sure the user is capable of logging in.
$preAuth = Get-SpotifyPreAuth -Username 'johndoe'

If (($preAuth.stat -eq 'OK') -and ($preAuth.response.result -eq 'auth')) {

    # Use Spotify App Auto method which choose the best available method for the first available device.
    $auth = Get-SpotifyAuth -Username 'johndoe' -AuthFactorAuto -Device $preAuth.response.devices[0].device

    # Check authentication result.
    If (($auth.stat -eq 'OK') -and ($auth.response.result -eq 'allow')) {
        Write-Host "Success : $($auth.response.status_msg)"
    } Else {
        Write-Host "Failed : $($auth.response.status_msg)"
    }

}

```

###### Example 4 : Custom API call.

``` powershell
$auth = Invoke-SpotifyRequest -SpotifyEnv 'Prod' -Method 'POST' -Path '/auth/v2/auth' -Parameters @{
            'username' = 'johndoe'
            'factor' = 'push'
            'device' = 'auto'
            'display_username' = 'Johnathan Doe'
            'type' = 'My Special Login Request Type'
            'pushinfo' = 'from=PowerShellUsername&domain=company.org&Foo=Bar'
        }

If (($auth.stat -eq 'OK') -and ($auth.response.result -eq 'allow')) {
    Write-Host "Success : $($auth.response.status_msg)"
} Else {
    Write-Host "Failed : $($auth.response.status_msg)"
}
```

###### Example 5 : Custom API call that returns a byte array of the response.

``` powershell
# Get logo and return as byte array.
[byte[]]$rawLogoPngBytes = Invoke-SpotifyRequest -Path '/auth/v2/logo' -Method 'GET' -ReturnRawBytes

# Save bytes to PNG file.
$rawLogoPngBytes | Set-Content "C:\Temp\logo.png" -Encoding Byte
```