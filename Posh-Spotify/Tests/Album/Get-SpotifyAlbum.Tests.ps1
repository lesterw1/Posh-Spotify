<#

    Get-SpotifyAlbum.Tests.ps1

#>

# If the parameter below is not provided a default location will be used. See the module documentation for details.
Param([string]$EnvironmentInfoFilePath)

# Initialize Spotify API session and environment info.
. "$PSScriptRoot\..\Test-SpotifySessionLauncher.ps1" -EnvironmentInfoFilePath $EnvironmentInfoFilePath

# Run tests inside the module scope so that internal private commands can be tested and mocked.
InModuleScope Posh-Spotify {

    Describe 'public function: Get-SpotifyAlbum - Retrieves an album' {

        #========================================================================================================

        ####################################
        ### Test Case : Get-SpotifyAlbum ###
        ####################################

        It 'Get Spotify album.' {

            $albums = Get-SpotifyAlbum -Id '3d74p8E8jFhgKogypxpZAd', '6hs55qjerNNOi4ZT5bOhxV'

            $albums.Count | Should Be 2
            $albums[0] | Should BeOfType NewGuy.PoshSpotify.Album
            $albums[1] | Should BeOfType NewGuy.PoshSpotify.Album

            # Believer by Imagine Dragons

            # AlbumType            : single
            # Artists              : {Imagine Dragons}
            # AvailableMarkets     : {}
            # ExternalUrl          : https://open.spotify.com/album/3d74p8E8jFhgKogypxpZAd
            # FullDetailUri        : https://api.spotify.com/v1/albums/3d74p8E8jFhgKogypxpZAd
            # Id                   : 3d74p8E8jFhgKogypxpZAd
            # Images               : {https://i.scdn.co/image/065e207d9c469de85ab24e2afbb922bcf6afc2e7, https://i.scdn.co/image/6ee470deb5da2581083a55b8726123d938ae8a54,
            #                        https://i.scdn.co/image/19a516ac153972be1e1a51068b12459b1b83d5a8}
            # Name                 : Believer
            # Type                 : Album
            # Uri                  : spotify:album:3d74p8E8jFhgKogypxpZAd
            # Copyrights           : {© 2017 KIDinaKORNER/Interscope Records, ℗ 2017 KIDinaKORNER/Interscope Records}
            # ExternalId           : 00602557443325
            # Genres               : {}
            # Label                : KIDinaKORNER/Interscope Records
            # Popularity           : 49
            # ReleaseDate          : 1/31/2017 12:00:00 AM
            # ReleaseDatePrecision : day
            # TrackPagingInfo      : PagedItems[1/50 of 1]
            # TrackCount           : 1
            # Tracks               : {Believer}

            $albums[0].AlbumType | Should Be 'single'
            $albums[0].Artists[0] | Should BeOfType NewGuy.PoshSpotify.Artist
            $albums[0].Artists[0].Name | Should Be 'Imagine Dragons'
            $albums[0].AvailableMarkets.Count | Should Be 0
            $albums[0].ExternalUrl | Should BeOfType NewGuy.PoshSpotify.ExternalUrl
            $albums[0].ExternalUrl.Url | Should Be 'https://open.spotify.com/album/3d74p8E8jFhgKogypxpZAd'
            $albums[0].FullDetailUri | Should Be 'https://api.spotify.com/v1/albums/3d74p8E8jFhgKogypxpZAd'
            $albums[0].Id | Should Be '3d74p8E8jFhgKogypxpZAd'
            $albums[0].Images.Count | Should Be 3
            $albums[0].Images[0] | Should BeOfType NewGuy.PoshSpotify.ImageInfo
            $albums[0].Images[0].Url | Should Be 'https://i.scdn.co/image/065e207d9c469de85ab24e2afbb922bcf6afc2e7'
            $albums[0].Name | Should Be 'Believer'
            $albums[0].Type | Should BeOfType NewGuy.PoshSpotify.ItemType
            $albums[0].Type | Should Be 'Album'
            $albums[0].Uri | Should Be 'spotify:album:3d74p8E8jFhgKogypxpZAd'
            $albums[0].Copyrights.Count | Should Be 2
            $albums[0].Copyrights[0] | Should BeOfType NewGuy.PoshSpotify.Copyright
            $albums[0].Copyrights[0] | Should Match '2017 KIDinaKORNER/Interscope Records'
            $albums[0].ExternalId | Should BeOfType NewGuy.PoshSpotify.ExternalId
            $albums[0].ExternalId.Id | Should Be '00602557443325'
            $albums[0].Genres.Count | Should Be 0
            $albums[0].Label | Should Be 'KIDinaKORNER/Interscope Records'
            $albums[0].Popularity | Should BeGreaterThan 0
            ($albums[0].ReleaseDate - (Get-Date '1/31/2017 12:00:00 AM')).Ticks | Should Be 0
            $albums[0].ReleaseDatePrecision | Should Be 'day'
            $albums[0].TrackPagingInfo | Should BeOfType NewGuy.PoshSpotify.PagingInfo
            $albums[0].TrackPagingInfo.ToString() | Should Be 'PagedItems[1/50 of 1]'
            $albums[0].TrackCount | Should Be 1
            $albums[0].Tracks.Count | Should Be 1
            $albums[0].Tracks[0] | Should BeOfType NewGuy.PoshSpotify.Track
            $albums[0].Tracks[0].Name | Should Be 'Believer'

            # Lungs by Florence + The Machine

            # AlbumType            : album
            # Artists              : {Florence + The Machine}
            # AvailableMarkets     : {AD, AR, AT, AU...}
            # ExternalUrl          : https://open.spotify.com/album/6hs55qjerNNOi4ZT5bOhxV
            # FullDetailUri        : https://api.spotify.com/v1/albums/6hs55qjerNNOi4ZT5bOhxV
            # Id                   : 6hs55qjerNNOi4ZT5bOhxV
            # Images               : {https://i.scdn.co/image/14ac8eaf3503928373c9902104d0b8815afaeb11, https://i.scdn.co/image/0b6cb02cc71eea5d754f3a97298063baf48dfdd0,
            #                        https://i.scdn.co/image/33402ae29b42a0a39013bc90abd78aa0b5808e3e}
            # Name                 : Lungs
            # Type                 : Album
            # Uri                  : spotify:album:6hs55qjerNNOi4ZT5bOhxV
            # Copyrights           : {© 2009 Universal Island Records Ltd. A Universal Music Company., ℗ 2009 Universal Island Records Ltd. A Universal Music Company.}
            # ExternalId           : 00602527116761
            # Genres               : {}
            # Label                : Island Records
            # Popularity           : 54
            # ReleaseDate          : 1/1/2009 12:00:00 AM
            # ReleaseDatePrecision : day
            # TrackPagingInfo      : PagedItems[13/50 of 13]
            # TrackCount           : 13
            # Tracks               : {Dog Days Are Over, Rabbit Heart (Raise It Up), I'm Not Calling You A Liar, Howl...}

            $albums[1].AlbumType | Should Be 'album'
            $albums[1].Artists[0] | Should BeOfType NewGuy.PoshSpotify.Artist
            $albums[1].Artists[0].Name | Should Be 'Florence + The Machine'
            $albums[1].AvailableMarkets.Count | Should Be 62
            $albums[1].AvailableMarkets[0] | Should Be 'AD'
            $albums[1].ExternalUrl | Should BeOfType NewGuy.PoshSpotify.ExternalUrl
            $albums[1].ExternalUrl.Url | Should Be 'https://open.spotify.com/album/6hs55qjerNNOi4ZT5bOhxV'
            $albums[1].FullDetailUri | Should Be 'https://api.spotify.com/v1/albums/6hs55qjerNNOi4ZT5bOhxV'
            $albums[1].Id | Should Be '6hs55qjerNNOi4ZT5bOhxV'
            $albums[1].Images.Count | Should Be 3
            $albums[1].Images[0] | Should BeOfType NewGuy.PoshSpotify.ImageInfo
            $albums[1].Images[0].Url | Should Be 'https://i.scdn.co/image/14ac8eaf3503928373c9902104d0b8815afaeb11'
            $albums[1].Name | Should Be 'Lungs'
            $albums[1].Type | Should BeOfType NewGuy.PoshSpotify.ItemType
            $albums[1].Type | Should Be 'Album'
            $albums[1].Uri | Should Be 'spotify:album:6hs55qjerNNOi4ZT5bOhxV'
            $albums[1].Copyrights.Count | Should Be 2
            $albums[1].Copyrights[0] | Should Match 'Universal Island Records Ltd\. A Universal Music Company\.'
            $albums[1].ExternalId | Should BeOfType NewGuy.PoshSpotify.ExternalId
            $albums[1].ExternalId.Id | Should Be '00602527116761'
            $albums[1].Genres.Count | Should Be 0
            $albums[1].Label | Should Be 'Island Records'
            $albums[1].Popularity | Should BeGreaterThan 0
            ($albums[1].ReleaseDate - (Get-Date '1/1/2009 12:00:00 AM')).Ticks | Should Be 0
            $albums[1].ReleaseDatePrecision | Should Be 'day'
            $albums[1].TrackPagingInfo | Should BeOfType NewGuy.PoshSpotify.PagingInfo
            $albums[1].TrackPagingInfo.ToString() | Should Be 'PagedItems[13/50 of 13]'
            $albums[1].TrackCount | Should Be 13
            $albums[1].Tracks.Count | Should Be 13
            $albums[1].Tracks[0] | Should BeOfType NewGuy.PoshSpotify.Track
            $albums[1].Tracks[0].Name | Should Be 'Dog Days Are Over'

        }

    }

}
