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

Function Get-SpotifyEnvironmentInfo {

    <#

        .SYNOPSIS

            Returns the current SpotifyEnvironmentInfo configuration.

        .DESCRIPTION

            Returns the current SpotifyEnvironmentInfo configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

    #>

    [CmdletBinding()]

    Param()

    # Hashtables pass by reference. So we have to recreate/clone them to prevent the user from modifying the hashtable they are getting
    # and in turn modifying the hashtable stored in this module without a proper validation test being performed on it.
    $userEnvironmentInfo = @{}
    $SpotifyEnvironmentInfo.Keys | ForEach-Object { $userEnvironmentInfo[$_] = $SpotifyEnvironmentInfo[$_].Clone() }
    Return $userEnvironmentInfo

}

Export-ModuleMember -Function 'Get-SpotifyEnvironmentInfo'

#endregion Get-SpotifyEnvironmentInfo

#====================================================================================================================================================
################################
## Set-SpotifyEnvironmentInfo ##
################################

#region Set-SpotifyEnvironmentInfo

Function Set-SpotifyEnvironmentInfo {

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

    Param([Parameter(Mandatory)] [hashtable]$SpotifyEnvironmentInfo,
          [Parameter(Mandatory)] [string]$SpotifyDefaultEnv)

    # Save the old info in case we have to restore it.
    $oldInfo = $script:SpotifyEnvironmentInfo
    $oldDefault = $script:SpotifyDefaultEnv

    # Set the current environment info to the specified info.
    # Hashtables pass by reference. So we have to recreate/clone them to prevent the user from modifying the hashtable they passed in
    # and in turn modifying the hashtable stored in this module without a proper validation test being performed on it.
    $userEnvironmentInfo = @{}
    $SpotifyEnvironmentInfo.Keys | ForEach-Object { $userEnvironmentInfo[$_] = $SpotifyEnvironmentInfo[$_].Clone() }
    $script:SpotifyEnvironmentInfo = $userEnvironmentInfo
    $script:SpotifyDefaultEnv = $SpotifyDefaultEnv

    # Verify the info is correct.
    Try {
        Test-SpotifyEnvInfoFormat | Out-Null
    } Catch {
        # Something is wrong with the hashtable format or default environment. Restoring old values.
        $script:SpotifyEnvironmentInfo = $oldInfo
        $script:SpotifyDefaultEnv = $oldDefault
        Throw  # Retrhow error.
    }

}

Export-ModuleMember -Function 'Set-SpotifyEnvironmentInfo'

#endregion Set-SpotifyEnvironmentInfo

#====================================================================================================================================================
#################################
## Save-SpotifyEnvironmentInfo ##
#################################

#region Save-SpotifyEnvironmentInfo

