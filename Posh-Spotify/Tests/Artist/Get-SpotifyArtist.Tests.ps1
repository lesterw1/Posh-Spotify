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
            # Genres        : {modern rock, pop, vegas indie}
            # Images        : {https://i.scdn.co/image/de3c2c4f4e822edab6fd8c2103102413502635ea, https://i.scdn.co/image/0242e9f3cdaeb9abd0c9724248213c8e364fc921,
            #                 https://i.scdn.co/image/affb5c546adf0b6f718282528e56f24854026be1}
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
            $artists[0].Genres[0] | Should -Be 'modern rock'
            $artists[0].Genres[1] | Should -Be 'pop'
            $artists[0].Genres[2] | Should -Be 'vegas indie'
            $artists[0].Images.Count | Should -Be 3
            $artists[0].Images[0] | Should -BeOfType NewGuy.PoshSpotify.ImageInfo
            $artists[0].Images[0].Url | Should -Be 'https://i.scdn.co/image/de3c2c4f4e822edab6fd8c2103102413502635ea'
            $artists[0].Popularity | Should -BeGreaterThan 0

            # Florence + The Machine

            # ExternalUrl   : https://open.spotify.com/artist/1moxjboGR7GNWYIMWsRjgG
            # FullDetailUri : https://api.spotify.com/v1/artists/1moxjboGR7GNWYIMWsRjgG
            # Id            : 1moxjboGR7GNWYIMWsRjgG
            # Name          : Florence + The Machine
            # Type          : Artist
            # Uri           : spotify:artist:1moxjboGR7GNWYIMWsRjgG
            # Followers     : 3164533
            # Genres        : {folk-pop, modern rock, pop}
            # Images        : {https://i.scdn.co/image/fe6148760b68df4c258a5131bd1b7b6f83286540, https://i.scdn.co/image/eaa4ac2fb065699bde532a88473c2dd21285c60c,
            #                 https://i.scdn.co/image/0c38f1000f44e7da4e3c324804dbf3f8e2d5a5ec, https://i.scdn.co/image/7fca47fff1ab14bb3f0b009d7544d7ab137ab728}
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
            $artists[1].Genres.Count | Should -Be 3
            $artists[1].Genres[0] | Should -Be 'folk-pop'
            $artists[1].Genres[1] | Should -Be 'modern rock'
            $artists[1].Genres[2] | Should -Be 'pop'
            $artists[1].Images.Count | Should -Be 4
            $artists[1].Images[0] | Should -BeOfType NewGuy.PoshSpotify.ImageInfo
            $artists[1].Images[0].Url | Should -Be 'https://i.scdn.co/image/fe6148760b68df4c258a5131bd1b7b6f83286540'
            $artists[1].Popularity | Should -BeGreaterThan 0

        }

    }

}
