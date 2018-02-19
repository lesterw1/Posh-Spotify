<#

    This file contains code for default use session management. It is intended for those using this module for control of their own Spotify
    accounts only. Includes functions for keeping track of default Refresh and Access tokens.

#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#######################################
## Spotify Default Session Functions ##
#######################################

#region Spotify Default Session Functions

#====================================================================================================================================================
###############################
## Get-SpotifyDefaultSession ##
###############################

#region Get-SpotifyDefaultSession

function Get-SpotifyDefaultSession {

    <#

        .SYNOPSIS

            Get the current default session information with Spotify.

        .DESCRIPTION

            Get the current default session information with Spotify. Includes information such as Refresh and Access token. Each Spotify environment
            configuration can have zero or more user sessions where the first session in the array is considered to be default.

        .PARAMETER RefreshIfExpired

            If the default session is expired, attempt to re-initialize the session.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.AuthenticationToken')]

    param([switch]$RefreshIfExpired,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    process {

        # If a UserSessions array exist, return a copy of the first (default) session.
        if (($script:SpotifyEnvironmentInfo[$SpotifyEnv].Keys -contains 'UserSessions') -and
            ($script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions.Count -gt 0)) {

            # Refresh the token first if needed.
            if ($RefreshIfExpired) {
                Initialize-SpotifySession -SpotifyEnv $SpotifyEnv
            }

            $userSess = [NewGuy.PoshSpotify.AuthenticationToken]::new()

            $userSess.AccessToken = $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0].AccessToken
            $userSess.RefreshToken = $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0].RefreshToken
            $userSess.ExpiresOn = $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0].ExpiresOn
            $userSess.Scopes = $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0].Scopes
            $userSess.TokenType = $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0].TokenType

            return $userSess
        }

    }

}

Export-ModuleMember -Function 'Get-SpotifyDefaultSession'

#endregion Get-SpotifyDefaultSession

#====================================================================================================================================================
############################
## Add-SpotifyUserSession ##
############################

#region Add-SpotifyUserSession

function Add-SpotifyUserSession {

    <#

        .SYNOPSIS

            Adds the provided user session information to the Spotify environment configuration.

        .DESCRIPTION

            Adds the provided user session information to the Spotify environment configuration. To obtain user session information you must first
            authenticate using one of the three Spotify authentication workflows. You can use one of the commands that comes with this modules to do
            so (ex. Initialize-SpotifyAuthorizationCodeFlow).

            Each Spotify environment configuration can contain an array of user sessions. The first user session in the array is used by default
            when its associated environment configuration is being used to make API requests. You can manage the user session array in each
            environment configuration by retrieving, modifying and setting back the current environment configuration. However, most will only ever
            want to add user sessions so this command will simplfy that process.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER RefreshToken

            The Refresh Token used to retrive new Access Tokens. Refresh Tokens can be retrieved using the Initialize-SpotifyAuthorizationCodeFlow
            command.

        .PARAMETER ExpiresOn

            The DateTime in which the Access Token will expire.

        .PARAMETER AccessToken

            The current Access Token for making Spotify API calls.

        .PARAMETER AuthenticationToken

            An AuthenticationToken object. AuthenthicationTokens can be retrieved using one of the authentication commands such as the
            Initialize-SpotifyAuthorizationCodeFlow command.

        .PARAMETER MakeDefault

            Sets the provided user session information as the first user session in the Spotify environment configuration which makes it the default.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .NOTES

            This command merely adds the provided data to the Spotify environment configuration. Modifying the properties will not have an effect on
            any Spotify process. For example, setting the ExpiresOn property of a user session to a future date will not un-expire the AccessToken and
            a new AccessToken will still need to be retrieved if it was expired. Modifying the properies of a user session given from Spotify may
            result in unexpected behavior.

    #>

    [CmdletBinding(DefaultParameterSetName = 'Parameters')]

    param([Parameter(ParameterSetName = 'Parameters', ValueFromPipeline, Position = 0)]
          [string]$RefreshToken,

          [Parameter(ParameterSetName = 'Parameters', Position = 1)]
          [string]$AccessToken,

          [Parameter(ParameterSetName = 'Parameters', Position = 2)]
          [DateTime]$ExpiresOn,

          [Parameter(ParameterSetName = 'AuthenticationToken', ValueFromPipeline, Position = 0)]
          [NewGuy.PoshSpotify.AuthenticationToken]$AuthenticationToken,

          [switch]$MakeDefault,

          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })]
          [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    process {

        # If a UserSessions array doesn't already exist, create one.
        if ($script:SpotifyEnvironmentInfo[$SpotifyEnv].Keys -notcontains 'UserSessions') {
            $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions = @()
        }

        $userSess = [NewGuy.PoshSpotify.AuthenticationToken]::new()

        if ($AuthenticationToken) {
            $userSess.AccessToken = $AuthenticationToken.AccessToken
            $userSess.RefreshToken = $AuthenticationToken.RefreshToken
            $userSess.ExpiresOn = $AuthenticationToken.ExpiresOn
            $userSess.Scopes = $AuthenticationToken.Scopes
            $userSess.TokenType = $AuthenticationToken.TokenType
        } else {
            if ($RefreshToken) { $userSess.RefreshToken = $RefreshToken }
            if ($AccessToken) { $userSess.AccessToken = $AccessToken }
            if ($ExpiresOn) { $userSess.ExpiresOn = $ExpiresOn }
            $userSess.TokenType = 'Bearer'
        }

        if ($MakeDefault) {
            $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions = @($userSess) + $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions
        } else {
            $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions += $userSess
        }

    }

}

