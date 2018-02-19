<#

    All functions related to modifying the environmental configuration.

#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

######################
## Public Functions ##
######################

#region Public Functions

#====================================================================================================================================================
################################
## Get-SpotifyEnvironmentInfo ##
################################

#region Get-SpotifyEnvironmentInfo

function Get-SpotifyEnvironmentInfo {

    <#

        .SYNOPSIS

            Returns the current SpotifyEnvironmentInfo configuration.

        .DESCRIPTION

            Returns the current SpotifyEnvironmentInfo configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

    #>

    [CmdletBinding()]
    [OutputType('hashtable')]

    param()

    # Hashtables pass by reference. So we have to recreate/clone them to prevent the user from modifying the hashtable they are getting
    # and in turn modifying the hashtable stored in this module without a proper validation test being performed on it.
    $userEnvironmentInfo = Copy-SpotifyEnvInfo -SpotifyEnvInfo $SpotifyEnvironmentInfo
    return $userEnvironmentInfo

}

Export-ModuleMember -Function 'Get-SpotifyEnvironmentInfo'

#endregion Get-SpotifyEnvironmentInfo

#====================================================================================================================================================
################################
## Set-SpotifyEnvironmentInfo ##
################################

#region Set-SpotifyEnvironmentInfo

function Set-SpotifyEnvironmentInfo {

    <#

        .SYNOPSIS

            Sets the current SpotifyEnvironmentInfo configuration.

        .DESCRIPTION

            Sets the current SpotifyEnvironmentInfo configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER SpotifyEnvironmentInfo

            The new SpotifyEnvironmentInfo configuration you would like to set.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER SpotifyDefaultEnv

            The default environment to use in the specified SpotifyEnvironmentInfo configuration. If not specified the current default will remain unchanged.

    #>

    [CmdletBinding()]

    param([Parameter(Mandatory)] [hashtable]$SpotifyEnvironmentInfo,
          [Parameter(Mandatory)] [string]$SpotifyDefaultEnv)

    # Save the old info in case we have to restore it.
    $oldInfo = $script:SpotifyEnvironmentInfo
    $oldDefault = $script:SpotifyDefaultEnv

    # Set the current environment info to the specified info.
    # Hashtables pass by reference. So we have to recreate/clone them to prevent the user from modifying the hashtable they passed in
    # and in turn modifying the hashtable stored in this module without a proper validation test being performed on it.
    $userEnvironmentInfo = Copy-SpotifyEnvInfo -SpotifyEnvInfo $SpotifyEnvironmentInfo
    $script:SpotifyEnvironmentInfo = $userEnvironmentInfo
    $script:SpotifyDefaultEnv = $SpotifyDefaultEnv

    # Verify the info is correct.
    try {
        Test-SpotifyEnvInfoFormat | Out-Null
    } catch {
        # Something is wrong with the hashtable format or default environment. Restoring old values.
        $script:SpotifyEnvironmentInfo = $oldInfo
        $script:SpotifyDefaultEnv = $oldDefault
        throw  # Re-throw error.
    }

}

Export-ModuleMember -Function 'Set-SpotifyEnvironmentInfo'

#endregion Set-SpotifyEnvironmentInfo

#====================================================================================================================================================
#################################
## Save-SpotifyEnvironmentInfo ##
#################################

#region Save-SpotifyEnvironmentInfo

