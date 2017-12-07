/*

    Album Object Model

    https://developer.spotify.com/web-api/object-model/#album-object-full
    https://developer.spotify.com/web-api/object-model/#album-object-simplified

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;
    using System.Linq;

    public class Album : Context {

        // Backing fields.

        private int popularity;

        // Properties in simplified object.

        public string AlbumType { get; set; }
        public List<Artist> Artists { get; set; }
        public List<string> AvailableMarkets { get; set; }
        public string Id { get; set; }
        public List<ImageInfo> Images { get; set; }
        public string Name { get; set; }

        // Properties in full object.

        public List<Copyright> Copyrights { get; set; }
        public ExternalId ExternalId { get; set; }
        public List<string> Genres { get; set; }
        public string Label { get; set; }

        public int Popularity {
            get { return this.popularity; }
            set {
                if (value >= 0 && value <= 100) { this.popularity = value; }
                else { throw new System.ArgumentException("Popularity value out of range (Min = 0 : Max = 100)"); }
            }
        }

        public DateTime ReleaseDate { get; set; }
        public string ReleaseDatePrecision { get; set; }

        // Custom properities.

        public PagingInfo TrackPagingInfo { get; set; }
        public int TrackCount { get { return this.TrackPagingInfo.Total; } }
        public List<Track> Tracks { get; set; }

        // Constructors.

        public Album() {
            this.AlbumType = "";
            this.Artists = new List<Artist>();
            this.AvailableMarkets = new List<string>();
            this.Copyrights = new List<Copyright>();
            this.ExternalId = new ExternalId();
            this.ExternalUrl = new ExternalUrl();
            this.FullDetailUri = "";
            this.Genres = new List<string>();
            this.Id = "";
            this.Images = new List<ImageInfo>();
            this.Label = "";
            this.Name = "";
            this.Popularity = 0;
            this.ReleaseDate = new DateTime(1,1,1);
            this.ReleaseDatePrecision = "year";
            this.TrackPagingInfo = new PagingInfo();
            this.Tracks = new List<Track>();
            this.type = ItemType.Album;
            this.Uri = "";
        }

        public Album(PSObject Object) : this() {
            if (Object != null) {
                this.AlbumType = Object.Properties["album_type"] != null ? (string)Object.Properties["album_type"].Value : "";
                this.Artists = Object.Properties["artists"] != null ? ((object[])Object.Properties["artists"].Value).Select(i => new Artist((PSObject)i)).ToList() : new List<Artist>();
                this.AvailableMarkets = Object.Properties["available_markets"] != null ? ((object[])Object.Properties["available_markets"].Value).Select(i => i.ToString()).ToList() : new List<string>();
                this.Copyrights = Object.Properties["copyrights"] != null ? ((object[])Object.Properties["copyrights"].Value).Select(i => new Copyright((PSObject)i)).ToList() : new List<Copyright>();
                this.ExternalId = Object.Properties["external_ids"] != null ? new ExternalId((PSObject)Object.Properties["external_ids"].Value) : new ExternalId();
                this.ExternalUrl = Object.Properties["external_urls"] != null ? new ExternalUrl((PSObject)Object.Properties["external_urls"].Value) : new ExternalUrl();
                this.FullDetailUri = Object.Properties["href"] != null ? (string)Object.Properties["href"].Value : "";
                this.Genres = Object.Properties["genres"] != null ? ((object[])Object.Properties["genres"].Value).Select(i => i.ToString()).ToList() : new List<string>();
                this.Id = Object.Properties["id"] != null ? (string)Object.Properties["id"].Value : "";
                this.Images = Object.Properties["images"] != null ? ((object[])Object.Properties["images"].Value).Select(i => new ImageInfo((PSObject)i)).ToList() : new List<ImageInfo>();
                this.Label = Object.Properties["label"] != null ? (string)Object.Properties["label"].Value : "";
                this.Name = Object.Properties["name"] != null ? (string)Object.Properties["name"].Value : "";
                this.Popularity = (Object.Properties["popularity"] != null && Object.Properties["popularity"].Value is int) ? (int)Object.Properties["popularity"].Value : 0;

                if (Object.Properties["release_date"] != null) {
                    List<int> ls = ((string)Object.Properties["release_date"].Value).Split('-').Select(i => Int32.Parse(i)).ToList();
                    if (ls.Count == 3) { this.ReleaseDate = new DateTime(ls[0], ls[1], ls[2]); }
                    else if (ls.Count == 2) { this.ReleaseDate = new DateTime(ls[0], ls[1], 1); }
                    else if (ls.Count == 1) { this.ReleaseDate = new DateTime(ls[0], 1, 1); }
                }

                this.ReleaseDatePrecision = Object.Properties["release_date_precision"] != null ? (string)Object.Properties["release_date_precision"].Value : "year";
                this.TrackPagingInfo = Object.Properties["tracks"] != null ? new PagingInfo((PSObject)Object.Properties["tracks"].Value) : new PagingInfo();
                this.Tracks = this.TrackPagingInfo.Items.Cast<Track>().ToList();
                this.Uri = Object.Properties["uri"] != null ? (string)Object.Properties["uri"].Value : "";
            }
        }

        // Methods.

        public override string ToString() {
            return this.Name;
        }

    }
}

