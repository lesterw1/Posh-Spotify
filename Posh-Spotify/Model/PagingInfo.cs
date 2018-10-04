/*

    PagingInfo Object Model

    https://developer.spotify.com/documentation/web-api/reference/object-model/#paging-object

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Management.Automation;
    using System.Linq;

    public class PagingInfo {

        public string FullDetailUri { get; set; }
        public ArrayList Items { get; set; }
        public int Limit { get; set; }
        public string NextPage { get; set; }
        public int Offset { get; set; }
        public string PreviousPage { get; set; }
        public int Total { get; set; }

        public PagingInfo() {
            this.FullDetailUri = "";
            this.Items = new ArrayList();
            this.Limit = 50;
            this.NextPage = "";
            this.Offset = 0;
            this.PreviousPage = "";
            this.Total = 0;
        }

        public PagingInfo(PSObject Object) : this() {
            if (Object != null) {
                this.FullDetailUri = Object.Properties["href"] != null ? (string)Object.Properties["href"].Value : "";
                List<PSObject> objItems = Object.Properties["items"] != null ? ((object[])Object.Properties["items"].Value).Select(i => (PSObject)i).ToList() : new List<PSObject>();
                this.Limit = (Object.Properties["limit"] != null && Object.Properties["limit"].Value is int) ? (int)Object.Properties["limit"].Value : 0;
                this.NextPage = Object.Properties["next"] != null ? (string)Object.Properties["next"].Value : "";
                this.Offset = (Object.Properties["offset"] != null && Object.Properties["offset"].Value is int) ? (int)Object.Properties["offset"].Value : 0;
                this.PreviousPage = Object.Properties["previous"] != null ? (string)Object.Properties["previous"].Value : "";
                this.Total = (Object.Properties["total"] != null && Object.Properties["total"].Value is int) ? (int)Object.Properties["total"].Value : 0;

                foreach (PSObject obj in objItems) {
                    if (obj.Properties["type"] != null && ((string)obj.Properties["type"].Value) == ItemType.Album.ToString().ToLower())
                        this.Items.Add(new Album(obj));
                    else if (obj.Properties["type"] != null && ((string)obj.Properties["type"].Value) == ItemType.Artist.ToString().ToLower())
                        this.Items.Add(new Artist(obj));
                    else if (obj.Properties["type"] != null && ((string)obj.Properties["type"].Value) == ItemType.Playlist.ToString().ToLower())
                        this.Items.Add(new Playlist(obj));
                    else if (obj.Properties["type"] != null && ((string)obj.Properties["type"].Value) == ItemType.Track.ToString().ToLower())
                        this.Items.Add(new Track(obj));
                    else if (obj.Properties["type"] != null && ((string)obj.Properties["type"].Value) == ItemType.User.ToString().ToLower())
                        this.Items.Add(new User(obj));
                    else if (obj.Properties["added_at"] != null)
                        this.Items.Add(new PlaylistTrack(obj));
                    else
                        this.Items.Add(obj);
                }
            }
        }

        // This constructor is used by the Spotify search endpoint commands which return multiple PagingInfo objects (as a PSObject) for each item
        // type returned from the search (i.e. Artists, Albums, Tracks, etc.). This allows the wrapper functions to simply supply the raw object and
        // choose which type it wants without having to parse the multi-page object.
        public PagingInfo(PSObject Object, ItemType ItemType) : this(PagingInfo.ParseMultiPageObject(Object, ItemType)) { }

        // Methods.

        private static PSObject ParseMultiPageObject(PSObject Object, ItemType ItemType) {
            if (Object != null) {
                if (Object.Properties[(ItemType.ToString().ToLower() + 's')] != null) {
                    return (PSObject)Object.Properties[(ItemType.ToString().ToLower() + 's')].Value;
                }
            }

            return null;
        }

        public override string ToString() {
            return "PagedItems[" + this.Items.Count + "/" + this.Limit + " of " + this.Total + "]";
        }

    }
}