Export-ModuleMember -Function 'Add-SpotifyUserSession'

#endregion Add-SpotifyUserSession

#====================================================================================================================================================
###############################
## Initialize-SpotifySession ##
###############################

#region Initialize-SpotifySession

function Initialize-SpotifySession {

    <#

        .SYNOPSIS

            Initializes the user session information and authenticates with Spotify.

        .DESCRIPTION

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

                - After authroziation, the user will be directed to your CallbackUrl configured through the environment configuration.

            For details on Spotfy authentication please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AuthenticationToken

            An AuthenticationToken object. AuthenthicationTokens, which represent user sessions, can be retrieved using one of the authentication
            commands such as the Initialize-SpotifyAuthorizationCodeFlow command.

        .PARAMETER ForceRefresh

            Forces a refresh of the provided user session (AuthenticationToken) or the environment's default user session even if the session has not
            yet expired. This should only be used if there is a need to refresh the token before it has expired. No user login is required.

        .PARAMETER ForceAuth

            Forces a full re-authentication with the user which will result in a user login request.

        .PARAMETER PassThru

            If the AuthenticationToken parameter was used, the updated token will be returned to the pipeline.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.AuthenticationToken')]

    param([NewGuy.PoshSpotify.AuthenticationToken]$AuthenticationToken,
          [switch]$ForceAuth,
          [switch]$ForceRefresh,
          [switch]$PassThru,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    process {

        # If a UserSessions array doesn't already exist, create one.
        if ($script:SpotifyEnvironmentInfo[$SpotifyEnv].Keys -notcontains 'UserSessions') {
            $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions = @()
        }

        # If a user provides a token use that, otherwise find the default for the provided environment.
        if ($AuthenticationToken) { $OriginalToken = $AuthenticationToken }
        elseif ($null -ne $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0]) { $OriginalToken = $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0] }
        else { $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions += $OriginalToken = [NewGuy.PoshSpotify.AuthenticationToken]::new() }

        # Check the status of the token and initialize a new one if needed.
        if (!$ForceAuth -and !$ForceRefresh -and $OriginalToken.AccessToken -and ($OriginalToken.ExpiresOn -gt (Get-Date))) { $NewToken = $OriginalToken }
        elseif (!$ForceAuth -and $OriginalToken.RefreshToken) { $NewToken = Initialize-SpotifyAuthorizationCodeFlow -RefreshToken $OriginalToken.RefreshToken -SpotifyEnv $SpotifyEnv }
        else { $NewToken = Initialize-SpotifyAuthorizationCodeFlow -SpotifyEnv $SpotifyEnv }

        # Now update the original token with the new token's information.
        $OriginalToken.AccessToken = $NewToken.AccessToken
        $OriginalToken.RefreshToken = $NewToken.RefreshToken
        $OriginalToken.ExpiresOn = $NewToken.ExpiresOn
        $OriginalToken.Scopes = $NewToken.Scopes
        $OriginalToken.TokenType = $NewToken.TokenType

        # Since we simply updated the values of the original AuthenticationToken object, whether it came from the user or as the default user
        # session for the given environment, we don't need to update the UserSessions lists nor does the user have to worry about working with a new
        # object.

        # Pass the object on thru if requested and only if originally provided by the user.
        if ($PassThru -and $AuthenticationToken) { return $OriginalToken }

    }

}

