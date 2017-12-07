<#

    This file when dot-sourced by the module at initialization time will build the object models from the C# files in the same folder. It will also
    add a few extra properties and methods to the .NET types defined here.

#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#########################
## Import Object Model ##
#########################

#region Import Object Model

# Since you can't unload a type from the console you must catch errors about adding the type when it already exists in the console.
Try {
    Add-Type -ErrorAction Stop -Path @(
        "$PSScriptRoot\Artist.cs",
        "$PSScriptRoot\Album.cs",
        "$PSScriptRoot\AuthenticationToken.cs",
        "$PSScriptRoot\Context.cs",
        "$PSScriptRoot\Copyright.cs",
        "$PSScriptRoot\ExternalId.cs",
        "$PSScriptRoot\ExternalUrl.cs",
        "$PSScriptRoot\FollowerInfo.cs",
        "$PSScriptRoot\ImageInfo.cs",
        "$PSScriptRoot\PagingInfo.cs",
        "$PSScriptRoot\Player.cs",
        "$PSScriptRoot\Playlist.cs",
        "$PSScriptRoot\Track.cs",
        "$PSScriptRoot\User.cs"
    )
} Catch {
    If ($_.Exception.Message -match "Cannot add type. The type name '.*?' already exists.") { }  # Do nothing.
    Else { Throw }  # Rethrow the error.
}

#endregion Import Object Model

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