function Save-SpotifyEnvironmentInfo {

    <#

        .SYNOPSIS

            Saves the current environment information with Spotify.

        .DESCRIPTION

            Saves the current environment information with Spotify.

        .PARAMETER FilePath

            The path to save the environment information with Spotify to.

        .PARAMETER NoTimestampAppend

            By default this command appends the current date and time onto the filename of the save. This switch will prevent the appending of the
            timestamp.

    #>

    [CmdletBinding()]

    param([string]$FilePath = ($script:SpotifyDefaultEnvironmentInfoSaveLocation + '\' + $script:SpotifyDefaultEnvironmentInfoSaveFilename),
          [switch]$NoTimestampAppend)

        if (-not $NoTimestampAppend) {
            $ext = [IO.Path]::GetExtension($FilePath)
            $FilePath = $FilePath -replace "$ext$","_$(Get-Date -Format 'yyyy.MM.dd_HH.mm.ss')$ext"
        }

    $script:SpotifyDefaultEnv, $script:SpotifyEnvironmentInfo | ConvertTo-Json -Depth 5 | Out-File $FilePath

    Write-Host "`nEnvironmentInfo saved to: $FilePath" -ForegroundColor Cyan

}

Export-ModuleMember -Function 'Save-SpotifyEnvironmentInfo'

#endregion Save-SpotifyEnvironmentInfo

#====================================================================================================================================================
###################################
## Import-SpotifyEnvironmentInfo ##
###################################

#region Import-SpotifyEnvironmentInfo

function Import-SpotifyEnvironmentInfo {

    <#

        .SYNOPSIS

            Loads the environment information with Spotify.

        .DESCRIPTION

            Loads the environment information with Spotify.

        .PARAMETER FilePath

            The path to load the environment information with Spotify from.

    #>

    [CmdletBinding()]
    [OutputType('hashtable')]

    param([string]$FilePath)

    # Throw all errors to stop the script.
    $ErrorActionPreference = 'Stop'

    # If FilePath was not provided build a default one. This only works if it was saved with default path and appended timestamp.
    # An * will be added as a wildcard for the date/time part of the filename.
    if (($FilePath -eq $null) -or ($FilePath -eq '')) {
        $FilePath = ($script:SpotifyDefaultEnvironmentInfoSaveLocation + '\' + $script:SpotifyDefaultEnvironmentInfoSaveFilename)
        $ext = [IO.Path]::GetExtension($FilePath)
        $FilePath = $FilePath -replace "$ext$","_*$ext"
        Write-Verbose "No path specified. Searching in following path : $FilePath"
    }

    # Verify we have a valid file now.
    if (-not (Test-Path $FilePath)) { throw "Invalid file path : $FilePath" }

    # If there are multiple matches on FilePath, sort by name and pick the last one.
    # Assuming the files end in a date, it should be the newest file. If not then who knows what the user is looking for.
    $file = Get-ChildItem $FilePath | Sort-Object Name | Select-Object -Last 1

    # Grab from disk the saved information. This comes back as an array.
    $jsonObjs = (Get-Content $file | ConvertFrom-Json)

    # Make sure we got something back. Should be an array.
    if (($null -eq $jsonObjs) -or ($jsonObjs.Count -eq 0)) { throw "Failed to retrieve information from provided file path : $FilePath" }

    # First object should be a string representing the default environment info.
    $defaultEnvInfo = $jsonObjs[0]

    # Second object should be a hashtable of environment info hashtables.
    # Though ConvertFrom-Json returns PSCustomObject. Need to convert to hashtables.
    $envInfoObj = $jsonObjs[1]
    $envInfoHT = @{}
    foreach ($env in ($envInfoObj | Get-Member -MemberType NoteProperty)) {
        $envInfoHT.($env.Name) = @{}
        foreach ($setting in ($envInfoObj.($env.Name) | Get-Member -MemberType NoteProperty)) {
            $envInfoHT.($env.Name).($setting.Name) = $envInfoObj.($env.Name).($setting.Name)
        }
    }

    # Need to convert any UserSessions into actual AuthenticationToken objects.
    foreach ($env in $envInfoHT.Keys) {
        if ($envInfoHT.$env.UserSessions -is [array]) {

            # New array containing only converted AuthenticationToken objects.
            $newUserSessionsArray = @()

            foreach ($sess in $envInfoHT.$env.UserSessions) {

                # Calculate the remaining time left on the access token.
                $expiresOn = $sess.ExpiresOn.ToLocalTime()
                $expiresInSec = [int]($expiresOn - (Get-Date)).TotalSeconds

                # Create object and set optional properties.
                $newSess = [NewGuy.PoshSpotify.AuthenticationToken]::new($sess.AccessToken, $sess.TokenType, $expiresInSec)
                if ($sess.RefreshToken) { $newSess.RefreshToken = $sess.RefreshToken }
                if ($sess.Scopes) { $newSess.Scopes = $sess.Scopes }

                # Add new Authentication Token to new UserSessions array.
                $newUserSessionsArray += $newSess

            }

            # Overwrite the old UserSessions array with the new.
            $envInfoHT.$env.UserSessions = $newUserSessionsArray

        }
    }

    Set-SpotifyEnvironmentInfo -SpotifyEnvironmentInfo $envInfoHT -SpotifyDefaultEnv $defaultEnvInfo

    return Get-SpotifyEnvironmentInfo

}

Export-ModuleMember -Function 'Import-SpotifyEnvironmentInfo'

#endregion Import-SpotifyEnvironmentInfo

#====================================================================================================================================================
#################################
## Set-SpotifyEnvironmentProxy ##
#################################

#region Set-SpotifyEnvironmentProxy

function Set-SpotifyEnvironmentProxy {

    <#

        .SYNOPSIS

            Sets the proxy server information for a given Spotify environment configuration.

        .DESCRIPTION

            Sets the proxy server information for a given Spotify environment configuration. The specified Spotify configuration must already exist in the current configuration hashtable.

            For details on environment configurations and proxy settings please see https://github.com/The-New-Guy/Posh-Spotify.

        .PARAMETER UseSystemSettings

            If this switch is specified, the command will attempt to retrieve proxy settings from system and then assigns those settings to the specified Spotify environment configuration. The system settings referenced here are typically set via the 'netsh winhttp' command context.

            NOTE: Depending on your proxy server configuration you may or may not still need to provide credentials when using the system settings or specify the UseDefaultCredentials switch.

        .PARAMETER Server

            The proxy server hostname that will be used to connect to Spotify.

            This setting will be assigned to the specified Spotify environment configuration.

        .PARAMETER Port

            The port used to connect to the proxy server.

            This setting will be assigned to the specified Spotify environment configuration.

        .PARAMETER BypassList

            The list of URIs that will not use the proxy server.

            This setting will be assigned to the specified Spotify environment configuration.

        .PARAMETER BypassOnLocal

            The switch to indicate whether short name hosts will bypass the proxy. By default this will be set to false.

            This setting will be assigned to the specified Spotify environment configuration.

        .PARAMETER Credentials

            The credentials to be used when authenticating to the proxy server.

            This setting will be assigned to the specified Spotify environment configuration.

        .PARAMETER UseDefaultCredentials

            The switch to indicate whether or not to use Windows default credentials when authenticating to the proxy server. By default this will be set to false.

            This setting will be assigned to the specified Spotify environment configuration.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

    #>

    [CmdletBinding()]

    param([Parameter(Mandatory, ParameterSetName = 'UseSystemSettings')] [switch]$UseSystemSettings,
          [Parameter(Mandatory, ParameterSetName = 'ManualEntry')] [string]$Server,
          [Parameter(ParameterSetName = 'ManualEntry')] [int]$Port,
          [Parameter(ParameterSetName = 'ManualEntry')] [array]$BypassList,
          [Parameter(ParameterSetName = 'ManualEntry')] [switch]$BypassOnLocal,
          [Parameter(ParameterSetName = 'ManualEntry')] [Parameter(ParameterSetName = 'UseSystemSettings')] [pscredential]$Credentials,
          [Parameter(ParameterSetName = 'ManualEntry')] [Parameter(ParameterSetName = 'UseSystemSettings')] [switch]$UseDefaultCredentials,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    # Save the old info in case we have to restore it.
    $oldEnvInfo = $script:SpotifyEnvironmentInfo[$SpotifyEnv]

    if ($PSCmdlet.ParameterSetName -eq 'UseSystemSettings') {
        $systemProxy = Get-SpotifySystemProxy

        if (($systemProxy -ne $null) -and ($systemProxy.ProxyEnabled)) {
            $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyServer = ($systemProxy.ProxyServer -split ':')[0]
            if (($systemProxy.ProxyServer -split ':')[1] -ne $null) { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyPort = ($systemProxy.ProxyServer -split ':')[1] }
            if ($systemProxy.BypassList -match '<local>') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyBypassOnLocal = $true }
            if ($systemProxy.BypassList.Length -gt 0) { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyBypassList = ($systemProxy.BypassList -replace '<local>;','') -split ';' }
            if ($PSBoundParameters.Keys -contains 'Credentials') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyUsername = $Credentials.UserName; $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyPasswordEncrypted = ConvertFrom-SecureString -SecureString $Credentials.Password }
            if ($PSBoundParameters.Keys -contains 'UseDefaultCredentials') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyUseDefaultCredentials = [bool]$UseDefaultCredentials }
        }
    } elseif ($PSCmdlet.ParameterSetName -eq 'ManualEntry') {

        $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyServer = $Server
        if ($PSBoundParameters.Keys -contains 'Port') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyPort = $Port }
        if ($PSBoundParameters.Keys -contains 'BypassList') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyBypassList = $BypassList }
        if ($PSBoundParameters.Keys -contains 'BypassOnLocal') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyBypassOnLocal = [bool]$BypassOnLocal }
        if ($PSBoundParameters.Keys -contains 'Credentials') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyUsername = $Credentials.UserName; $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyPasswordEncrypted = ConvertFrom-SecureString -SecureString $Credentials.Password }
        if ($PSBoundParameters.Keys -contains 'UseDefaultCredentials') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyUseDefaultCredentials = [bool]$UseDefaultCredentials }

        # Verify the info is in a correct format.
        try {
            Test-SpotifyEnvInfoFormat | Out-Null
        } catch {
            # Something is wrong with the hashtable format or default environment. Restoring old values.
            $script:SpotifyEnvironmentInfo[$SpotifyEnv] = $oldEnvInfo
            throw  # Re-throw error.
        }

    }

}

