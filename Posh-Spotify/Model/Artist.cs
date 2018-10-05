/*

    Artist Object Model

    https://developer.spotify.com/documentation/web-api/reference/object-model/#artist-object-full
    https://developer.spotify.com/documentation/web-api/reference/object-model/#artist-object-simplified

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;
    using System.Linq;

    public class Artist : Context {

        // Backing fields.

        private int popularity;

        // Properties in simplified object.

        public string Id { get; set; }
        public string Name { get; set; }

        // Properties in full object.

        public FollowerInfo Followers { get; set; }
        public List<string> Genres { get; set; }
        public List<ImageInfo> Images { get; set; }

        public int Popularity {
            get { return this.popularity; }
            set {
                if (value >= 0 && value <= 100) { this.popularity = value; }
                else { throw new System.ArgumentException("Popularity value out of range (Min = 0 : Max = 100)"); }
            }
        }

        // Constructors.

        public Artist() {
            this.ExternalUrl = new ExternalUrl();
            this.FullDetailUri = "";
            this.Followers = new FollowerInfo();
            this.Genres = new List<string>();
            this.Id = "";
            this.Images = new List<ImageInfo>();
            this.Name = "";
            this.Popularity = 0;
            this.type = ItemType.Artist;
            this.Uri = "";
        }

        public Artist(PSObject Object) : this() {
            if (Object != null) {
                this.ExternalUrl = Object.Properties["external_urls"] != null ? new ExternalUrl((PSObject)Object.Properties["external_urls"].Value) : new ExternalUrl();
                this.FullDetailUri = Object.Properties["href"] != null ? (string)Object.Properties["href"].Value : "";
                this.Followers = Object.Properties["followers"] != null ? new FollowerInfo((PSObject)Object.Properties["followers"].Value) : new FollowerInfo();
                this.Genres = Object.Properties["genres"] != null ? ((object[])Object.Properties["genres"].Value).Select(i => i.ToString()).ToList() : new List<string>();
                this.Id = Object.Properties["id"] != null ? (string)Object.Properties["id"].Value : "";
                this.Images = Object.Properties["images"] != null ? ((object[])Object.Properties["images"].Value).Select(i => new ImageInfo((PSObject)i)).ToList() : new List<ImageInfo>();
                this.Name = Object.Properties["name"] != null ? (string)Object.Properties["name"].Value : "";
                this.Popularity = (Object.Properties["popularity"] != null && Object.Properties["popularity"].Value is int) ? (int)Object.Properties["popularity"].Value : 0;
                this.Uri = Object.Properties["uri"] != null ? (string)Object.Properties["uri"].Value : "";
            }
        }

        // Methods.

        public override string ToString() {
            return this.Name;
        }

    }
}

