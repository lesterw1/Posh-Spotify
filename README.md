# Posh-Spotify

This is a PowerShell module that contains a set of wrapper functions for retrieving and managing Spotify content via the Spotify Web API. Authentication is required for all Spotify API requests whether you are accessing public resources or not. After authentication you will be provided with a temporary Access Token that must be provided on every API request. The core command this module provides is **Invoke-SpotifyRequest** which will handle the formatting and proper encoding of your Access Token as well as any other parameters needed for the API request. This command can be used for most all Spotify Web API endpoints.

This module also provides a number of commands used to automatically keep track of your current application's credentials, your current Access Token and associated Refresh Token, as well as several commands for initiating authentication and acquiring these tokens. Once the module is configured with these parameters the configurations can be exported to disk in a secure manner allowing you to easily re-import them between PowerShell sessions. See the [Optional Profile Configuration](#Profile) section below for details.

The bulk of the commands provided by this module are wrappers around the individual Spotify Web API endpoints and all use the **Invoke-SpotifyRequest** command mentioned above. Some of the features these additional commands provide are listed below. There are plans to add many more featues later (ex. Playlist Modification, Search Features, etc.). In the meantime any feature this module does not have a command for should be possible via the **Invoke-SpotifyRequest** command and the appropriate Spotify Web API endpoint.

Current Command Support

- Retrieve devices connected to Spotify.
- Control playback of active player (ex. Play/Pause, Volume, Skip/Previous, Shuffle/Repeat, Get Current Track).
- Get detailed artist, album, playlist or track information.

###### ***NOTE**: Use **Invoke-SpotifyRequest** for unsupported features.

Documentation on Spotify Web API can be found at the following locations:

- Spotify API - https://developer.spotify.com/web-api/
- Spotify Authorization - https://developer.spotify.com/web-api/authorization-guide/
- Spotify Scopes - https://developer.spotify.com/web-api/using-scopes/

For details on installing and using this module please refer to the following sections:

