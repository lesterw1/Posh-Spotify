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

Function Get-SpotifyDefaultSession {

    <#

        .SYNOPSIS

            Get the current default session information with Spotify.

        .DESCRIPTION

            Get the current default session information with Spotify. Includes information such as Refresh and Access token. Each Spotify environment
            configuration can have zero or more user sessions where the first session in the array is considered to be default.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.AuthenticationToken')]

    Param([ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    Process {

        # If a UserSessions array exist, return a copy of the first (default) session.
        If ($script:SpotifyEnvironmentInfo[$SpotifyEnv].Keys -contains 'UserSessions') {
            $userSess = [NewGuy.PoshSpotify.AuthenticationToken]::new()

            $userSess.AccessToken = $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0].AccessToken
            $userSess.RefreshToken = $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0].RefreshToken
            $userSess.ExpiresOn = $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0].ExpiresOn
            $userSess.Scopes = $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0].Scopes
            $userSess.TokenType = $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0].TokenType

            Return $userSess
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

Function Add-SpotifyUserSession {

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

    Param([Parameter(ParameterSetName = 'Parameters', ValueFromPipeline, Position = 0)]
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

    Process {

        # If a UserSessions array doesn't already exist, create one.
        If ($script:SpotifyEnvironmentInfo[$SpotifyEnv].Keys -notcontains 'UserSessions') {
            $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions = @()
        }

        $userSess = [NewGuy.PoshSpotify.AuthenticationToken]::new()

        If ($AuthenticationToken) {
            $userSess.AccessToken = $AuthenticationToken.AccessToken
            $userSess.RefreshToken = $AuthenticationToken.RefreshToken
            $userSess.ExpiresOn = $AuthenticationToken.ExpiresOn
            $userSess.Scopes = $AuthenticationToken.Scopes
            $userSess.TokenType = $AuthenticationToken.TokenType
        } Else {
            If ($RefreshToken) { $userSess.RefreshToken = $RefreshToken }
            If ($AccessToken) { $userSess.AccessToken = $AccessToken }
            If ($ExpiresOn) { $userSess.ExpiresOn = $ExpiresOn }
        }

        If ($MakeDefault) {
            $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions = @($userSess) + $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions
        } Else {
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

Function Initialize-SpotifySession {

    <#

        .SYNOPSIS

            Initializes the user session information and authenticates with Spotify.

        .DESCRIPTION

            Initializes the user session information and authenticates with Spotify. If an AuthenticationToken object is given that object will be
            updated with the newly initialized session. If none is provided then the default user session of the Spotify environment configuration
            will be updated. If none are initialized, an entirely new session will be initialized which will result in a user login request.

            For details on Spotfy authentication please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER AuthenticationToken

            An AuthenticationToken object. AuthenthicationTokens can be retrieved using one of the authentication commands such as the
            Initialize-SpotifyAuthorizationCodeFlow command.

        .PARAMETER Force

            Forces a re-initialization of the default session if one was already previously initialized for the current session.

        .PARAMETER PassThru

            If the AuthenticationToken parameter was used, the updated token will be returned to the pipeline.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.AuthenticationToken')]

    Param([NewGuy.PoshSpotify.AuthenticationToken]$AuthenticationToken,
          [switch]$Force,
          [switch]$PassThru,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    Process {

        # If a UserSessions array doesn't already exist, create one.
        If ($script:SpotifyEnvironmentInfo[$SpotifyEnv].Keys -notcontains 'UserSessions') {
            $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions = @()
        }

        # If a user provides a token use that, otherwise find the default for the provided environment.
        If ($AuthenticationToken) { $OriginalToken = $AuthenticationToken }
        ElseIf ($null -ne $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0]) { $OriginalToken = $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0] }
        Else { $OriginalToken = [NewGuy.PoshSpotify.AuthenticationToken]::new() }

        # Check the status of the token and initialize a new one if needed.
        If (!$Force -and $OriginalToken.AccessToken -and ($OriginalToken.ExpiresOn -gt (Get-Date))) { $NewToken = $OriginalToken }
        ElseIf (!$Force -and $OriginalToken.RefreshToken) { $NewToken = Initialize-SpotifyAuthorizationCodeFlow -RefreshToken $OriginalToken.RefreshToken }
        Else { $NewToken = Initialize-SpotifyAuthorizationCodeFlow }

        # Keep previously recorded scopes if new authorization object doesn't contain any.
        If (($OriginalToken.Scopes.Count -gt 0) -and ($NewToken.Scopes.Count -eq 0)) {
            $NewToken.Scopes = $OriginalToken.Scopes
        }

        # Now update the original token with the new token's information.
        $OriginalToken.AccessToken = $NewToken.AccessToken
        $OriginalToken.RefreshToken = $NewToken.RefreshToken
        $OriginalToken.ExpiresOn = $NewToken.ExpiresOn
        $OriginalToken.Scopes = $NewToken.Scopes
        $OriginalToken.TokenType = $NewToken.TokenType

        # Since we simply updated the values of the original AuthenticationToken object, whether that came from the user or as the default user
        # session for the given environment, we don't need to update the UserSessions lists nor does the user have to worry about working with a new
        # object.

        # Pass the object on thru if requested and if originally provided by the user.
        If ($PassThru -and $AuthenticationToken) { Return $OriginalToken }

    }

}

Export-ModuleMember -Function 'Initialize-SpotifySession'

#endregion Initialize-SpotifySession

#====================================================================================================================================================
################################
## Save-SpotifyDefaultSession ##
################################

#region Save-SpotifyDefaultSession

Function Save-SpotifyDefaultSession {

    <#

        .SYNOPSIS

            Saves the current default session information with Spotify.

        .DESCRIPTION

            Saves the current default session information with Spotify. Includes information such as Refresh and Access token.

        .PARAMETER FilePath

            The path to save the default session information with Spotify to.

        .PARAMETER NoTimestampAppend

            By default this command appends the current date and time onto the filename of the save. This switch will prevent the appending of the
            timestamp.

        .NOTES

            TODO : At some point I would like to add functionality for storing this AuthenticationToken with SecureStrings for the AccessToken and
            RefershToken.

    #>

    [CmdletBinding()]

    Param([string]$FilePath = ($script:SpotifyDefaultAuthenticationTokenSaveLocation + '\' + $script:SpotifyDefaultAuthenticationTokenSaveFilename),
          [switch]$NoTimestampAppend)

    If (-not $NoTimestampAppend) {
        $ext = [IO.Path]::GetExtension($FilePath)
        $FilePath = $FilePath -replace "$ext$","_$(Get-Date -Format 'HH.mm.ss_MMM.dd')$ext"
    }

    $script:SpotifyDefaultAuthenticationToken | ConvertTo-Json | Out-File $FilePath

    Write-Host "`nAuthenticationToken saved to: $FilePath" -ForegroundColor Cyan

}

Export-ModuleMember -Function 'Save-SpotifyDefaultSession'

#endregion Save-SpotifyDefaultSession

#====================================================================================================================================================
##################################
## Import-SpotifyDefaultSession ##
##################################

#region Import-SpotifyDefaultSession

Function Import-SpotifyDefaultSession {

    <#

        .SYNOPSIS

            Loads the default session information with Spotify.

        .DESCRIPTION

            Loads the default session information with Spotify. Includes information such as Refresh and Access token.

        .PARAMETER FilePath

            The path to load the default session information with Spotify from.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.AuthenticationToken')]

    Param([string]$FilePath)

    # Throw all errors to stop the script.
    $ErrorActionPreference = 'Stop'

    # Initialize result object.
    $authObj = $null

    # If FilePath was not provided build a default one. This only works if it was saved with default path and appended timestamp.
    # An * will be added as a wildcard for the date/time part of the filename.
    If (($FilePath -eq $null) -or ($FilePath -eq '')) {
        $FilePath = ($script:SpotifyDefaultAuthenticationTokenSaveLocation + '\' + $script:SpotifyDefaultAuthenticationTokenSaveFilename)
        $ext = [IO.Path]::GetExtension($FilePath)
        $FilePath = $FilePath -replace "$ext$","_*$ext"
        Write-Verbose "No path specified. Searching in following path : $FilePath"
    }

    # Verify we have a valid file now.
    If (-not (Test-Path $FilePath)) { Throw "Invalid file path : $FilePath" }

    # If there are multiple matches on FilePath, sort by name and pick the last one.
    # Assuming the files end in a date, it should be the newest file. If not then who knows what the user is looking for.
    $file = Get-ChildItem $FilePath | Sort-Object Name | Select-Object -Last 1

    # Grab from disk the saved information.
    $jsonObj = (Get-Content $file | ConvertFrom-Json)

    # Make sure we got something back.
    If (($null -eq $jsonObj) -or ($jsonObj -eq '')) { Throw "Failed to retrieve information from provided file path : $FilePath" }

    # Calculate the remaining time left on the access token.
    $expiresOn = $jsonObj.ExpiresOn.ToLocalTime()
    $expiresInSec = [int]($expiresOn - (Get-Date)).TotalSeconds

    # Create object and set optional properties.
    $authObj = [NewGuy.PoshSpotify.AuthenticationToken]::new($jsonObj.AccessToken, $jsonObj.TokenType, $expiresInSec)
    If ($jsonObj.RefreshToken) { $authObj.RefreshToken = $jsonObj.RefreshToken }
    If ($jsonObj.Scopes) { $authObj.Scopes = $jsonObj.Scopes }

    $script:SpotifyDefaultAuthenticationToken = $authObj

    Return $authObj

}

Export-ModuleMember -Function 'Import-SpotifyDefaultSession'

#endregion Import-SpotifyDefaultSession

#====================================================================================================================================================
###################################
## Get-SpotifyDefaultAccessToken ##
###################################

#region Get-SpotifyDefaultAccessToken

Function Get-SpotifyDefaultAccessToken {

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

    Param([switch]$IsRequired,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    If ($script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0].AccessToken) { Return $script:SpotifyEnvironmentInfo[$SpotifyEnv].UserSessions[0].AccessToken }
    ElseIf ($IsRequired) { Throw 'An Access Token is required for this procedure. Either provide an Access Token to the -AccessToken parameter or configure a new session with the Initialize-SpotifySession command.' }
    Else { Return $null }

}

Export-ModuleMember -Function 'Get-SpotifyDefaultAccessToken'

#endregion Get-SpotifyDefaultAccessToken

#====================================================================================================================================================
#############################
## Add-SpotifyCommandAlias ##
#############################

#region Add-SpotifyCommandAlias

Function Add-SpotifyCommandAlias {

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

    Param([ValidateSet('Play',
                       'Pause',
                       'Skip',
                       'NextTrack',
                       'SkipBack',
                       'PreviousTrack',
                       'Player')] [string[]]$Aliases)

    If (($Aliases.Count -eq 0) -or ($Aliases -contains 'Play')) { Set-Alias -Name Play -Value Start-SpotifyPlayback -Scope Global }
    If (($Aliases.Count -eq 0) -or ($Aliases -contains 'Pause')) { Set-Alias -Name Pause -Value Stop-SpotifyPlayback -Scope Global }
    If (($Aliases.Count -eq 0) -or ($Aliases -contains 'Skip')) { Set-Alias -Name Skip -Value Skip-SpotifyNextTrack -Scope Global }
    If (($Aliases.Count -eq 0) -or ($Aliases -contains 'NextTrack')) { Set-Alias -Name NextTrack -Value Skip-SpotifyNextTrack -Scope Global }
    If (($Aliases.Count -eq 0) -or ($Aliases -contains 'SkipBack')) { Set-Alias -Name SkipBack -Value Skip-SpotifyPreviousTrack -Scope Global }
    If (($Aliases.Count -eq 0) -or ($Aliases -contains 'PreviousTrack')) { Set-Alias -Name PreviousTrack -Value Skip-SpotifyPreviousTrack -Scope Global }
    If (($Aliases.Count -eq 0) -or ($Aliases -contains 'Player')) { Set-Alias -Name Player -Value Get-SpotifyPlayer -Scope Global }

}

Export-ModuleMember -Function 'Add-SpotifyCommandAlias'

#endregion Add-SpotifyCommandAlias

#endregion Spotify Default Session Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
