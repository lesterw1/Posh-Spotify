/*

    Playlist Object Model

    https://developer.spotify.com/web-api/object-model/#playlist-object-full
    https://developer.spotify.com/web-api/object-model/#playlist-object-simplified

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;
    using System.Linq;

    /*=====================*/
    /*== Playlist Object ==*/
    /*=====================*/

    // Playlist object

    public class Playlist : Context {

        // Properties in simplified object.

        public bool Collaborative { get; set; }
        public string Id { get; set; }
        public List<ImageInfo> Images { get; set; }
        public string Name { get; set; }
        public User Owner { get; set; }
        public bool? Public { get; set; }  // Value of null means not relevant.
        public string SnapshotId { get; set; }

        // Properties in full object.

        public string Description { get; set; }
        public FollowerInfo Followers { get; set; }

        // Custom properities.

        public PagingInfo TrackPagingInfo { get; set; }
        public int TrackCount { get { return this.TrackPagingInfo.Total; } }
        public List<PlaylistTrack> Tracks { get; set; }

        // Constructors.

        public Playlist() {
            this.Collaborative = false;
            this.Description = "";
            this.ExternalUrl = new ExternalUrl();
            this.Followers = new FollowerInfo();
            this.FullDetailUri = "";
            this.Id = "";
            this.Images = new List<ImageInfo>();
            this.Name = "";
            this.Owner = new User();
            this.Public = null;
            this.SnapshotId = "";
            this.TrackPagingInfo = new PagingInfo();
            this.Tracks = new List<PlaylistTrack>();
            this.type = ItemType.Playlist;
            this.Uri = "";
        }

        public Playlist(PSObject Object) : this() {
            if (Object != null) {
                this.Collaborative = Object.Properties["collaborative"] != null ? (bool)Object.Properties["collaborative"].Value : false;
                this.Description = Object.Properties["description"] != null ? (string)Object.Properties["description"].Value : "";
                this.ExternalUrl = Object.Properties["external_urls"] != null ? new ExternalUrl((PSObject)Object.Properties["external_urls"].Value) : new ExternalUrl();
                this.Followers = Object.Properties["followers"] != null ? new FollowerInfo((PSObject)Object.Properties["followers"].Value) : new FollowerInfo();
                this.FullDetailUri = Object.Properties["href"] != null ? (string)Object.Properties["href"].Value : "";
                this.Id = Object.Properties["id"] != null ? (string)Object.Properties["id"].Value : "";
                this.Images = Object.Properties["images"] != null ? ((object[])Object.Properties["images"].Value).Select(i => new ImageInfo((PSObject)i)).ToList() : new List<ImageInfo>();
                this.Name = Object.Properties["name"] != null ? (string)Object.Properties["name"].Value : "";
                this.Owner = Object.Properties["owner"] != null ? new User((PSObject)Object.Properties["owner"].Value) : new User();
                this.Public = Object.Properties["public"] != null ? (bool?)Object.Properties["public"].Value : null as bool?;
                this.SnapshotId = Object.Properties["snapshot_id"] != null ? (string)Object.Properties["snapshot_id"].Value : "";
                this.TrackPagingInfo = Object.Properties["tracks"] != null ? new PagingInfo((PSObject)Object.Properties["tracks"].Value) : new PagingInfo();
                this.Tracks = this.TrackPagingInfo.Items.Cast<PlaylistTrack>().ToList();
                this.Uri = Object.Properties["uri"] != null ? (string)Object.Properties["uri"].Value : "";
            }
        }

        // Methods.

        public override string ToString() {
            return this.Name;
        }

    }

    /*===========================*/
    /*== Playlist Track Object ==*/
    /*===========================*/

    // Playlist track object used by the playlist to describe tracks associated with it

    public class PlaylistTrack {

        public User AddedBy { get; set; }
        public DateTime DateAdded { get; set; }
        public bool IsLocal { get; set; }
        public Track Track { get; set; }

        public PlaylistTrack() {
            this.AddedBy = new User();
            this.DateAdded = new DateTime(1,1,1);
            this.IsLocal = false;
            this.Track = new Track();
        }

        public PlaylistTrack(PSObject Object) : this() {
            if (Object != null) {
                this.AddedBy = (Object.Properties["added_by"] != null && Object.Properties["added_by"].Value != null) ? new User((PSObject)Object.Properties["added_by"].Value) : new User();
                this.DateAdded = (Object.Properties["added_at"] != null && Object.Properties["added_at"].Value != null) ? DateTime.Parse((string)Object.Properties["added_at"].Value) : new DateTime(1,1,1);
                this.IsLocal = Object.Properties["is_local"] != null ? (bool)Object.Properties["is_local"].Value : false;
                this.Track = Object.Properties["track"] != null ? new Track((PSObject)Object.Properties["track"].Value) : new Track();
            }
        }

        // Methods.

        public override string ToString() {
            return this.Track.Name;
        }

    }
}

