<#

    Get-SpotifyTrack.Tests.ps1

#>

# If the parameters below are not provided default locations will be used. See the module documentation for details.
Param([string]$AuthenticationTokenFilePath, [string]$EnvironmentInfoFilePath)

# Initialize Spotify API session and environment info.
. "$PSScriptRoot\..\Test-SpotifySessionLauncher.ps1" -AuthenticationTokenFilePath $AuthenticationTokenFilePath -EnvironmentInfoFilePath $EnvironmentInfoFilePath

# Run tests inside the module scope so that internal private commands can be tested and mocked.
InModuleScope Posh-Spotify {

    Describe 'public function: Get-SpotifyTrack - Retrieves an track' {

        #========================================================================================================

        ####################################
        ### Test Case : Get-SpotifyTrack ###
        ####################################

        It 'Get Spotify track.' {

            $tracks = Get-SpotifyTrack -Ids '05KfyCEE6otdlT1pp2VIjP', '6eN9yBWv9zFVZFXGsPrMxj'

            $tracks.Count | Should Be 2
            $tracks[0] | Should BeOfType NewGuy.PoshSpotify.Track
            $tracks[1] | Should BeOfType NewGuy.PoshSpotify.Track

            # Believer by Imagine Dragons

            # Artists           : {Imagine Dragons}
            # AvailableMarkets  : {}
            # DiscNumber        : 1
            # Duration          : 00:03:23.7820000
            # HasExplicitLyrics : False
            # ExternalUrl       : https://open.spotify.com/track/05KfyCEE6otdlT1pp2VIjP
            # FullDetailUri     : https://api.spotify.com/v1/tracks/05KfyCEE6otdlT1pp2VIjP
            # Id                : 05KfyCEE6otdlT1pp2VIjP
            # IsPlayable        : True
            # LinkedFrom        :
            # Name              : Believer
            # PreviewUrl        :
            # TrackNumber       : 1
            # Type              : Track
            # Uri               : spotify:track:05KfyCEE6otdlT1pp2VIjP
            # Album             : Believer
            # ExternalId        : USUM71700626
            # Popularity        : 56

            $tracks[0].Artists[0] | Should BeOfType NewGuy.PoshSpotify.Artist
            $tracks[0].Artists[0].Name | Should Be 'Imagine Dragons'
            $tracks[0].AvailableMarkets.Count | Should Be 0
            $tracks[0].DiscNumber | Should Be 1
            ($tracks[0].Duration - [TimeSpan]'00:03:23.7820000').Ticks | Should Be 0
            $tracks[0].HasExplicitLyrics | Should Be $false
            $tracks[0].ExternalUrl | Should BeOfType NewGuy.PoshSpotify.ExternalUrl
            $tracks[0].ExternalUrl.Url | Should Be 'https://open.spotify.com/track/05KfyCEE6otdlT1pp2VIjP'
            $tracks[0].FullDetailUri | Should Be 'https://api.spotify.com/v1/tracks/05KfyCEE6otdlT1pp2VIjP'
            $tracks[0].Id | Should Be '05KfyCEE6otdlT1pp2VIjP'
            $tracks[0].IsPlayable | Should Be $true
            $tracks[0].LinkedFrom | Should BeOfType NewGuy.PoshSpotify.TrackLink
            $tracks[0].Name | Should Be 'Believer'
            $tracks[0].PreviewUrl | Should Be $null
            $tracks[0].TrackNumber | Should Be 1
            $tracks[0].Type | Should BeOfType NewGuy.PoshSpotify.ItemType
            $tracks[0].Type | Should Be 'Track'
            $tracks[0].Uri | Should Be 'spotify:track:05KfyCEE6otdlT1pp2VIjP'
            $tracks[0].Album | Should BeOfType NewGuy.PoshSpotify.Album
            $tracks[0].Album.Name | Should Be 'Believer'
            $tracks[0].ExternalId | Should BeOfType NewGuy.PoshSpotify.ExternalId
            $tracks[0].ExternalId.Id | Should Be 'USUM71700626'
            $tracks[0].Popularity | Should BeGreaterThan 0

            # Dog Days Are Over by Florence + The Machine

            # Artists           : {Florence + The Machine}
            # AvailableMarkets  : {AD, AR, AT, AU...}
            # DiscNumber        : 1
            # Duration          : 00:04:12.8530000
            # HasExplicitLyrics : False
            # ExternalUrl       : https://open.spotify.com/track/6eN9yBWv9zFVZFXGsPrMxj
            # FullDetailUri     : https://api.spotify.com/v1/tracks/6eN9yBWv9zFVZFXGsPrMxj
            # Id                : 6eN9yBWv9zFVZFXGsPrMxj
            # IsPlayable        : True
            # LinkedFrom        :
            # Name              : Dog Days Are Over
            # PreviewUrl        : https://p.scdn.co/mp3-preview/0a5711b61a302056c23c7489870cd78f777cc850?cid=d9dc4310ac2347b994e19fb789f9ad4d
            # TrackNumber       : 1
            # Type              : Track
            # Uri               : spotify:track:6eN9yBWv9zFVZFXGsPrMxj
            # Album             : Lungs
            # ExternalId        : GBUM70900209
            # Popularity        : 50

            $tracks[1].Artists[0] | Should BeOfType NewGuy.PoshSpotify.Artist
            $tracks[1].Artists[0].Name | Should Be 'Florence + The Machine'
            $tracks[1].AvailableMarkets.Count | Should Be 62
            $tracks[1].AvailableMarkets[0] | Should Be 'AD'
            $tracks[1].DiscNumber | Should Be 1
            ($tracks[1].Duration - [TimeSpan]'00:04:12.8530000').Ticks | Should Be 0
            $tracks[1].HasExplicitLyrics | Should Be $false
            $tracks[1].ExternalUrl | Should BeOfType NewGuy.PoshSpotify.ExternalUrl
            $tracks[1].ExternalUrl.Url | Should Be 'https://open.spotify.com/track/6eN9yBWv9zFVZFXGsPrMxj'
            $tracks[1].FullDetailUri | Should Be 'https://api.spotify.com/v1/tracks/6eN9yBWv9zFVZFXGsPrMxj'
            $tracks[1].Id | Should Be '6eN9yBWv9zFVZFXGsPrMxj'
            $tracks[1].IsPlayable | Should Be $true
            $tracks[1].LinkedFrom | Should BeOfType NewGuy.PoshSpotify.TrackLink
            $tracks[1].Name | Should Be 'Dog Days Are Over'
            $tracks[1].PreviewUrl | Should Be 'https://p.scdn.co/mp3-preview/0a5711b61a302056c23c7489870cd78f777cc850?cid=d9dc4310ac2347b994e19fb789f9ad4d'
            $tracks[1].TrackNumber | Should Be 1
            $tracks[1].Type | Should BeOfType NewGuy.PoshSpotify.ItemType
            $tracks[1].Type | Should Be 'Track'
            $tracks[1].Uri | Should Be 'spotify:track:6eN9yBWv9zFVZFXGsPrMxj'
            $tracks[1].Album | Should BeOfType NewGuy.PoshSpotify.Album
            $tracks[1].Album.Name | Should Be 'Lungs'
            $tracks[1].ExternalId | Should BeOfType NewGuy.PoshSpotify.ExternalId
            $tracks[1].ExternalId.Id | Should Be 'GBUM70900209'
            $tracks[1].Popularity | Should BeGreaterThan 0

        }

    }

}
