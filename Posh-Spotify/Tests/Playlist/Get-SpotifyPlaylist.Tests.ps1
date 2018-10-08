<#

    Get-SpotifyPlaylist.Tests.ps1

    The tests use live calls to the Spotify API. The items they retrieve may change as things change on the Spotify service. I tried to find test
    objects that would not likely change or be removed from Spotify. As I notice changes to these objects that break the tests I will either comment
    them out or find another object.

#>

# If the parameter below is not provided a default location will be used. See the module documentation for details.
param([string]$EnvironmentInfoFilePath)

# Initialize Spotify API session and environment info.
. "$PSScriptRoot\..\Test-SpotifySessionLauncher.ps1" -EnvironmentInfoFilePath $EnvironmentInfoFilePath

# Run tests inside the module scope so that internal private commands can be tested and mocked.
InModuleScope Posh-Spotify {

    Describe 'public function: Get-SpotifyPlaylist - Retrieves an playlist' {

        #========================================================================================================

        #######################################
        ### Test Case : Get-SpotifyPlaylist ###
        #######################################

        It 'Get current Spotify user''s playlist.' {

            $playlists = Get-SpotifyPlaylist

            $playlists.Count | Should -BeGreaterOrEqual 1
            $playlists[0] | Should -BeOfType NewGuy.PoshSpotify.Playlist

            # Find a testing playlist. This will need to exist before running this test.
            $selectedPlaylist = $playlists | Where-Object { $_.Name -match 'Posh-Spotify Playlist Test' }

            # Posh-Spotify Playlist Test by my2eggs

            # Collaborative   : False
            # Id              : 6ePQdv3gJKhHS0HHOcjegE
            # Images          : {https://mosaic.scdn.co/640/1a9d8dd58014c1ed46f4fd22613376cf9a65cea6765dd18a89c2dbbb8d548dfb6387001eb362d25c90f62be60c6b902cb7c556c600677e26189d8844e5e617df404d6982f114f5a5d0e3b991a
            #                   f7e1fac, https://mosaic.scdn.co/300/1a9d8dd58014c1ed46f4fd22613376cf9a65cea6765dd18a89c2dbbb8d548dfb6387001eb362d25c90f62be60c6b902cb7c556c600677e26189d8844e5e617df404d6982f114f5a5d
            #                   0e3b991af7e1fac, https://mosaic.scdn.co/60/1a9d8dd58014c1ed46f4fd22613376cf9a65cea6765dd18a89c2dbbb8d548dfb6387001eb362d25c90f62be60c6b902cb7c556c600677e26189d8844e5e617df404d6982f1
            #                   14f5a5d0e3b991af7e1fac}
            # Name            : Posh-Spotify Playlist Test
            # Owner           : my2eggs
            # Public          : False
            # SnapshotId      : MTAsOTljMDE1NDkzNjAwNTY3YmNmN2FkNzA4N2FkMGQ0ZjBlMDg2YWQxYw==
            # Description     : 
            # Followers       : 0
            # TrackPagingInfo : PagedItems[8/100 of 8]
            # TrackCount      : 8
            # Tracks          : {Que Sera, Crystalised, Tessellate, Between Two Points (feat. Swan)...}
            # ExternalUrl     : https://open.spotify.com/playlist/6ePQdv3gJKhHS0HHOcjegE
            # FullDetailUri   : https://api.spotify.com/v1/playlists/6ePQdv3gJKhHS0HHOcjegE
            # Type            : Playlist
            # Uri             : spotify:user:my2eggs:playlist:6ePQdv3gJKhHS0HHOcjegE

            $selectedPlaylist.Collaborative | Should -BeFalse
            $selectedPlaylist.Id | Should -Be '6ePQdv3gJKhHS0HHOcjegE'
            $selectedPlaylist.Images.Count | Should -Be 3
            $selectedPlaylist.Images[0] | Should -BeOfType NewGuy.PoshSpotify.ImageInfo
            $selectedPlaylist.Images[0].Url | Should -Match '(^https://i.scdn.co/image/)|(^https://mosaic.scdn.co)'
            $selectedPlaylist.Name | Should -Be 'Posh-Spotify Playlist Test'
            $selectedPlaylist.Owner | Should -Be 'my2eggs'
            $selectedPlaylist.Public | Should -BeFalse
            $selectedPlaylist.SnapshotId.Length | Should -BeGreaterThan 0
            $selectedPlaylist.Description | Should -BeNullOrEmpty  # This is only available on Full Playlist object.
            $selectedPlaylist.Followers | Should -BeGreaterOrEqual 0
            $selectedPlaylist.TrackPagingInfo | Should -BeOfType NewGuy.PoshSpotify.PagingInfo
            $selectedPlaylist.TrackPagingInfo.FullDetailUri.Length | Should -BeGreaterThan 0
            $selectedPlaylist.TrackPagingInfo.Total | Should -Be $selectedPlaylist.TrackCount
            $selectedPlaylist.TrackCount | Should -Be 8
            $selectedPlaylist.Tracks.Capacity | Should -Be $selectedPlaylist.TrackCount
            $selectedPlaylist.Tracks[0] | Should -BeOfType NewGuy.PoshSpotify.PlaylistTrack
            $selectedPlaylist.Tracks[0].Track | Should -BeOfType NewGuy.PoshSpotify.Track
            $selectedPlaylist.Tracks[0].Track.Name | Should -Be 'Que Sera'
            $selectedPlaylist.ExternalUrl | Should -BeOfType NewGuy.PoshSpotify.ExternalUrl
            $selectedPlaylist.ExternalUrl.Url | Should -Be 'https://open.spotify.com/playlist/6ePQdv3gJKhHS0HHOcjegE'
            $selectedPlaylist.FullDetailUri | Should -Be 'https://api.spotify.com/v1/playlists/6ePQdv3gJKhHS0HHOcjegE'
            $selectedPlaylist.Type | Should -BeOfType NewGuy.PoshSpotify.ItemType
            $selectedPlaylist.Type | Should -Be 'Playlist'
            $selectedPlaylist.Uri | Should -Be 'spotify:user:my2eggs:playlist:6ePQdv3gJKhHS0HHOcjegE'

        }

    }

}