Export-ModuleMember -Function 'Initialize-SpotifySession'

#endregion Initialize-SpotifySession

#====================================================================================================================================================
#############################
## Add-SpotifyCommandAlias ##
#############################

#region Add-SpotifyCommandAlias

function Add-SpotifyCommandAlias {

    <#

        .SYNOPSIS

            Adds command aliases to the local PowerShell session.

        .DESCRIPTION

            Adds command aliases to the local PowerShell session such as "Play", "Pause", "Skip", "SkipBack", etc.

        .PARAMETER Aliases

            List of aliases to make available to the local PowerShell session. If empty all aliases will be added. Possible values include:

                Play - Starts playback of music on the current player device.
                Pause - Pauses playback of music on the current player device.
                Skip - Skips to the next track.
                NextTrack - Skips to the next track.
                SkipBack - Skips back to the previous track.
                PreviousTrack - Skips back to the previous track.
                Player - Returns the currently active player.

    #>

    [CmdletBinding()]

    param([ValidateSet('Play',
                       'Pause',
                       'Skip',
                       'NextTrack',
                       'SkipBack',
                       'PreviousTrack',
                       'Player')] [string[]]$Aliases)

    if (($Aliases.Count -eq 0) -or ($Aliases -contains 'Play')) { Set-Alias -Name Play -Value Start-SpotifyPlayback -Scope Global }
    if (($Aliases.Count -eq 0) -or ($Aliases -contains 'Pause')) { Set-Alias -Name Pause -Value Stop-SpotifyPlayback -Scope Global }
    if (($Aliases.Count -eq 0) -or ($Aliases -contains 'Skip')) { Set-Alias -Name Skip -Value Skip-SpotifyNextTrack -Scope Global }
    if (($Aliases.Count -eq 0) -or ($Aliases -contains 'NextTrack')) { Set-Alias -Name NextTrack -Value Skip-SpotifyNextTrack -Scope Global }
    if (($Aliases.Count -eq 0) -or ($Aliases -contains 'SkipBack')) { Set-Alias -Name SkipBack -Value Skip-SpotifyPreviousTrack -Scope Global }
    if (($Aliases.Count -eq 0) -or ($Aliases -contains 'PreviousTrack')) { Set-Alias -Name PreviousTrack -Value Skip-SpotifyPreviousTrack -Scope Global }
    if (($Aliases.Count -eq 0) -or ($Aliases -contains 'Player')) { Set-Alias -Name Player -Value Get-SpotifyPlayer -Scope Global }

}

Export-ModuleMember -Function 'Add-SpotifyCommandAlias'

#endregion Add-SpotifyCommandAlias

#endregion Spotify Default Session Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#################################################
## Spotify Default Session Functions - Private ##
#################################################

#region Spotify Default Session Functions - Private

#====================================================================================================================================================
###################################
## Get-SpotifyDefaultAccessToken ##
###################################

#region Get-SpotifyDefaultAccessToken

function Get-SpotifyDefaultAccessToken {

    <#

        .SYNOPSIS

            Returns the current default user session Access Token or $null if not initialized.

        .DESCRIPTION

            Returns the current default user session Access Token or $null if not initialized. Each Spotify environment configuration can have zero or
            more user sessions where the first session in the array is considered to be default.

        .PARAMETER IsRequired

            If this switch is given, terminating errors will occur if a user session Access Token has not yet been initialized.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

    #>

    [CmdletBinding()]
    [OutputType([string])]

    param([switch]$IsRequired,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    if (($script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0]).AccessToken) { return (Get-SpotifyDefaultSession -SpotifyEnv $SpotifyEnv -RefreshIfExpired).AccessToken }
    elseif ($IsRequired) { throw 'An Access Token is required for this procedure. Either provide an Access Token to the -AccessToken parameter or configure a new session with the Initialize-SpotifySession command.' }
    else { return $null }

}

#endregion Get-SpotifyDefaultAccessToken

#endregion Spotify Default Session Functions - Private