Export-ModuleMember -Function 'Set-SpotifyEnvironmentProxy'

#endregion Set-SpotifyEnvironmentProxy

#endregion Public Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#######################
## Private Functions ##
#######################

#region Private Functions

#====================================================================================================================================================
#########################
## Copy-SpotifyEnvInfo ##
#########################

#region Copy-SpotifyEnvInfo

# Make a copy of the provided Spotify environment configuration hashtable. This hashtable may have come from the user and may be invalid.
# However, we don't care about validation, that will be done later. We will just clone the primitives and manually clone the known complex objects.
function Copy-SpotifyEnvInfo {

    Param ([Parameter(Mandatory)] [hashtable]$SpotifyEnvInfo)

    $userEnvironmentInfo = @{}
    $SpotifyEnvInfo.Keys | ForEach-Object { $userEnvironmentInfo[$_] = $SpotifyEnvInfo[$_].Clone() }

    # UserSessions should be an array containing AuthenticationTokens. If it doesn't, who cares, it will be caught later.
    foreach ($env in $userEnvironmentInfo.Keys) {
        if (($userEnvironmentInfo.$env.Keys -contains 'UserSessions') -and ($userEnvironmentInfo.$env.UserSessions -is [array])) {

            # New array containing only converted AuthenticationToken objects.
            $newUserSessionsArray = @()

            foreach ($sess in $userEnvironmentInfo.$env.UserSessions) {
                if ($sess -is [NewGuy.PoshSpotify.AuthenticationToken]) {

                    # Calculate the remaining time left on the access token.
                    $expiresOn = $sess.ExpiresOn
                    $expiresInSec = [int]($expiresOn - (Get-Date)).TotalSeconds

                    # Create object and set optional properties.
                    $newSess = [NewGuy.PoshSpotify.AuthenticationToken]::new($sess.AccessToken, $sess.TokenType, $expiresInSec)
                    if ($sess.RefreshToken) { $newSess.RefreshToken = $sess.RefreshToken }
                    if ($sess.Scopes) { $newSess.Scopes = $sess.Scopes }

                    # Add new Authentication Token to new UserSessions array.
                    $newUserSessionsArray += $newSess

                } else {
                    # Not an AuthenticationToken? Whatever, invalid data will be handled later.
                    $newUserSessionsArray = $sess
                }
            }

            # Overwrite the old UserSessions array with the new.
            $userEnvironmentInfo.$env.UserSessions = $newUserSessionsArray

        }
    }

    return $userEnvironmentInfo

}

