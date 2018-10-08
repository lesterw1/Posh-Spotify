<#

    Get-SpotifyArtist.Tests.ps1

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

    Describe 'public function: Get-SpotifyArtist - Retrieves an artist' {

        #========================================================================================================

        #####################################
        ### Test Case : Get-SpotifyArtist ###
        #####################################

        It 'Get Spotify artist.' {

            $artists = Get-SpotifyArtist -Id '53XhwfbYqKCa1cC15pYq2q', '1moxjboGR7GNWYIMWsRjgG'

            $artists.Count | Should -Be 2
            $artists[0] | Should -BeOfType NewGuy.PoshSpotify.Artist
            $artists[1] | Should -BeOfType NewGuy.PoshSpotify.Artist

            # Imagine Dragons

            # ExternalUrl   : https://open.spotify.com/artist/53XhwfbYqKCa1cC15pYq2q
            # FullDetailUri : https://api.spotify.com/v1/artists/53XhwfbYqKCa1cC15pYq2q
            # Id            : 53XhwfbYqKCa1cC15pYq2q
            # Name          : Imagine Dragons
            # Type          : Artist
            # Uri           : spotify:artist:53XhwfbYqKCa1cC15pYq2q
            # Followers     : 5522353
            # Genres        : {modern rock, rock, vegas indie}
            # Images        : {https://i.scdn.co/image/63eaf58fd171dc297376c7f362c2cdbc0eda70d2, https://i.scdn.co/image/c9d31051d1e820f8874a783bb703eb902fade140,
            #                 https://i.scdn.co/image/4cb175e3be6d254414c055821da31124f4fe356a}
            # Popularity    : 94

            $artists[0].ExternalUrl | Should -BeOfType NewGuy.PoshSpotify.ExternalUrl
            $artists[0].ExternalUrl.Url | Should -Be 'https://open.spotify.com/artist/53XhwfbYqKCa1cC15pYq2q'
            $artists[0].FullDetailUri | Should -Be 'https://api.spotify.com/v1/artists/53XhwfbYqKCa1cC15pYq2q'
            $artists[0].Id | Should -Be '53XhwfbYqKCa1cC15pYq2q'
            $artists[0].Name | Should -Be 'Imagine Dragons'
            $artists[0].Type | Should -BeOfType NewGuy.PoshSpotify.ItemType
            $artists[0].Type | Should -Be 'Artist'
            $artists[0].Uri | Should -Be 'spotify:artist:53XhwfbYqKCa1cC15pYq2q'
            $artists[0].Followers | Should -BeOfType NewGuy.PoshSpotify.FollowerInfo
            $artists[0].Followers.TotalFollowers | Should -BeGreaterThan 0
            $artists[0].Genres.Count | Should -Be 3
            @('modern rock', 'rock', 'vegas indie') | Should -BeIn $artists[0].Genres
            $artists[0].Images.Count | Should -Be 3
            $artists[0].Images[0] | Should -BeOfType NewGuy.PoshSpotify.ImageInfo
            $artists[0].Images[0].Url | Should -BeLike 'https://i.scdn.co/image/*'
            $artists[0].Popularity | Should -BeGreaterThan 0

            # Florence + The Machine

            # ExternalUrl   : https://open.spotify.com/artist/1moxjboGR7GNWYIMWsRjgG
            # FullDetailUri : https://api.spotify.com/v1/artists/1moxjboGR7GNWYIMWsRjgG
            # Id            : 1moxjboGR7GNWYIMWsRjgG
            # Name          : Florence + The Machine
            # Type          : Artist
            # Uri           : spotify:artist:1moxjboGR7GNWYIMWsRjgG
            # Followers     : 3164533
            # Genres        : {folk-pop, pop}
            # Images        : {https://i.scdn.co/image/fca10d0cc2eb43803df106f9d58448c31ec4f04e, https://i.scdn.co/image/220b6d876dc81f6084204b6a885cd3a3614ccbe0,
            #                 https://i.scdn.co/image/b9e12d1aa93b01b17ce710819df65994ff8c382c}
            # Popularity    : 79

            $artists[1].ExternalUrl | Should -BeOfType NewGuy.PoshSpotify.ExternalUrl
            $artists[1].ExternalUrl.Url | Should -Be 'https://open.spotify.com/artist/1moxjboGR7GNWYIMWsRjgG'
            $artists[1].FullDetailUri | Should -Be 'https://api.spotify.com/v1/artists/1moxjboGR7GNWYIMWsRjgG'
            $artists[1].Id | Should -Be '1moxjboGR7GNWYIMWsRjgG'
            $artists[1].Name | Should -Be 'Florence + The Machine'
            $artists[1].Type | Should -BeOfType NewGuy.PoshSpotify.ItemType
            $artists[1].Type | Should -Be 'Artist'
            $artists[1].Uri | Should -Be 'spotify:artist:1moxjboGR7GNWYIMWsRjgG'
            $artists[1].Followers | Should -BeOfType NewGuy.PoshSpotify.FollowerInfo
            $artists[1].Followers.TotalFollowers | Should -BeGreaterThan 0
            $artists[1].Genres.Count | Should -Be 2
            @('folk-pop', 'pop') | Should -Be $artists[1].Genres
            $artists[1].Images.Count | Should -Be 3
            $artists[1].Images[0] | Should -BeOfType NewGuy.PoshSpotify.ImageInfo
            $artists[1].Images[0].Url | Should -BeLike 'https://i.scdn.co/image/*'
            $artists[1].Popularity | Should -BeGreaterThan 0

        }

    }

}
