/*

    Track Object Model

    https://developer.spotify.com/web-api/object-model/#track-object-full
    https://developer.spotify.com/web-api/object-model/#track-object-simplified

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;
    using System.Linq;

    /*==================*/
    /*== Track Object ==*/
    /*==================*/

    // Track object

    public class Track {

        // Backing fields.

        private ItemType type;
        private int popularity;

        // Properties in simplified object.

        public List<Artist> Artists { get; set; }
        public List<string> AvailableMarkets { get; set; }
        public int DiscNumber { get; set; }
        public TimeSpan Duration { get; set; }
        public bool HasExplicitLyrics { get; set; }
        public ExternalUrl ExternalUrl { get; set; }
        public string FullDetailUri { get; set; }
        public string Id { get; set; }
        public bool IsPlayable { get; set ; }
        public TrackLink LinkedFrom { get; set; }
        public string Name { get; set; }
        public string PreviewUrl { get; set; }
        public int TrackNumber { get; set; }
        public ItemType Type { get { return this.type; } }
        public string Uri { get; set; }

        // Properties in full object.

        public Album Album { get; set; }
        public ExternalId ExternalId { get; set; }

        public int Popularity {
            get { return this.popularity; }
            set {
                if (value >= 0 && value <= 100) { this.popularity = value; }
                else { throw new System.ArgumentException("Popularity value out of range (Min = 0 : Max = 100)"); }
            }
        }

        // Constructors.

        public Track() {
            this.Album = new Album();
            this.Artists = new List<Artist>();
            this.AvailableMarkets = new List<string>();
            this.DiscNumber = 0;
            this.Duration = new TimeSpan(0);
            this.HasExplicitLyrics = false;
            this.ExternalId = new ExternalId();
            this.ExternalUrl = new ExternalUrl();
            this.FullDetailUri = "";
            this.Id = "";
            this.IsPlayable = true;
            this.LinkedFrom = new TrackLink();
            this.Name = "";
            this.PreviewUrl = "";
            this.Popularity = 0;
            this.TrackNumber = 0;
            this.type = ItemType.Track;
            this.Uri = "";
        }

        public Track(PSObject Object) : this() {
            if (Object != null) {
                this.Album = Object.Properties["album"] != null ? new Album((PSObject)Object.Properties["album"].Value) : new Album();
                this.Artists = Object.Properties["artists"] != null ? ((object[])Object.Properties["artists"].Value).Select(i => new Artist((PSObject)i)).ToList() : new List<Artist>();
                this.AvailableMarkets = Object.Properties["available_markets"] != null ? ((object[])Object.Properties["available_markets"].Value).Select(i => i.ToString()).ToList() : new List<string>();
                this.DiscNumber = (Object.Properties["disc_number"] != null && Object.Properties["disc_number"].Value is int) ? (int)Object.Properties["disc_number"].Value : 0;
                this.Duration = Object.Properties["duration_ms"] != null ? new TimeSpan(TimeSpan.TicksPerMillisecond * (int)Object.Properties["duration_ms"].Value) : new TimeSpan(0);
                this.HasExplicitLyrics = Object.Properties["explicit"] != null ? (bool)Object.Properties["explicit"].Value : false;
                this.ExternalId = Object.Properties["external_ids"] != null ? new ExternalId((PSObject)Object.Properties["external_ids"].Value) : new ExternalId();
                this.ExternalUrl = Object.Properties["external_urls"] != null ? new ExternalUrl((PSObject)Object.Properties["external_urls"].Value) : new ExternalUrl();
                this.FullDetailUri = Object.Properties["href"] != null ? (string)Object.Properties["href"].Value : "";
                this.Id = Object.Properties["id"] != null ? (string)Object.Properties["id"].Value : "";
                this.IsPlayable = Object.Properties["is_playable"] != null ? (bool)Object.Properties["is_playable"].Value : true;
                this.LinkedFrom = Object.Properties["linked_from"] != null ? new TrackLink((PSObject)Object.Properties["linked_from"].Value) : new TrackLink();
                this.Name = Object.Properties["name"] != null ? (string)Object.Properties["name"].Value : "";
                this.PreviewUrl = Object.Properties["preview_url"] != null ? (string)Object.Properties["preview_url"].Value : "";
                this.Popularity = (Object.Properties["popularity"] != null && Object.Properties["popularity"].Value is int) ? (int)Object.Properties["popularity"].Value : 0;
                this.TrackNumber = (Object.Properties["track_number"] != null && Object.Properties["track_number"].Value is int) ? (int)Object.Properties["track_number"].Value : 0;
                this.Uri = Object.Properties["uri"] != null ? (string)Object.Properties["uri"].Value : "";
            }
        }

        // Methods.

        public override string ToString() {
            return this.Name;
        }

    }

    /*======================*/
    /*== TrackLink Object ==*/
    /*======================*/

    // TrackLink object used by the track to locate the original track in case of Track Relinking : https://developer.spotify.com/web-api/track-relinking-guide/

    public class TrackLink {

        private string type;

        public ExternalUrl ExternalUrl { get; set; }
        public string FullDetailUri { get; set; }
        public string Id { get; set; }
        public string LinkType { get { return this.type; } }
        public string Uri { get; set; }

        public TrackLink() {
            this.ExternalUrl = new ExternalUrl();
            this.FullDetailUri = "";
            this.Id = "";
            this.Uri = "";
            this.type = "track";
        }

        public TrackLink(PSObject Object) : this() {
            if (Object != null) {
                this.ExternalUrl = Object.Properties["external_urls"] != null ? new ExternalUrl((PSObject)Object.Properties["external_urls"].Value) : new ExternalUrl();
                this.FullDetailUri = Object.Properties["href"] != null ? (string)Object.Properties["href"].Value : "";
                this.Id = Object.Properties["id"] != null ? (string)Object.Properties["id"].Value : "";
                this.Uri = Object.Properties["uri"] != null ? (string)Object.Properties["uri"].Value : "";
            }
        }

        // Methods.

        public override string ToString() {
            return this.Uri;
        }

    }
}