#endregion Copy-SpotifyEnvInfo

#====================================================================================================================================================
#####################
## Test-SpotifyEnv ##
#####################

#region Test-SpotifyEnv

# Test to ensure the provided Spotify environment exists within the current Spotify environment configuration hashtable.
function Test-SpotifyEnv {

    Param ([Parameter(Mandatory)] [string]$SpotifyEnv)

    if ($script:SpotifyEnvironmentInfo[$SpotifyEnv]) { return $true }
    else { throw ("The $SpotifyEnv key is not found in the SpotifyEnvironmentInfo hashtable. See https://github.com/The-New-Guy/Posh-Spotify for details:`nKeys:$($script:SpotifyEnvironmentInfo.Keys)") }

}

#endregion Test-SpotifyEnv

#====================================================================================================================================================
###############################
## Test-SpotifyEnvInfoFormat ##
###############################

#region Test-SpotifyEnvInfoFormat

function Test-SpotifyEnvInfoFormat {

    <#

        .SYNOPSIS

            Verifies the provided Spotify environment configuration hashtable is correctly formatted.

        .DESCRIPTION

            Verifies the provided Spotify environment configuration hashtable is correctly formatted. This configuration hashtable can created in a
            number of ways.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .NOTES

            The $script:SpotifyEnvironmentInfo hashtable must be of the following format to properly configure the Spotify environment info.
            Additionally the current $script:DefaultSpotifyEnv must match at least one of the provided keys in the main hashtable.

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

                    # System Keys.

                    # User Session Array. An array of AuthenticationToken objects. This will be created by this module if not present.
                    UserSessions = @()

                }

                Work = @{

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
                    # ProxyPasswordEncrypted = 'Big long protected SecureString converted to a standard string (though encrypted) all on one line here'

                    # System Keys.

                    # User Session Array. An array of AuthenticationToken objects. This will be created by this module if not present.
                    UserSessions = @()

                }

                Test = @{

                    # Required Keys.

                    ClientId = 'yourClientIdHere'
                    SecretKey = 'YourSecretsHere'

                    # Optional keys.

                    CallbackUrl = 'http://localhost:8080/callback/'
                    DefaultScopes = @(
                        'user-modify-playback-state',
                        'user-read-playback-state',
                        'user-read-private'
                    )

                    # ProxyServer = 'your-proxy-01.domain.local'
                    # ProxyPort = 8080
                    # ProxyBypassList = @('*.domain.local', '*.otherdomain.local')
                    # ProxyBypassOnLocal = $true
                    # ProxyUseDefaultCredentials = $true

                    # System Keys.

                    # User Session Array. An array of AuthenticationToken objects. This will be created by this module if not present.
                    UserSessions = @()

                }
            }

    #>

    [CmdletBinding()]

    param()

    Write-Debug "Environment Count : $($script:SpotifyEnvironmentInfo.Count)"
    Write-Debug "Environment Keys : `n$($script:SpotifyEnvironmentInfo.Keys | Out-String)"
    Write-Debug "Environment Settings : `n$(($script:SpotifyEnvironmentInfo.Keys | ForEach-Object { "$_ = @{`n" + ($script:SpotifyEnvironmentInfo[$_] | Out-String) + "}`n" }) -join "`n")"

    # Verify the whole thing is a non-empty hashtable.
    if (($script:SpotifyEnvironmentInfo -ne $null) -and ($script:SpotifyEnvironmentInfo -is [hashtable]) -and ($script:SpotifyEnvironmentInfo.Count -gt 0)) {

        # Verify that the Default Spotify Env is contained within this hashtable.
        if (-not $script:SpotifyEnvironmentInfo.Contains($script:SpotifyDefaultEnv)) {
            throw "The DefaultSpotifyEnv could not be found as a key to the SpotifyEnvironmentInfo hashtable:`nDefaultSpotifyEnv = $($script:SpotifyDefaultEnv)`nSpotifyEnvironmentIfno = $($script:SpotifyEnvironmentInfo | Out-String)"
        }

        # Verify each key is associated with another hashtable with the proper format.
        foreach ($env in $script:SpotifyEnvironmentInfo.Keys) {

            ## Check required keys. ##

            # Verify the inner hashtables are in fact hashtables.
            if (($script:SpotifyEnvironmentInfo[$env] -eq $null) -or ($script:SpotifyEnvironmentInfo[$env] -isnot [hashtable])) {
                throw "The $env key in the SpotifyEnvironmentInfo hashtable is not in the proper format. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
            }

            # The 'ClientId' should contain the Spotify API Integration Key.
            if (($script:SpotifyEnvironmentInfo[$env].ClientId -eq $null) -or
                ($script:SpotifyEnvironmentInfo[$env].ClientId -isnot [string]) -or
                ($script:SpotifyEnvironmentInfo[$env].ClientId.Length -eq 0)) {
                throw "The $env key in the SpotifyEnvironmentInfo hashtable is missing the ClientId key or it is in the wrong format. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
            }

            # The final required key must be one of the following.
            # 1. The 'SecretKey' should contain the Spotify API Application Secret Key in plain text.
            # 2. The 'SecretKeyEncrypted' should contain the Spotify API Application Secret Key as a string representation of a SecureString.
            if ((($script:SpotifyEnvironmentInfo[$env].SecretKey -eq $null) -or
                 ($script:SpotifyEnvironmentInfo[$env].SecretKey -isnot [string]) -or
                 ($script:SpotifyEnvironmentInfo[$env].SecretKey.Length -eq 0)) -and
                (($script:SpotifyEnvironmentInfo[$env].SecretKeyEncrypted -eq $null) -or
                 ($script:SpotifyEnvironmentInfo[$env].SecretKeyEncrypted -isnot [string]) -or
                 ($script:SpotifyEnvironmentInfo[$env].SecretKeyEncrypted.Length -eq 0))) {
                throw "The $env key in the SpotifyEnvironmentInfo hashtable is missing the SecretKey/SecretKeyEncrypted key or it is in the wrong format. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
            }

            # The above check does not account for the case where SecretKey is valid but SecretKeyEncrypted is invalid.
            # Since SecretKeyEncrypted is used by default when both keys are given we will do a second check on SecretKeyEncrypted.
            if (($script:SpotifyEnvironmentInfo[$env].SecretKeyEncrypted -ne $null) -and
                (($script:SpotifyEnvironmentInfo[$env].SecretKeyEncrypted -isnot [string]) -or
                 ($script:SpotifyEnvironmentInfo[$env].SecretKeyEncrypted.Length -eq 0))) {
                throw "The $env key in the SpotifyEnvironmentInfo hashtable has a SecretKeyEncrypted key in the wrong format. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
            }

            ## Check optional CallbackUrl and DefaultScopes keys. ##

            # The 'CallbackUrl' should contain the callback URL registered with Spotify and will be used to redirect users to after authentication.
            if (($script:SpotifyEnvironmentInfo[$env].CallbackUrl -ne $null) -and
                (($script:SpotifyEnvironmentInfo[$env].CallbackUrl -isnot [string]) -or
                 ($script:SpotifyEnvironmentInfo[$env].CallbackUrl.Length -eq 0))) {
                throw "The $env key in the SpotifyEnvironmentInfo hashtable has a CallbackUrl key in the wrong format. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
            }

            # The 'DefaultScopes' should contain a list of strings that representing the permission scopes you are requesting access for during authentication.
            if (($script:SpotifyEnvironmentInfo[$env].DefaultScopes -ne $null) -and ($script:SpotifyEnvironmentInfo[$env].DefaultScopes -isnot [array])) {
                throw "The $env key in the SpotifyEnvironmentInfo hashtable has a DefaultScopes key in the wrong format. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
            }

            ## Check optional proxy keys. ##

            # Only bother check if the ProxyServer key exists to begin with.
            if ($script:SpotifyEnvironmentInfo[$env].ProxyServer -ne $null) {

                # The 'ProxyServer' should contain the hostname of the proxy server to use.
                if (($script:SpotifyEnvironmentInfo[$env].ProxyServer -isnot [string]) -or ($script:SpotifyEnvironmentInfo[$env].ProxyServer.Length -eq 0)) {
                    throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted ProxyServer key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                # Each of the additional proxy keys below should either not exist OR match the requirements below.

                # The 'ProxyPort' should contain the port use to connect to the proxy server.
                if (($script:SpotifyEnvironmentInfo[$env].ProxyPort -ne $null) -and
                    ((($script:SpotifyEnvironmentInfo[$env].ProxyPort -isnot [int]) -and ($script:SpotifyEnvironmentInfo[$env].ProxyPort -isnot [string])) -or
                     (($script:SpotifyEnvironmentInfo[$env].ProxyPort -as [int]) -le 0))) {
                    throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted ProxyPort key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                # The 'ProxyBypassList' should contain an array of URIs that will not use the proxy server.
                if (($script:SpotifyEnvironmentInfo[$env].ProxyBypassList -ne $null) -and ($script:SpotifyEnvironmentInfo[$env].ProxyBypassList -isnot [array])) {
                    throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted ProxyBypassList key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                # The 'ProxyBypassOnLocal' switch should be a bool or a switch.
                if (($script:SpotifyEnvironmentInfo[$env].ProxyBypassOnLocal -ne $null) -and ($script:SpotifyEnvironmentInfo[$env].ProxyBypassOnLocal -isnot [bool])) {
                    throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted ProxyBypassOnLocal key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                # The 'ProxyUsername' should contain the username of the account needed to authenticate to the proxy server.
                if (($script:SpotifyEnvironmentInfo[$env].ProxyUsername -ne $null) -and
                    (($script:SpotifyEnvironmentInfo[$env].ProxyUsername -isnot [string]) -or ($script:SpotifyEnvironmentInfo[$env].ProxyUsername.Length -eq 0))) {
                    throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted ProxyUsername key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                # The 'ProxyUseDefaultCredentials' switch should be a bool or a switch.
                if (($script:SpotifyEnvironmentInfo[$env].ProxyUseDefaultCredentials -ne $null) -and ($script:SpotifyEnvironmentInfo[$env].ProxyUseDefaultCredentials -isnot [bool])) {
                    throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted ProxyUseDefaultCredentials key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                # The proxy password keys must be one of the following.
                # 1. The 'ProxyPassword' should contain the proxy password in plain text.
                # 2. The 'ProxyPasswordEncrypted' should contain the proxy password as a string representation of a SecureString.
                if (($script:SpotifyEnvironmentInfo[$env].ProxyUsername -ne $null) -and ($script:SpotifyEnvironmentInfo[$env].ProxyPassword -eq $null) -and ($script:SpotifyEnvironmentInfo[$env].ProxyPasswordEncrypted -eq $null)) {
                    throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an ProxyUsername key but does not contain a ProxyPassword or ProxyPasswordEncrypted key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                if (($script:SpotifyEnvironmentInfo[$env].ProxyUsername -ne $null) -and
                    ((($script:SpotifyEnvironmentInfo[$env].ProxyPassword -eq $null) -or
                      ($script:SpotifyEnvironmentInfo[$env].ProxyPassword -isnot [string]) -or
                      ($script:SpotifyEnvironmentInfo[$env].ProxyPassword.Length -eq 0)) -and
                     (($script:SpotifyEnvironmentInfo[$env].ProxyPasswordEncrypted -eq $null) -or
                      ($script:SpotifyEnvironmentInfo[$env].ProxyPasswordEncrypted -isnot [string]) -or
                      ($script:SpotifyEnvironmentInfo[$env].ProxyPasswordEncrypted.Length -eq 0)))) {
                    throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted ProxyPassword or ProxyPasswordEncrypted key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                # The above check does not account for the case where ProxyPassword is valid but ProxyPasswordEncrypted is invalid.
                # Since ProxyPasswordEncrypted is used by default when both keys are given we will do a second check on ProxyPasswordEncrypted.
                if (($script:SpotifyEnvironmentInfo[$env].ProxyUsername -ne $null) -and
                    ($script:SpotifyEnvironmentInfo[$env].ProxyPasswordEncrypted -ne $null) -and
                    (($script:SpotifyEnvironmentInfo[$env].ProxyPasswordEncrypted -isnot [string]) -or
                     ($script:SpotifyEnvironmentInfo[$env].ProxyPasswordEncrypted.Length -eq 0))) {
                        throw "The $env key in the SpotifyEnvironmentInfo hashtable has a ProxyPasswordEncrypted key in the wrong format. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }
            }

            ## Check system keys. ##

            # If the UserSessions key exists, make sure it is an array containing only AuthenticationToken objects.
            if ($script:SpotifyEnvironmentInfo[$env].UserSessions -ne $null) {
                if (($script:SpotifyEnvironmentInfo[$env].UserSessions -isnot [array]) -or
                    ($script:SpotifyEnvironmentInfo[$env].UserSessions | ForEach-Object -Begin { $NotValid = $false } `
                                                                                        -Process { if ($_ -isnot [NewGuy.PoshSpotify.AuthenticationToken]) { $NotValid = $true } } `
                                                                                        -End { return $NotValid })) {
                    throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted UserSessions key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }
            }
        }
    } else {
        throw "The SpotifyEnvironmentInfo hashtable is not defined or is not in the proper format. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo | Out-String)"
    }

    # If we made it this far then I call that a success.
    return $true

}

#endregion Test-SpotifyEnvInfoFormat

#====================================================================================================================================================
############################
## Get-SpotifySystemProxy ##
############################

#region Get-SpotifySystemProxy

# Returns an object with the system proxy settings.
function Get-SpotifySystemProxy {

    [CmdletBinding()]

    param()

    begin {

        # Result proxy settings object.
        $ProxySettings = New-Object PSCustomObject -Property @{
            ProxyEnabled = $false
            ProxyServer = ''
            BypassList = ''
        }

    }

    process {

        # Retrieve the binary proxy setting data.
        $regVal = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" -Name WinHttpSettings -ErrorAction SilentlyContinue).WinHttPSettings
        if ($regVal -eq $null) { return }

        # The first part of this binary data appears to be some static information followed by an Int32 that is either 1 for proxy cleared or 3 for proxy set.
        $headerLength = 12 - 1  # 8 bytes static info + 4 bytes Int32 = 12 bytes (starting at zero so minus one).

        # Our field lengths are 4 byte Int32 objects.
        $Int32ByteStop = 4 - 1  # Starting at zero.

        # Get proxy server string length.
        $proxyLengthByteStart = $headerLength + 1
        $proxyLengthByteStop = $proxyLengthByteStart + $Int32ByteStop
        $proxyLength = [System.BitConverter]::ToInt32($regVal[$proxyLengthByteStart..$proxyLengthByteStop], 0)

        if ($proxyLength -gt 0) {

            # Get the proxy server name string.
            $proxyByteStart = $proxyLengthByteStop + 1
            $proxyByteStop = $proxyByteStart + ($proxyLength - 1)
            $proxy = -join ($regVal[$proxyByteStart..$proxyByteStop] | ForEach-Object { [char]$_ })

            # Get the bypass list string length.
            $bypassLengthByteStart = $proxyByteStop + 1
            $bypassLengthByteStop = $bypassLengthByteStart + $Int32ByteStop
            $bypassLength = [System.BitConverter]::ToInt32($regVal[$bypassLengthByteStart..$bypassLengthByteStop], 0)

            if ($bypassLength -gt 0) {

                # Get the bypass list string.
                $bypassByteStart = $bypassLengthByteStop + 1
                $bypassByteStop = $bypassByteStart + ($bypassLength - 1)
                $bypassList = -join ($regVal[$bypassByteStart..$bypassByteStop] | ForEach-Object { [char]$_ })

            } else {
                $bypasslist = ''
            }

            $ProxySettings.ProxyEnabled = $true
            $ProxySettings.ProxyServer = $proxy
            $ProxySettings.BypassList = $bypassList

        }
    }

    end {

        return $ProxySettings
    }

}

#endregion Get-SpotifySystemProxy

#endregion Private Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>