Function Save-SpotifyEnvironmentInfo {

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

    Param([string]$FilePath = ($script:SpotifyDefaultEnvironmentInfoSaveLocation + '\' + $script:SpotifyDefaultEnvironmentInfoSaveFilename),
          [switch]$NoTimestampAppend)

        If (-not $NoTimestampAppend) {
            $ext = [IO.Path]::GetExtension($FilePath)
            $FilePath = $FilePath -replace "$ext$","_$(Get-Date -Format 'HH.MM.ss_MMM.dd')$ext"
        }

    $script:SpotifyDefaultEnv, $script:SpotifyEnvironmentInfo | ConvertTo-Json | Out-File $FilePath

    Write-Host "`nEnvironmentInfo saved to: $FilePath" -ForegroundColor Cyan

}

Export-ModuleMember -Function 'Save-SpotifyEnvironmentInfo'

#endregion Save-SpotifyEnvironmentInfo

#====================================================================================================================================================
###################################
## Import-SpotifyEnvironmentInfo ##
###################################

#region Import-SpotifyEnvironmentInfo

Function Import-SpotifyEnvironmentInfo {

    <#

        .SYNOPSIS

            Loads the environment information with Spotify.

        .DESCRIPTION

            Loads the environment information with Spotify.

        .PARAMETER FilePath

            The path to load the environment information with Spotify from.

    #>

    [CmdletBinding()]

    Param([string]$FilePath)

    # Throw all errors to stop the script.
    $ErrorActionPreference = 'Stop'

    # If FilePath was not provided build a default one. This only works if it was saved with default path and appended timestamp.
    # An * will be added as a wildcard for the date/time part of the filename.
    If (($FilePath -eq $null) -or ($FilePath -eq '')) {
        $FilePath = ($script:SpotifyDefaultEnvironmentInfoSaveLocation + '\' + $script:SpotifyDefaultEnvironmentInfoSaveFilename)
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
    $jsonObjs = (Get-Content $file | ConvertFrom-Json)

    # Make sure we got something back.
    If (($jsonObj -eq $null) -or ($jsonObj -eq '')) { Throw "Failed to retrieve information from provided file path : $FilePath" }

    # First object should be a string representing the default environment info.
    $defaultEnvInfo = $jsonObjs[0]

    # Second object should be a hashtable of environment info hashtables.
    # Though ConvertFrom-Json returns PSCustomObject. Need to conver to hashtables.
    $envInfoObj = $jsonObjs[1]
    $envInfoHT = @{}
    Foreach ($env In ($envInfoObj | Get-Member -MemberType NoteProperty)) {
        $envInfoHT.($env.Name) = @{}
        Foreach ($setting In ($envInfoObj.($env.Name) | Get-Member -MemberType NoteProperty)) {
            $envInfoHT.($env.Name).($setting.Name) = $envInfoObj.($env.Name).($setting.Name)
        }
    }

    Set-SpotifyEnvironmentInfo -SpotifyEnvironmentInfo $envInfoHT -SpotifyDefaultEnv $defaultEnvInfo

    Return Get-SpotifyEnvironmentInfo

}

Export-ModuleMember -Function 'Import-SpotifyEnvironmentInfo'

#endregion Import-SpotifyEnvironmentInfo

#====================================================================================================================================================
#################################
## Set-SpotifyEnvironmentProxy ##
#################################

#region Set-SpotifyEnvironmentProxy

Function Set-SpotifyEnvironmentProxy {

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

            The switch to indicate whether shortname hosts will bypass the proxy. By default this will be set to false.

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

    Param([Parameter(Mandatory, ParameterSetName = 'UseSystemSettings')] [switch]$UseSystemSettings,
          [Parameter(Mandatory, ParameterSetName = 'ManualEntry')] [string]$Server,
          [Parameter(ParameterSetName = 'ManualEntry')] [int]$Port,
          [Parameter(ParameterSetName = 'ManualEntry')] [array]$BypassList,
          [Parameter(ParameterSetName = 'ManualEntry')] [switch]$BypassOnLocal,
          [Parameter(ParameterSetName = 'ManualEntry')] [Parameter(ParameterSetName = 'UseSystemSettings')] [pscredential]$Credentials,
          [Parameter(ParameterSetName = 'ManualEntry')] [Parameter(ParameterSetName = 'UseSystemSettings')] [switch]$UseDefaultCredentials,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    # Save the old info in case we have to restore it.
    $oldEnvInfo = $script:SpotifyEnvironmentInfo[$SpotifyEnv]

    If ($PSCmdlet.ParameterSetName -eq 'UseSystemSettings') {
        $systemProxy = Get-SpotifySystemProxy

        If (($systemProxy -ne $null) -and ($systemProxy.ProxyEnabled)) {
            $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyServer = ($systemProxy.ProxyServer -split ':')[0]
            If (($systemProxy.ProxyServer -split ':')[1] -ne $null) { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyPort = ($systemProxy.ProxyServer -split ':')[1] }
            If ($systemProxy.BypassList -match '<local>') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyBypassOnLocal = $true }
            If ($systemProxy.BypassList.Length -gt 0) { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyBypassList = ($systemProxy.BypassList -replace '<local>;','') -split ';' }
            If ($PSBoundParameters.Keys -contains 'Credentials') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyUsername = $Credentials.UserName; $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyPasswordEncrypted = ConvertFrom-SecureString -SecureString $Credentials.Password }
            If ($PSBoundParameters.Keys -contains 'UseDefaultCredentials') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyUseDefaultCredentials = [bool]$UseDefaultCredentials }
        }
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'ManualEntry') {

        $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyServer = $Server
        If ($PSBoundParameters.Keys -contains 'Port') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyPort = $Port }
        If ($PSBoundParameters.Keys -contains 'BypassList') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyBypassList = $BypassList }
        If ($PSBoundParameters.Keys -contains 'BypassOnLocal') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyBypassOnLocal = [bool]$BypassOnLocal }
        If ($PSBoundParameters.Keys -contains 'Credentials') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyUsername = $Credentials.UserName; $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyPasswordEncrypted = ConvertFrom-SecureString -SecureString $Credentials.Password }
        If ($PSBoundParameters.Keys -contains 'UseDefaultCredentials') { $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyUseDefaultCredentials = [bool]$UseDefaultCredentials }

        # Verify the info is in a correct format.
        Try {
            Test-SpotifyEnvInfoFormat | Out-Null
        } Catch {
            # Something is wrong with the hashtable format or default environment. Restoring old values.
            $script:SpotifyEnvironmentInfo[$SpotifyEnv] = $oldEnvInfo
            Throw  # Retrhow error.
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
#####################
## Test-SpotifyEnv ##
#####################

#region Test-SpotifyEnv

# Test to ensure the provided Spotify environment exists within the current Spotify evironment configuration hashtable.
Function Test-SpotifyEnv {

    Param ([Parameter(Mandatory)] [string]$SpotifyEnv)

    If ($script:SpotifyEnvironmentInfo[$SpotifyEnv]) { Return $true }
    Else { Throw ("The $SpotifyEnv key is not found in the SpotifyEnvironmentInfo hashtable. See https://github.com/The-New-Guy/Posh-Spotify for details:`nKeys:$($script:SpotifyEnvironmentInfo.Keys)") }

}

#endregion Test-SpotifyEnv

#====================================================================================================================================================
###############################
## Test-SpotifyEnvInfoFormat ##
###############################

#region Test-SpotifyEnvInfoFormat

Function Test-SpotifyEnvInfoFormat {

    <#

        .SYNOPSIS

            Verifies the provided Spotify environment configuration hashtable is correctly formatted.

        .DESCRIPTION

            Verifies the provided Spotify environment configuration hashtable is correctly formatted. This configuration hashtable can created in a number of ways.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

        .NOTES

            The $script:SpotifyEnvironmentInfo hashtable must be of the following format to properly configure the Spotify environment info. Additionally the current $script:DefaultSpotifyEnv must match at least one of the provided keys in the main hashtable.

            $script:SpotifyEnvironmentInfo = @{

                Prod = @{

                    # Required Keys.

                    ClientId = 'DIxxxxxxxxxxxxxxxxxx'
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

                Dev = @{

                    # Required Keys.

                    ClientId = 'DIxxxxxxxxxxxxxxxxxx'
                    SecretKeyEncrypted = 'Big long protected SecureString represented as a string on 1 line here'

                    # Optional keys.

                    # ProxyServer = 'your-proxy-01.domain.local'
                    # ProxyPort = 8080
                    # ProxyBypassList = @('*.domain.local', '*.otherdomain.local')
                    # ProxyBypassOnLocal = $true
                    # ProxyUseDefaultCredentials = $true

                }
            }

    #>

    [CmdletBinding()]

    Param()

    Write-Debug "Environment Count : $($script:SpotifyEnvironmentInfo.Count)"
    Write-Debug "Environment Keys : `n$($script:SpotifyEnvironmentInfo.Keys | Out-String)"
    Write-Debug "Environment Settings : `n$(($script:SpotifyEnvironmentInfo.Keys | ForEach-Object { "$_ = @{`n" + ($script:SpotifyEnvironmentInfo[$_] | Out-String) + "}`n" }) -join "`n")"

    # Verify the whole thing is a non-empty hashtable.
    If (($script:SpotifyEnvironmentInfo -ne $null) -and ($script:SpotifyEnvironmentInfo -is [hashtable]) -and ($script:SpotifyEnvironmentInfo.Count -gt 0)) {

        # Verify that the Default Spotify Env is contianed within this hashtable.
        If (-not $script:SpotifyEnvironmentInfo.Contains($script:SpotifyDefaultEnv)) {
            Throw "The DefaultSpotifyEnv could not be found as a key to the SpotifyEnvironmentInfo hashtable:`nDefaultSpotifyEnv = $($script:SpotifyDefaultEnv)`nSpotifyEnvironmentIfno = $($script:SpotifyEnvironmentInfo | Out-String)"
        }

        # Verify each key is associated with another hashtable with the proper format.
        Foreach ($env In $script:SpotifyEnvironmentInfo.Keys) {

            ## Check required keys. ##

            # Verify the inner hashtables are in fact hashtables.
            If (($script:SpotifyEnvironmentInfo[$env] -eq $null) -or ($script:SpotifyEnvironmentInfo[$env] -isnot [hashtable])) {
                Throw "The $env key in the SpotifyEnvironmentInfo hashtable is not in the proper format. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
            }

            # The 'ClientId' should contain the Spotify API Integration Key.
            If (($script:SpotifyEnvironmentInfo[$env].ClientId -eq $null) -or
                ($script:SpotifyEnvironmentInfo[$env].ClientId -isnot [string]) -or
                ($script:SpotifyEnvironmentInfo[$env].ClientId.Length -eq 0)) {
                Throw "The $env key in the SpotifyEnvironmentInfo hashtable is missing the ClientId key or it is in the wrong format. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
            }

            # The final required key must be one of the following, but not both.
            # 1. The 'SecretKey' should contain the Spotify API Application Secret Key in plain text.
            # 2. The 'SecretKeyEncrypted' should contain the Spotify API Application Secret Key as a string representation of a SecureString.
            If ((($script:SpotifyEnvironmentInfo[$env].SecretKey -eq $null) -or
                 ($script:SpotifyEnvironmentInfo[$env].SecretKey -isnot [string]) -or
                 ($script:SpotifyEnvironmentInfo[$env].SecretKey.Length -eq 0)) -and
                (($script:SpotifyEnvironmentInfo[$env].SecretKeyEncrypted -eq $null) -or
                 ($script:SpotifyEnvironmentInfo[$env].SecretKeyEncrypted -isnot [string]) -or
                 ($script:SpotifyEnvironmentInfo[$env].SecretKeyEncrypted.Length -eq 0))) {
                Throw "The $env key in the SpotifyEnvironmentInfo hashtable is missing the SecretKey/SecretKeyEncrypted key or it is in the wrong format. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
            }

            ## Check optional proxy keys. ##

            # Only bother check if the ProxyServer key exists to begin with.
            If ($script:SpotifyEnvironmentInfo[$env].ProxyServer -ne $null) {

                # The 'ProxyServer' should contain the hostname of the proxy server to use.
                If (($script:SpotifyEnvironmentInfo[$env].ProxyServer -isnot [string]) -or ($script:SpotifyEnvironmentInfo[$env].ProxyServer.Length -eq 0)) {
                    Throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted ProxyServer key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                # Each of the additional proxy keys below should either not exist OR match the requirements below.

                # The 'ProxyPort' should contain the port use to connect to the proxy server.
                If (($script:SpotifyEnvironmentInfo[$env].ProxyPort -ne $null) -and
                    ((($script:SpotifyEnvironmentInfo[$env].ProxyPort -isnot [int]) -and ($script:SpotifyEnvironmentInfo[$env].ProxyPort -isnot [string])) -or
                     (($script:SpotifyEnvironmentInfo[$env].ProxyPort -as [int]) -le 0))) {
                    Throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted ProxyPort key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                # The 'ProxyBypassList' should contain an array of URIs that will not use the proxy server.
                If (($script:SpotifyEnvironmentInfo[$env].ProxyBypassList -ne $null) -and ($script:SpotifyEnvironmentInfo[$env].ProxyBypassList -isnot [array])) {
                    Throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted ProxyBypassList key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                # The 'ProxyBypassOnLocal' switch should be a bool or a switch.
                If (($script:SpotifyEnvironmentInfo[$env].ProxyBypassOnLocal -ne $null) -and ($script:SpotifyEnvironmentInfo[$env].ProxyBypassOnLocal -isnot [bool])) {
                    Throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted ProxyBypassOnLocal key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                # The 'ProxyUsername' should contain the username of the account needed to authenticate to the proxy server.
                If (($script:SpotifyEnvironmentInfo[$env].ProxyUsername -ne $null) -and
                    (($script:SpotifyEnvironmentInfo[$env].ProxyUsername -isnot [string]) -or ($script:SpotifyEnvironmentInfo[$env].ProxyUsername.Length -eq 0))) {
                    Throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted ProxyUsername key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                # The 'ProxyUseDefaultCredentials' switch should be a bool or a switch.
                If (($script:SpotifyEnvironmentInfo[$env].ProxyUseDefaultCredentials -ne $null) -and ($script:SpotifyEnvironmentInfo[$env].ProxyUseDefaultCredentials -isnot [bool])) {
                    Throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted ProxyUseDefaultCredentials key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                # The proxy password keys must be one of the following.
                # 1. The 'ProxyPassword' should contain the proxy password in plain text.
                # 2. The 'ProxyPasswordEncrypted' should contain the proxy password as a string representation of a SecureString.
                # 3. Neither should exist is the 'ProxyUsername' key does not exist and if it does exist then one and only one ProxyPassword/ProxyPasswordEncrypted should exist.
                If (($script:SpotifyEnvironmentInfo[$env].ProxyUsername -ne $null) -and ($script:SpotifyEnvironmentInfo[$env].ProxyPassword -eq $null) -and ($script:SpotifyEnvironmentInfo[$env].ProxyPasswordEncrypted -eq $null)) {
                    Throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an ProxyUsername key but does not contain a ProxyPassword or ProxyPasswordEncrypted key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }

                If (($script:SpotifyEnvironmentInfo[$env].ProxyUsername -ne $null) -and
                    ((($script:SpotifyEnvironmentInfo[$env].ProxyPassword -eq $null) -or
                      ($script:SpotifyEnvironmentInfo[$env].ProxyPassword -isnot [string]) -or
                      ($script:SpotifyEnvironmentInfo[$env].ProxyPassword.Length -eq 0)) -and
                     (($script:SpotifyEnvironmentInfo[$env].ProxyPasswordEncrypted -eq $null) -or
                      ($script:SpotifyEnvironmentInfo[$env].ProxyPasswordEncrypted -isnot [string]) -or
                      ($script:SpotifyEnvironmentInfo[$env].ProxyPasswordEncrypted.Length -eq 0)))) {
                    Throw "The $env key in the SpotifyEnvironmentInfo hashtable contains an improperly formatted ProxyPassword or ProxyPasswordEncrypted key. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo[$env] | Out-String)"
                }
            }
        }
    } Else {
        Throw "The SpotifyEnvironmentInfo hashtable is not defined or is not in the proper format. See https://github.com/The-New-Guy/Posh-Spotify for details:`n$($script:SpotifyEnvironmentInfo | Out-String)"
    }

    # If we made it this far then I call that a success.
    Return $true

}

#endregion Test-SpotifyEnvInfoFormat

#====================================================================================================================================================
############################
## Get-SpotifySystemProxy ##
############################

#region Get-SpotifySystemProxy

# Returns an object with the system proxy settings.
Function Get-SpotifySystemProxy {

    [CmdletBinding()]

    Param()

    Begin {

        # Result proxy settings object.
        $ProxySettings = New-Object PSCustomObject -Property @{
            ProxyEnabled = $false
            ProxyServer = ''
            BypassList = ''
        }

    }

    Process {

        # Retrieve the binary proxy setting data.
        $regVal = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" -Name WinHttpSettings -ErrorAction SilentlyContinue).WinHttPSettings
        If ($regVal -eq $null) { Return }

        # The first part of this binary data appears to be some static information followed by an Int32 that is either 1 for proxy cleared or 3 for proxy set.
        $headerLength = 12 - 1  # 8 bytes static info + 4 bytes Int32 = 12 bytes (starting at zero so minus one).

        # Our field lengths are 4 byte Int32 objects.
        $Int32ByteStop = 4 - 1  # Starting at zero.

        # Get proxy server string length.
        $proxyLengthByteStart = $headerLength + 1
        $proxyLengthByteStop = $proxyLengthByteStart + $Int32ByteStop
        $proxyLength = [System.BitConverter]::ToInt32($regVal[$proxyLengthByteStart..$proxyLengthByteStop], 0)

        If ($proxyLength -gt 0) {

            # Get the proxy servername string.
            $proxyByteStart = $proxyLengthByteStop + 1
            $proxyByteStop = $proxyByteStart + ($proxyLength - 1)
            $proxy = -join ($regVal[$proxyByteStart..$proxyByteStop] | ForEach-Object { [char]$_ })

            # Get the bypass list string length.
            $bypassLengthByteStart = $proxyByteStop + 1
            $bypassLengthByteStop = $bypassLengthByteStart + $Int32ByteStop
            $bypassLength = [System.BitConverter]::ToInt32($regVal[$bypassLengthByteStart..$bypassLengthByteStop], 0)

            If ($bypassLength -gt 0) {

                # Get the bypass list string.
                $bypassByteStart = $bypassLengthByteStop + 1
                $bypassByteStop = $bypassByteStart + ($bypassLength - 1)
                $bypassList = -join ($regVal[$bypassByteStart..$bypassByteStop] | ForEach-Object { [char]$_ })

            } Else {
                $bypasslist = ''
            }

            $ProxySettings.ProxyEnabled = $true
            $ProxySettings.ProxyServer = $proxy
            $ProxySettings.BypassList = $bypassList

        }
    }

    End {

        Return $ProxySettings
    }

}

#region Get-SpotifySystemProxy

#endregion Private Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>