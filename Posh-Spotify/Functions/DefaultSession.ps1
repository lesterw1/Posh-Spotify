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

            Get the current default session information with Spotify. Includes information such as Refresh and Access token.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.AuthenticationToken')]

    Param()

    Return $script:SpotifyDefaultAuthenticationToken

}

Export-ModuleMember -Function 'Get-SpotifyDefaultSession'

#endregion Get-SpotifyDefaultSession

#====================================================================================================================================================
###############################
## Set-SpotifyDefaultSession ##
###############################

#region Set-SpotifyDefaultSession

Function Set-SpotifyDefaultSession {

    <#

        .SYNOPSIS

            Sets the current default session information with Spotify.

        .DESCRIPTION

            Sets the current default session information with Spotify. Includes information such as Refresh and Access token.

        .PARAMETER RefreshToken

            The Refresh Token used to retrive new Access Tokens. Refresh Tokens can be retrieved using the Initialize-SpotifyAuthorizationCodeFlow
            command.

        .PARAMETER ExpiresOn

            The DateTime in which the Access Token will expire.

        .PARAMETER AccessToken

            The current Access Token for making Spotify API calls.

        .PARAMETER AuthenticationToken

            An AuthenticationToken object. The default AuthenticationObject will be the same object as the one provided.

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

          [hashtable]$SpotifyEnvironment)

    Process {

        If ($script:SpotifyDefaultAuthenticationToken -eq $null) { $script:SpotifyDefaultAuthenticationToken = [NewGuy.PoshSpotify.AuthenticationToken]::new() }

        If ($AuthenticationToken) { $script:SpotifyDefaultAuthenticationToken = $AuthenticationToken }
        Else {
            If ($RefreshToken) { $script:SpotifyDefaultAuthenticationToken.RefreshToken = $RefreshToken }
            If ($AccessToken) { $script:SpotifyDefaultAuthenticationToken.AccessToken = $AccessToken }
            If ($ExpiresOn) { $script:SpotifyDefaultAuthenticationToken.ExpiresOn = $ExpiresOn }
        }

    }

}

Export-ModuleMember -Function 'Set-SpotifyDefaultSession'

#endregion Set-SpotifyDefaultSession

#====================================================================================================================================================
######################################
## Initialize-SpotifyDefaultSession ##
######################################

#region Initialize-SpotifyDefaultSession

Function Initialize-SpotifyDefaultSession {

    <#

        .SYNOPSIS

            Initializes the current default session information with Spotify.

        .DESCRIPTION

            Initializes the current default session information with Spotify. Gathers information such as Refresh and Access token.

        .PARAMETER Force

            Forces a re-initialization of the default session if one was already previously initialized for the current session.

    #>

    [CmdletBinding()]
    [OutputType('NewGuy.PoshSpotify.AuthenticationToken')]

    Param([switch]$Force)

    If (!$Force -and $script:SpotifyDefaultAuthenticationToken.AccessToken -and ($script:SpotifyDefaultAuthenticationToken.ExpiresOn -gt (Get-Date))) { $authObj = $script:SpotifyDefaultAuthenticationToken }
    ElseIf (!$Force -and $script:SpotifyDefaultAuthenticationToken.RefreshToken) { $authObj = Initialize-SpotifyAuthorizationCodeFlow -RefreshToken $script:SpotifyDefaultAuthenticationToken.RefreshToken }
    Else { $authObj = Initialize-SpotifyAuthorizationCodeFlow }

    # Keep previously recorded scopes if new authorization object doesn't contain any.
    If (($script:SpotifyDefaultAuthenticationToken.Scopes.Count -gt 0) -and ($authObj.Scopes.Count -eq 0)) {
        $authObj.Scopes = $script:SpotifyDefaultAuthenticationToken.Scopes
    }

    $script:SpotifyDefaultAuthenticationToken = $authObj

    Return $authObj

}

Export-ModuleMember -Function 'Initialize-SpotifyDefaultSession'

#endregion Initialize-SpotifyDefaultSession

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

            Returns the current default Access Token or $null if not initialized.

        .DESCRIPTION

            Returns the current default Access Token or $null if not initialized.

        .PARAMETER IsRequired

            If this switch is given, terminating errors will occur if an Access Token has not yet been initialized.

    #>

    [CmdletBinding()]
    [OutputType([string])]

    Param([switch]$IsRequired)

    If ($script:SpotifyDefaultAuthenticationToken.AccessToken) { Return $script:SpotifyDefaultAuthenticationToken.AccessToken }
    ElseIf ($IsRequired) { Throw 'An Access Token is required for this procedure. Either provide an Access Token to the -AccessToken parameter or configure a new session with the Initialize-SpotifyDefaultSession command.' }
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

    #>

    [CmdletBinding()]

    Param([ValidateSet('Play',
                       'Pause',
                       'Skip',
                       'NextTrack',
                       'SkipBack',
                       'PreviousTrack')] [string[]]$Aliases)

    If (($Aliases.Count -eq 0) -or ($Aliases -contains 'Play')) { Set-Alias -Name Play -Value Start-SpotifyPlayback -Scope Global }
    If (($Aliases.Count -eq 0) -or ($Aliases -contains 'Pause')) { Set-Alias -Name Pause -Value Stop-SpotifyPlayback -Scope Global }
    If (($Aliases.Count -eq 0) -or ($Aliases -contains 'Skip')) { Set-Alias -Name Skip -Value Skip-SpotifyNextTrack -Scope Global }
    If (($Aliases.Count -eq 0) -or ($Aliases -contains 'NextTrack')) { Set-Alias -Name NextTrack -Value Skip-SpotifyNextTrack -Scope Global }
    If (($Aliases.Count -eq 0) -or ($Aliases -contains 'SkipBack')) { Set-Alias -Name SkipBack -Value Skip-SpotifyPreviousTrack -Scope Global }
    If (($Aliases.Count -eq 0) -or ($Aliases -contains 'PreviousTrack')) { Set-Alias -Name PreviousTrack -Value Skip-SpotifyPreviousTrack -Scope Global }

}

Export-ModuleMember -Function 'Add-SpotifyCommandAlias'

#endregion Add-SpotifyCommandAlias

#endregion Spotify Default Session Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
