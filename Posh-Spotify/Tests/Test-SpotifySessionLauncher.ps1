<#

    This script ensures each pester test has a valid Spotify session to work with.

#>

# If the parameter below is not provided default locations will be used. See the module documentation for details.
Param([string]$EnvironmentInfoFilePath)

# Remove any pre-existing or already loaded version of the module.
Get-Module Posh-Spotify | Remove-Module

# Import the module to be tested (up one folder).
Import-Module "$PSScriptRoot\..\Posh-Spotify.psd1"

Try {

    Import-SpotifyEnvironmentInfo -FilePath $EnvironmentInfoFilePath | Out-Null

} Catch {

    $errMsg = @"
Could not load Spotify session and environment info.

Exception Message: $($_.Exception.Message)

Please note these tests were designed to run using the module's default file name and location settings.
To run these tests ensure that there is a valid Spotify environment configuration file with a valid user session saved to the default locations or use the following to invoke the tests.

    Invoke-Pester -Script @{ Path = '.\*'; Parameters = @{ EnvironmentInfoFilePath = <EnvironmentInfoPath> } }
"@

    Throw $errMsg

}

Initialize-SpotifySession | Out-Null
