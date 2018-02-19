<#

    Invoke-SpotifyRequest and all supporting functions will be found here.

#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

###########################
## Invoke-SpotifyRequest ##
###########################

#region Invoke-SpotifyRequest

function Invoke-SpotifyRequest {

    <#

        .SYNOPSIS

            Generates and sends a new Spotify API request.

        .DESCRIPTION

            Generates and sends a new Spotify API request based on the provided parameters. For details on what calls can be made please review the
            Spotify documentation found at the following locations.

                Spotify API : https://developer.spotify.com/web-api

        .PARAMETER Path

            The Spotify API path for a given API call.

            EX: '/v1/browse/categories'

        .PARAMETER Method

            The HTTP method by which to submit the Spotify API call.

            EX: 'GET' or 'POST' or 'PUT' or 'DELETE'

        .PARAMETER QueryParameters

            A hashtable which contains key/value pairs of each Spotify API request that needs to be encoded and added to the query string of the
            request (i.e. The parameters are place in the URL of the request).

            EX: @{
                   country = 'US'
                   locale = 'en_US'
                 }

        .PARAMETER RequestBodyParameters

            A hashtable which contains key/value pairs of each Spotify API request that needs to be encoded as JSON and added to the body of the
            request (i.e. The parameters are place in the the body request as additional content).

            EX: @{
                   country = 'US'
                   locale = 'en_US'
                 }

        .PARAMETER Encoding

            The method by which the request body parameters should be encoded. Possible values include:

                 UrlEncoding OR JSON

            Default value is UrlEncoding.

        .PARAMETER AccessToken

            If provided, the Authorization header will be of type 'Bearer' and will contain this Access Token. If not provided the Authorization
            header will be of type 'Basic' and will contain the client id and secret key as specified by the given or default environment
            configuration.

        .PARAMETER RequestType

            Specifies the type of Spotify API request. This essentially controls which Spotify API hostname to use. Possible values include:

                 'WebAPI' or 'AccountsAPI'

            Default is 'WebAPI'.

        .PARAMETER ReturnRawBytes

            If this switch is set, the response body to the Spotify request will be returned as raw bytes. By default the response is converted from
            its native JSON format into a PSObject.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

    #>

    [CmdletBinding()]

    param([Parameter(Mandatory)] [string]$Path,
          [Parameter(Mandatory)] [ValidateSet('GET', 'POST', 'PUT', 'DELETE')] [string]$Method,
          [hashtable]$QueryParameters,
          [hashtable]$RequestBodyParameters,
          [ValidateSet('UrlEncoding','JSON')] [string]$Encoding = 'UrlEncoding',
          [string]$AccessToken,
          [ValidateSet('WebAPI', 'AccountsAPI')] [string]$RequestType = 'WebAPI',
          [switch]$ReturnRawBytes,
          [ValidateScript({ Test-SpotifyEnv -SpotifyEnv $_ })] [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    Write-Debug "Invoke-SpotifyRequest : Using Environment '$SpotifyEnv' : `n$($script:SpotifyEnvironmentInfo[$SpotifyEnv] | Out-String)"

    # Setup the query string if needed.
    $queryStr = ''
    if ($QueryParameters.Count -gt 0) {
            # URL encode requested parameters.
            $queryParams = Get-SpotifyEncodedParameter -RequestParameters $QueryParameters -Encoding UrlEncoding
            $queryStr = '?' + $queryParams
    }

    # Remove starting web hostname if present.
    $Path = $Path.Replace(('https://' + $script:SpotifyWebApiHostname), '')
    $Path = $Path.Replace(('https://' + $script:SpotifyAccountsApiHostname), '')

    # Add a leading slash to the path if not present unless it's full URL.
    if (($Path -notmatch '^/') -and ($Path -notmatch '^https?://')) { $Path = '/' + $Path }

    # Build the URI.
    if ($RequestType -eq 'WebAPI') { $uri = 'https://' + $script:SpotifyWebApiHostname + $Path + $queryStr }
    elseif ($RequestType -eq 'AccountsAPI') { $uri = 'https://' + $script:SpotifyAccountsApiHostname + $Path + $queryStr }

    # Build the request.
    try {

        # Create HTTP request and set its method.
        $request = [System.Net.HttpWebRequest]::CreateHttp($uri)
        if ($request) { $request.Method = $Method }
        else { throw "Error creating HTTP request for URI: $uri" }

        Write-Verbose ('[' + $request.Method + ' ' + $request.RequestUri + ']')
        Write-Debug ('[' + $request.Method + ' ' + $request.RequestUri + ']')

        # Set request encoding and user agent string.
        $request.Accept = 'application/json'
        $request.UserAgent = $script:SpotifyUserAgent

        # Add authorization header.
        $authN = Get-SpotifyAuthorizationHeader -SpotifyEnv $SpotifyEnv -AccessToken $AccessToken
        $request.Headers.Add('Authorization', $authN)

        Write-Debug "Authorization Header : $authN"

        # Configure proxy if needed.
        Set-SpotifyRequestProxy -Request $request -SpotifyEnv $SpotifyEnv

        # If sending request body parameters, convert to JSON and write out the bytes to the request object.
        if ($RequestBodyParameters.Count -gt 0) {

            $bodyParams = Get-SpotifyEncodedParameter -RequestParameters $RequestBodyParameters -Encoding $Encoding

            Write-Verbose "Request Body Parameters :`n$($bodyParams | Format-Table | Out-String)"
            Write-Debug "Request Body Parameters :`n$($bodyParams | Format-Table | Out-String)"

            # Get request parameter bytes for output stream and set content info.
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($bodyParams)
            $request.ContentType = 'application/x-www-form-urlencoded'
            $request.ContentLength = $bytes.Length

            # Get output stream from request object and write out the request parameter bytes.
            [System.IO.Stream]$outputStream = [System.IO.Stream]$request.GetRequestStream()
            $outputStream.Write($bytes,0,$bytes.Length)
            $outputStream.Close()
            Remove-Variable -Name outputStream

        }

        Write-Verbose 'Sending request...'

        # Send the request and wait for a response.
        [System.Net.HttpWebResponse]$response = $request.GetResponse()

        Write-Verbose 'Response received. Processing...'

        # Process the response.
        if ($response -eq $null) { throw "Error retrieving response from URI: $uri" }

        # Check for common response codes needing action.
        if ($response.StatusCode -eq '202') {

            # TODO

            # 202 ACCEPTED
            # Request was accepted but the resource is temporarily unavailable.
            # Need to wait 5 seconds and retry for no more than 5 retries.

        }

        if ($response.StatusCode -eq '204') {

            # TODO

            # 204 NO CONTENT
            # Request succeeded but there was no body content in the response.
            # If this occurs then the code below is not needed.

        }

        # Return just the raw bytes of the response body.
        if ($ReturnRawBytes) {

            # To get the bytes only we have to work directly with the response stream.
            $respStream = $response.GetResponseStream()

            # Need a buffer of known length to store bytes for each read operation.
            $buffer = New-Object System.Byte[] ($script:SpotifyBufferSize)

            $bytesRead = 0
            [byte[]]$respBodyBytes = @()
            while (($bytesRead = $respStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $respBodyBytes += $buffer[0..($bytesRead - 1)]
            }

            # Return raw response body as bytes.
            return $respBodyBytes

        # Convert the JSON response body to a PSObject if requested.
        } else {

            # Get the response body.
            $respStreamReader = New-Object System.IO.StreamReader($response.GetResponseStream())
            $respBody = $respStreamReader.ReadToEnd()
            $respStreamReader.Close()

            try {
                $respBodyObj = ConvertFrom-Json -InputObject $respBody
            } catch {
                Write-Warning "Response body could not be converted from JSON:`n$respBody"
                Write-Warning "JSON Conversion Exception: $($_.Exception.Message)"
            }

            # Return JSON converted response body.
            return $respBodyObj

        }

    # Handle Web Request errors.
    } catch [Net.WebException] {

        # Get the error from the response body if one exists and use it as a message in the error we are about to throw.
        if ($_.Exception.Response -ne $null) {

            [System.Net.HttpWebResponse]$response = $_.Exception.Response

            if ($response.StatusCode -eq '429') {

                # TODO

                # 429 TOO MANY REQUESTS
                # Rate limiting. Sent too many requests in a short period of time.
                # There should be a 'Retry-After' header containing the number of seconds you must wait before the next request can be made.
                # Need to make a decision as to whether to wait and try again or just return rate limiting error to user (or a switch for the option).

            } elseif ($response.StatusCode -match '^[45]\d\d$') {

                # TODO

                # 4xx or 5xx ERROR
                # Errors not specifically handled above. Spotify will return a Spotify Error object.
                # Need to make a decision as to whether to create a new class and convert the object or just throw the error below.
                # The error thrown below already displays this info but as a terminating exception. Do we want to force handling of these errors or
                # do we want to silently return a converted Spotify Error object (possibly unexpected by the caller). The wrapper functions would
                # have to check for this if necessary.

            } else {
                # <The Error Code Below>
            }

            $respStreamReader = New-Object System.IO.StreamReader($response.GetResponseStream())
            $respBody = $respStreamReader.ReadToEnd()
            $respStreamReader.Close()
            throw "Status Code : $([int]($response.StatusCode))`nStatus Description : $($response.StatusDescription)`nResponse Body :`n$respBody"
        } else {
            throw  # No response body so just re-throw the exception as is.
        }

    # Handle any other errors.
    } catch {

        throw  # Re-throw exception.

    # Clean up.
    } finally {

        if ($response) {

            $response.Close()
            $response.Dispose()

        }

    }

}

Export-ModuleMember -Function 'Invoke-SpotifyRequest'

#endregion Invoke-SpotifyRequest

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

##########################
## Supporting Functions ##
##########################

#region Supporting Functions

#====================================================================================================================================================
####################################
## Get-SpotifyAuthorizationHeader ##
####################################

#region Get-SpotifyAuthorizationHeader

# This function is called by the public command Invoke-SpotifyRequest to build the Authorization header.

function Get-SpotifyAuthorizationHeader {

    <#

        .SYNOPSIS

            Generates the Authorization header of the API call in a format required by the Spotify API.

        .DESCRIPTION

            Generates the Authorization header of the API call in a format required by the Spotify API. This format depends on whether the API call
            is using the client id and client secret for "Basic" authorization or the access token for "Bearer" authorization.

            This function is intended for internal use by this module only.

        .PARAMETER AccessToken

            If provide the Authorization header will be of type 'Bearer' and will contain this Access Token. If not provided the Authorization header
            will be of type 'Basic' and will contain the client id and secret key as specified by the given or default environment configuration.

        .PARAMETER SpotifyEnv

            A string matching a key in the Spotify environment configuration hashtable to be used when making Spotify API calls. If this parameter is
            not specified it will use the current default environment configuration.

            For details on environment configurations please see https://github.com/The-New-Guy/Posh-Spotify.

    #>

    [CmdletBinding()]

    param([string]$AccessToken,
          [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    if ($AccessToken) { $header = "Bearer $AccessToken" }
    else {

        if ($script:SpotifyEnvironmentInfo[$SpotifyEnv].SecretKeyEncrypted) {
            try {
                $secureSecretKey = ConvertTo-SecureString -String $script:SpotifyEnvironmentInfo[$SpotifyEnv].SecretKeyEncrypted -ErrorAction Stop
                $secretKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureSecretKey))
            } catch { throw "Invalid Encrypted Secret Key : $($_.Exception.Message)" }
            $authStr = $script:SpotifyEnvironmentInfo[$SpotifyEnv].ClientId + ':' + $secretKey
        } else {
            $authStr = $script:SpotifyEnvironmentInfo[$SpotifyEnv].ClientId + ':' + $script:SpotifyEnvironmentInfo[$SpotifyEnv].SecretKey
        }
        $basicAuthStr = Get-SpotifyEncode64 -PlainText $authStr
        $header = "Basic $basicAuthStr"

    }

    Write-Debug "Get-SpotifyAuthorizationHeader : `n$header"

    return $header

}

#endregion Get-SpotifyAuthorizationHeader

#====================================================================================================================================================
#################################
## Get-SpotifyEncodedParameter ##
#################################

#region Get-SpotifyEncodedParameter

# This function is called by the public command Invoke-SpotifyRequest to encode the request parameters.

function Get-SpotifyEncodedParameter {

    <#

        .SYNOPSIS

            Encodes a hashtable of parameters to be used in a Spotify API call and returns it as a string.

        .DESCRIPTION

            Encodes a hashtable of parameters to be used in a Spotify API call and returns it as a string.

            EX: username=janedoe&exFieldWithSpaces=some+value+with+spaces

            EX: {
                   username = 'janedoe'
                   exFieldWithSpaces = 'some value with spaces'
                }

            This function is intended for internal use by this module only.

        .PARAMETER RequestParameters

            A hashtable which contains key/value pairs of each Spotify API request parameter needed.

            EX: @{
                   username = 'janedoe'
                   exFieldWithSpaces = 'some value with spaces'
                 }

        .PARAMETER Encoding

            The method by which the parameters should be encoded. Possible values include:

                 UrlEncoding OR JSON

            Default value is UrlEncoding.

    #>

    [CmdletBinding()]

    param([hashtable]$RequestParameters,
          [ValidateSet('UrlEncoding','JSON')] [string]$Encoding = 'UrlEncoding')

    if ($RequestParameters.Count -gt 0) {

        $paramLines = @()

        if ($Encoding -eq 'UrlEncoding') {

            foreach ($key in $RequestParameters.keys) {

                # URL encode the the parameters.
                $param = [System.Web.HttpUtility]::UrlEncode($key) + '=' + [System.Web.HttpUtility]::UrlEncode($RequestParameters[$key])

                # Add the URL encoded parameter to the list of request parameters.
                $paramLines += $param

            }

            # Put parameters into one query string.
            $encodedParameters = $paramLines -join '&'

        } else {
            # JSON converted object.
            $encodedParameters = ConvertTo-Json $RequestParameters
        }

    } else {
        $encodedParameters = ''
    }

    Write-Debug "Get-SpotifyEncodedParameter : `n$encodedParameters"

    return $encodedParameters
}

#endregion Get-SpotifyEncodedParameter

#endregion Supporting Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#######################
## Utility Functions ##
#######################

#region Utility Functions

#====================================================================================================================================================
#########################
## Get-SpotifyEncode64 ##
#########################

#region Get-SpotifyEncode64

# Returns a Base64 encoded version of provided $Plaintext.
function Get-SpotifyEncode64 {

    Param ($PlainText)

    [byte[]]$plainTextBytes = [System.Text.Encoding]::ASCII.GetBytes($PlainText)

    return [System.Convert]::ToBase64String($plainTextBytes)

}

#endregion Get-SpotifyEncode64

#====================================================================================================================================================
#############################
## Set-SpotifyRequestProxy ##
#############################

#region Set-SpotifyRequestProxy

# Sets the proxy server for the given request using the provided Spotify environment info.
function Set-SpotifyRequestProxy {

    [CmdletBinding()]

    param([Parameter(Mandatory)] [System.Net.HttpWebRequest]$Request,
          [string]$SpotifyEnv = $script:SpotifyDefaultEnv)

    # Check if a proxy server has been given and set it up if so.
    if ($script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyServer) {

        # Create the proxy object.
        $webProxy = New-Object System.Net.WebProxy
        if ($webProxy -eq $null) { throw 'Error creating web proxy object' }

        # Set the proxy server and port. Make sure we are using HTTP as that is all the System.Net.WebRequest class supports.
        # HTTPS proxy addresses should not ever be needed. See below.
        # https://blogs.msdn.microsoft.com/jpsanders/2007/04/25/the-servicepointmanager-does-not-support-proxies-of-https-scheme-net-1-1-sp1/
        $proxyServer = $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyServer
        if ($proxyServer -notmatch '^http') { $proxyServer = "http://$proxyServer" }
        else { $proxyServer = $proxyServer -replace '^https://', 'http://' }
        if ($script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyPort) { $proxyServer += ':' + $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyPort }
        $webProxy.Address = $proxyServer

        # Set the bypass list if available. Make sure each URI starts with a ';'.
        if ($script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyBypassList) {
            $bypassList = $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyBypassList | ForEach-Object { if ($_ -match '^;') { $_ } else { ';' + $_ } }
            try { $webProxy.BypassList = $bypassList }
            catch { throw "Invalid proxy bypass list.`n$($_.Exception.Message)" }
        }

        # Set bypass on local setting if needed.
        if ($script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyBypassOnLocal) {
            $webProxy.BypassProxyOnLocal = $true
        }

        # Set credentials if needed.
        if ($script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyUseDefaultCredentials) {
            $webProxy.UseDefaultCredentials = $true
        } elseif ($script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyUsername) {
            if ($script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyPasswordEncrypted) {
                $secPassword = $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyPasswordEncrypted
            } elseif ($script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyPassword) {
                $secPassword = ConvertTo-SecureString $script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyPassword -AsPlainText -Force
            }
            try {
                $creds = New-Object System.Management.Automation.PSCredential ($script:SpotifyEnvironmentInfo[$SpotifyEnv].ProxyUsername, $secPassword)
                $webProxy.Credentials = $creds
            } catch { throw "Error setting proxy server credentials.`n$($_.Exception.Message)" }
        }

        Write-Debug "Set-SpotifyRequestProxy : Proxy Setup : $($webProxy | Out-String)"

        # Add the proxy to the web request.
        try { $Request.Proxy = $webProxy }
        catch { throw "Error setting proxy server on web request: `n$($_.Exception.Message)" }

    }
}

#endregion Set-SpotifyRequestProxy

#endregion Utility Functions

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