- [Register With Spotify](#Register)
- [Installation](#Install)
- [Spotify Environment Configuration](#SpotifyEnvConfig)
    - [Quick Start](#Quick)
    - [Configuration Syntax](#ConfigSyntax)
- [User Sessions : Authentication, Access Tokens and Scopes](#UserSessions)
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

### <a name="Quick"></a> Quick Start

This module has two required pramaters needed for configuration and several optional parameters. There are a few different methods in which these parameters can be configured but the quick start instructions are below. Note that [registration](#Register) of your application is still required.

1. Import the module and configure your ClientId and SecretKey.

```powershell
# Import the module.
Import-Module Posh-Spotify

# Gather your ClientId and SecretKey. It can be plain text (SecretKey) or encrypted SecureString (SecretKeyEncrypted) as seen below.
$ClientId = 'xxxxxxxxxxxxxxxxxxxx'
$SecretKeyEncrypted = ConvertFrom-SecureString (ConvertTo-SecureString -String 'yourSecretKeyHere' -AsPlainText -Force)

# Get a copy of the default module configuration (includes pre-configured CallbackUrl and Scopes).
$EnvInfo = Get-SpotifyEnvironmentInfo

# Add your ClientId and SecretKey (or SecretKeyEncrypted).
$EnvInfo.Home.ClientId = $ClientId
$EnvInfo.Home.SecretKeyEncrypted = $SecretKeyEncrypted

# Either remove the other example environments are configure them like above.
# Or do neither, they won't be used by default so they will be ignored unless explicitly used.
$EnvInfo.Remove('Work')
$EnvInfo.Remove('Test')  # Test example has no scopes configured.

# Set your modified copy of the environment configuration back to the module.
Set-SpotifyEnvironmentInfo -SpotifyEnvironmentInfo $EnvInfo -SpotifyDefaultEnv Home
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

### <a name="ConfigSyntax"></a>Environment Configuration Syntax

In order to make Spotify API requests this module will need on each request an *Access Token*. This *Access Token* lasts for only a short time (usually 1hr) at which point a new *Access Token* must be acquired by either re-authenticating or by using a *Refresh Token*. The *Spotify Authorization Code Flow* method of login is the only authentication method that returns along with the *Access Token*, a *Refresh Token* that can be used to retrieve unlimited *Access Tokens* without additional authentication requests. The *Refresh Token* never expires and can be used between PowerShell sessions to retrieve a new *Access Token* without loging into Spotify each time. Therefore we must keep track of the *Refresh Token* for each user session. Regardless of which authentication method is used, we will also need to keep track of the *Client ID* and *Secret Key* that was acquired after registring your application with Spotify Developer. If you do not have a Spotify Client ID and Secret Key please refer the previous section, [Register With Spotify](#Register), for details.

To aid in keeping track of these parameters the module will use an internal hashtable that can contain multiple environment configurations and each environment can contain multiple user sessions. This hashtable can be retrieved (**Get-SpotifyEnvironmentInfo**), modified and submitted back to the module (**Set-SpotifyEnvironmentInfo**) to make changes. There are also commands for exporting (**Save-SpotifyEnvironmentInfo**) and importing (**Import-SpotifyEnvironmentInfo**) the hashtable, making it possible to easily save and reload configurations including *Refresh Tokens* between PowerShell sessions.

Below is an example of this *EnvironmentInfo* hashtable mentioned above. It also includes a brief description of the parameters mentioned above as well as a number of other possible parameters that can be configured for this module:

``` powershell
SpotifyEnvironmentInfo = @{

    Home = @{

        # Required Keys.

        ClientId = 'DIxxxxxxxxxxxxxxxxxx'
        SecretKeyEncrypted = 'Big long protected SecureString represented as a string on 1 line here'

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

    Work = @{

        # Required Keys.

        ClientId = 'DIxxxxxxxxxxxxxxxxxx'
        SecretKeyEncrypted = 'Big long protected SecureString represented as a string on 1 line here'

        # Optional keys.

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

1. The main hashtable contains one or more environments represented as additional hashtables. The keys of the main hashtable are the names for each of the environment hashtables.

2. The main hashtable must contain a key that matches the default Spotify environment. The default Spotify environment must be provided during the Spotify environment configuration. See details below on how this is done.

3. The inner environment hashtable must have the following keys:

    1. **ClientId** - The Spotify client id acquired during registration.
    2. **SecretKey/SecretKeyEncrypted** - The Spotify secret key associated with the client id. If the **SecretKey** key is used then the secret key is in plain text. If the **SecretKeyEncrypted** key is used then the secret key is a string representation of a standard *SecureString*. If both keys are used only the **SecretKeyEncrypted** key will be used.

4. The inner environment hashtable can optionally have the following keys:

    1. **CallbackUrl** - The callback url setup during registration. If not prsent the default will be `http://localhost:8080/callback/`.
    2. **Scopes** - The set of user permission scopes that should be requested anytime a full authentication is required. The user must authorize the use of these scopes to obtain access to the commands that use them.
    3. **ProxyServer** - The hostname of the proxy server used to connect to Spotify if a proxy server is required. All other proxy related keys will be ignored if this key is not present.
    4. **ProxyPort** - The port to use when connecting through the specified proxy server. Port 80 will be chosen if this key is not present.
    5. **ProxyBypassList** - The list of URIs that will not use the proxy. No bypass list will be used if this key is not present.
    6. **ProxyBypassOnLocal** - The switch to indicate whether shortname hosts will bypass the proxy. By default this will be set to false.
    7. **ProxyUsername** - The username used to authenticate to the specified proxy server. By default anonymous authentication is used.
    8. **ProxyPassword/ProxyPasswordEncrypted** - The password used to authenticate to the specified proxy server. If the **ProxyPassword** key is used then the password is in plain text. If the **ProxyPasswordEncrypted** key is used then the password is a string representation of a standard *SecureString*. If both keys are used only the **ProxyPasswordEncrypted** key will be used.
    9. **ProxyUseDefaultCredentials** - The switch to indicate whether or not to use Windows default credentials when authenticating to the specified proxy server. If this switch is given then the **ProxyUsername** and **ProxyPassword/ProxyPasswordEncrypted** keys are ignored. By default anonymous authentication is used.

5. The inner environment hashtable may also contain a system key used to store user sessions.

    1. **UserSessions** - An array of AuthenticationToken objects which contains a user authentication's *Access Token*, *Refresh Token* and expiration information. This array is filled by the module by default when using **Initialize-SpotifySession** to start a user session.

Once this information has been given to the module you can make Spotify API calls by specifying the environment you wish to use. If an environment is not provided during the call the default environment key will be used. The default environment key must be provided when configuring the Spotify application environment details.

The Spotify application environment details can be provided in one of the following ways:

- [SpotifyEnvironmentInfo.ps1 File](#SpotifyEnvFile) - Provide environment configuration prior to importing the module. This is the only method that will persist in new PowerShell sessions without need to import configurations. However, this requires updating a file within the module itself making it possible to lose settings if the module is updated.
- [Set-SpotifyEnvironmentInfo](#SpotifyEnvArgumentList) - Provide environment configuration after the module has been imported. This can be done by creating the hashtable mentioned above by hand or by importing it from a json file.
- [Proxy Configuration](#Proxy) - Provide proxy server conifguration after the environment configuration has already be configured.

#### <a name="SpotifyEnvFile"></a> Configure SpotifyEnvironmentInfo.ps1 File

Using the *SpotifyEnvironmentInfo.ps1* file that comes with the module is the easiest way to configure the module. It is also the only method that persists between PowerShell sessions. For details on the format of the data in this file see the above section: [Spotify Environment Configuration](#SpotifyEnvConfig).

1. Open the module folder, then open the folder named *SpotifyEnvironmentInfo*.

2. Open the file named *SpotifyEnvironmentInfo.ps1*.

3. Fill in the fake values with your information. Add/Remove environment hashtables as needed. The default values for *CallbackUrl* and *Scopes* are recommended.

4. Update the default environment key variable at the top to one of the environments in your hashtable.

5. Save file and import module.

When importing the module a check will be ran to ensure the hashtable is in the proper format as described in the section above.

#### <a name="SetSpotifyEnvInfo"></a> Set-SpotifyEnvironmentInfo Command

The module has a *SpotifyEnvironmentInfo.ps1* file that comes with pre-filled in with fake values. This means that you can import the module without modifying the file. However, since the values are fake, you will not be able to successfully execute any API calls until it has been updated. At any point after importing the module you can change the current Spotify environment configuration by using the **Set-SpotifyEnvironmentInfo** command and providing it a hashtable and default environment key as described in the above section ([Spotify Environment Configuration](#SpotifyEnvConfig)). There is also a **Get-SpotifyEnvironmentInfo** that can be used to retrieve and view the current settings. For a quick start it is recommended that you use **Get-SpotifyEnvironmentInfo** command to get a copy of the default configuration and then modify it as needed before setting it back with **Set-SpotifyEnvironmentInfo** command (an example is seen below).

###### Example : Configuring environment configuration using default module configuration.

``` powershell
# Gather your ClientId and SecretKey. It can be plain text (SecretKey) or encrypted SecureString (SecretKeyEncrypted) as seen below.
$ClientId = 'xxxxxxxxxxxxxxxxxxxx'
$SecretKeyEncrypted = ConvertFrom-SecureString (ConvertTo-SecureString -String 'yourSecretKeyHere' -AsPlainText -Force)

# Get a copy of the default module configuration (includes pre-configured CallbackUrl and Scopes).
$EnvInfo = Get-SpotifyEnvironmentInfo

# Add your ClientId and SecretKey (or SecretKeyEncrypted).
$EnvInfo.Home.ClientId = $ClientId
$EnvInfo.Home.SecretKeyEncrypted = $SecretKeyEncrypted

# Set your modified copy of the environment configuration back to the module.
Set-SpotifyEnvironmentInfo $EnvInfo Home
```

#### <a name="Proxy"></a> Proxy Server Configuration

By default this module will use the proxy settings from Internet Explorer for the current user. Therefore, proxy settings here are not typically needed. This is primarily used if the user running this module cannot have Internet Explorer configured proxy settings. For instance if the user running PowerShell is not the login user and you don't want to create a user profile for it (i.e. you'll run PowerShell with `-noprofile`). There are of course other reasons you might not be able to configure the settings in Internet Explorer and therefore you'll need them configured here.

Proxy server configuration information can be configured using any of the above methods for environment configuration by adding the proxy server info to the environment hashtable of each Spotify application environment. For details on properly formatting the Spotify application environment hashtable with proxy information see the above section: ([Spotify Environment Configuration](#SpotifyEnvConfig)). You can also set the proxy server info at any time after the Spotify application environment has been configured by using the **Set-SpotifyEnvironmentProxy** command.

To set the Spotify environment proxy server details at any time use the following command (only *-ProxyServer* is required):

``` powershell
Set-SpotifyEnvironmentProxy -ProxyServer 'your-proxy-01.domain.local' -ProxyPort 8080 -ProxyBypassList @('*.domain.local', '*.otherdomain.local') -ProxyBypassOnLocal -ProxyUseDefaultCredentials -SpotifyEnv 'Test'
```

## <a name="UserSessions"></a> User Sessions : Authentication, Access Tokens and Scopes

In this module's documentation and command help the term *User Sessions* will be frequently referenced. A *User Session* contains information such as the *Access Token*, *Refresh Token* if available and the expiration date of the *Access Token*. For convenience this module will use an object class called **AuthenticationToken** which will hold these values and provide a simple means by which to keep track of and pass around the required information for each Spotify API request.

#### Default User Session

As briefly described in the above section, [Environment Configuration Syntax](#ConfigSyntax), each environment may contain one or more *User Sessions*, held in a `UserSessions` array of the environment's configuration hashtable. Most commands provided by this module require an *Access Token*. If this *Access Token* is not provided the command will look to the default environment configuration for this `UserSessions` array and pull out the first available **AuthenticationToken** (i.e. *User Session*). By doing this, most users will never have to worry about providing an *Access Token* when making Spotify API requests. This is assuming of course the module has been properly configured. For a quick start on getting the module configured as needed please see the above section [Quick Start](#Quick).

#### Authentication

To acquire *Access Tokens* you must first authenticate to Spotify. Once authenticated you will be provided with an *Access Token* from Spotify. This *Access Token* lasts for only a short time (usually 1hr) at which point a new *Access Token* must be acquired by either re-authenticating or by using a *Refresh Token*. The *Authorization Code* authentication workflow is the only workflow that returns along with the *Access Token*, a *Refresh Token* that can be used to retrieve unlimited *Access Tokens* without additional authentication requests. The *Refresh Token* never expires and can be used between PowerShell sessions to retrieve a new *Access Token* without loging into Spotify each time. All other methods of authentication to Spotify require re-authentication for each new *Access Token* requested.

Both the *Authorization Code* and *Implicit Grant* authentication workflows require a interactive user login to Spotify. This means the user's browser must be directed away to the Spotify login page. If the user's browser is already logged into Spotify it will skip that login page and go directly to the application authorization page where the user must authorize your access to their account. If the user has previously authorized your application for the requested scopes they will be automatically redirected back to your *CallbackUrl* (more on scopes later). The *CallbackUrl* should be registered with your application on Spotify Developer and should point to an http service that can accept the user's browser redirect to your *CallbackUrl*. The *CallbackUrl* must match exactly (case, trailing slashes, etc.). This redirect will contain in the query string either the *Access Token* (for *Implicit Grant*) or the authorization code needed to acquire the final *Access Token* and *Refresh Token* (for *Authorization Code*). By default the authorization commands provided with this module will handle the process of starting up an http listener and acquiring the *Access Tokens*. The default *CallbackUrl* this module listens on is `http://localhost:8080/callback/`.

For more details on Spotify authentication workflows see the following: https://developer.spotify.com/web-api/authorization-guide/

Currently this module supports the following authentication workflows. If a workflow is not present here it can still be acomplished with **Invoke-SpotifyRequest**. Note that the **Initialize-SpotifySession** uses the *Authorization Code* workflow and automatically adds the acquired user session to the environment configuration's `UserSessions` array if not already.

##### Authroziation Code Flow

```powershell
# Authenticate and request authorization for the default callback url and scopes.
$userSession = Initialize-SpotifyAuthorizationCodeFlow

# The user's default browser gets directed to Spotify login page.

# The above command will block the prompt until authentication is complete and the user successfully redirected back to the CallbackUrl.

# Add this session to the default environment as the new default user session.
$userSession | Add-SpotifyUserSession -MakeDefault

# Authenticate and request authorization for the custom callback url and scopes.
# This command will block the prompt until authentication is complete and the user successfully redirected back to the CallbackUrl.
$scopes = @(
    'user-modify-playback-state',
    'user-read-playback-state',
    'user-modify-playback-state',
    'user-read-playback-state',
)
$userSession = Initialize-SpotifyAuthorizationCodeFlow -CallbackUrl 'http://localhost/myCustomCallbackUrl/' -Scopes $scopes

# Add this session to the default environment. It will not be the default user session unless it is the only user session.
$userSession | Add-SpotifyUserSession
```

#### Scopes

In order to access any data on a user account that is not public you must request specific user permission *Scopes* during the authentication process. The *Access Token* provided will only be able to access resources that full under those *Scopes*. For instance, in order to check a user's player state (including your own), your authentication request must have at some point requested (and been authorized by the user), the `user-read-playback-state` *Scope*. Each Spotify API endpoint that requires a sepcific *Scope* should state which *Scope* to use on their documentation page.

The *SpotifyEnvironmentInfo.ps1* file loaded with this module by default contains a list of recommended scopes for full functionaility of this module's provided commands. If you load an environment configuration that does not have a *Scopes* member, it will overwrite these defaults and *Scopes* will have to be explicitly requested during the authentication process.

For more details and a partial list of available scopes please see the following: https://developer.spotify.com/web-api/using-scopes/

## <a name="Profile"></a> Optional Profile Configuration

To aid in loading this module on each PowerShell session you may want to configure you PowerShell session to automatically load the module and import your saved configuration file. Possibly load the command aliases as well if desired. An example of one possible profile configuration is detailed below. Please note this example assumes you have previously configured the module as detailed in the [Spotify Environment Configuration](#SpotifyEnvConfig) section above, authenticated with Spotify at least once saving the user session to the default environment (i.e. use **Initialize-SpotifySession**) and that you have saved that environment configuration to a file using **Save-SpotifyEnvironmentInfo**. For a quick start on getting to that point please see the above section [Quick Start](#Quick).

```powershell
# Set a custom path to where you configs get saved by default.
# A timestamp will be appended by default when saving. So we will use '*' for importing.
# If the import path matches multiple files it will sort them alphabetically and pick the top one (in this case the latest saved copy).
# Remove these two lines if you want to use default save\import locations.
$SpotifyEnvironmentInfoImportPath = "C:\Users\$($env:USERNAME)\Posh-Spotify-Configs\$($env:USERNAME)_$($env:COMPUTERNAME)_SpotifyEnvironmentInfo_*.json"
$SpotifyEnvironmentInfoSavePath = "C:\Users\$($env:USERNAME)\Posh-Spotify-Configs\$($env:USERNAME)_$($env:COMPUTERNAME)_SpotifyEnvironmentInfo.json"

# Import module.
Import-Module Posh-Spotify

# Import saved environment configurations.
Import-SpotifyEnvironmentInfo -FilePath $SpotifyEnvironmentInfoImportPath | Out-Null

# Add command aliases (ex. Play/Pause, Skip/SkipBack).
Add-SpotifyCommandAlias

# Set default parameter value for -FilePath of the Import/Save-SpotifyEnvironmentInfo commands.
# We now don't have to ever specify our custom FilePath when calling these commands.
# Remove these two lines if you want to use default save\import locations.
$PSDefaultParameterValues['Import-SpotifyEnvironmentInfo:FilePath'] = $SpotifyEnvironmentInfoImportPath
$PSDefaultParameterValues['Save-SpotifyEnvironmentInfo:FilePath'] = $SpotifyEnvironmentInfoSavePath
```

## <a name="Examples"></a> Examples

Once the module is imported and the Spotify environment info has been configured as detailed in the section above ([Spotify Environment Configuration](#SpotifyEnvConfig)), you can begin using the Spotify commands to make Spotify API calls. Below are a few examples. Note that in any example that uses a command without a proper PowerShell approved verb is an example of one of the command aliases imported into your session using **Add-SpotifyCommandAlias**.

###### Example 1 : Control playback of currently active device.

``` powershell
# Player : Get-SpotifyPlayer
# Play : Start-SpotifyPlayback
# Pause : Stop-SpotifyPlayback
# Skip : Skip-SpotifyNextTrack
# SkipBack : Skip-SpotifyPreviousTrack

# Start playback on current player device.
Player | Play

# Stop playback on current player device.
Player | Pause

# Skip forward one Track on current player device.
Player | Skip

# Skip backward one Track on current player device.
Player | SkipBack

# Seek current player device to 1 min and 25 secs in the current Track.
Player | Set-SpotifyTrackSeek -Minutes 1 -Seconds 25

# Set the current player device to 50% volume 
Player | Set-SpotifyPlayerVolume -Volume 50

# Turn on shuffle mode for current player device.
Player | Set-SpotifyPlayerShuffleMode -State Enabled

# Set repeat mode to repeat the current Track on the current player device.
Player | Set-SpotifyPlayerRepeatMode -State Track

# Set repeat mode to repeat the current Context (i.e. Playlist, Album).
Player | Set-SpotifyPlayerRepeatMode -State Context

# Set the current computer to be the active player device (without starting playback).
Get-SpotifyDevice | ? { $_.Name -match $env:COMPUTERNAME } | Set-SpotifyPlayer

# Set the current computer to be the active player device (with starting playback).
Get-SpotifyDevice | ? { $_.Name -match $env:COMPUTERNAME } | Set-SpotifyPlayer -Play
# -- OR --
Get-SpotifyDevice | ? { $_.Name -match $env:COMPUTERNAME } | Play
```

###### Example 2 : Get detailed information of Spotify objects.

``` powershell
# Get current track on currently active player device.
$song = (Get-SpotifyCurrentlyPlaying).Track

# View simplified versions of Album and Artist of the song.
$song.Album
$song.Artists

# Get full detailed versions of Album and Artist of the song.
$artist = $song.Artists | Get-SpotifyArtist
$album = $song.Album | Get-SpotifyAlbum

# View detailed information including members hidden by default.
$artist | fl *
$album | fl *
```

###### Example 3 : Get playlist information.

```powershell
# Get all playlists for current user.
# Note depending on number of playlists and songs per list this could cause rate limiting.
$playlists = Get-SpotifyPlaylist

# Get a specific playlist. In this case the 3rd playlist available.
$specificPlaylist = Get-SpotifyPlaylist -PageResults -Limit 1 -Offset 3

# Get all playlists but skip extra requests to get track information (it can be retrieved later).
$playlistsOnly = Get-SpotifyPlaylist -SkipTrackRetrieval

# Get all Tracks for each Playlist retrieved above that has "Rock" in its name.
$rockPlaylists = $playlistsOnly | ? { $_.Name -match 'Rock' }
Foreach ($playlist In $rockPlaylists) {
    $newPageInfo = Get-SpotifyPage -PagingInfo $playlist.TrackPagingInfo -RetrieveMode AllPages
    $newPageInfo.Items | ForEach-Object { $playlist.Tracks.Add($_) }
}
```