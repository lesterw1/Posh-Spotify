/*

    User Object Model

    https://developer.spotify.com/web-api/object-model/#user-object-private
    https://developer.spotify.com/web-api/object-model/#user-object-public

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;
    using System.Linq;

    public class User {

        // Backing fields.

        private ItemType type;

        // Properties in simplified (public) object.

        public string DisplayName { get; set; }
        public ExternalUrl ExternalUrl { get; set; }
        public FollowerInfo Followers { get; set; }
        public string FullDetailUri { get; set; }
        public string Id { get; set; }
        public List<ImageInfo> Images { get; set; }
        public ItemType Type { get { return this.type; } }
        public string Uri { get; set; }

        // Properties in full (private) object.

        public DateTime Birthdate { get; set; }
        public string Country { get; set; }
        public string Email { get; set; }
        public string ProductSubscription { get; set; }

        // Constructors.

        public User() {
            this.Birthdate = new DateTime(1,1,1);
            this.Country = "";
            this.DisplayName = "";
            this.ExternalUrl = new ExternalUrl();
            this.Followers = new FollowerInfo();
            this.FullDetailUri = "";
            this.Id = "";
            this.Images = new List<ImageInfo>();
            this.type = ItemType.User;
            this.Uri = "";
        }

        public User(PSObject Object) : this() {
            if (Object != null) {

                if (Object.Properties["birthdate"] != null) {
                    List<int> ls = ((string)Object.Properties["birthdate"].Value).Split('-').Select(i => Int32.Parse(i)).ToList();
                    if (ls.Count == 3) { this.Birthdate = new DateTime(ls[0], ls[1], ls[2]); }
                    else if (ls.Count == 2) { this.Birthdate = new DateTime(ls[0], ls[1], 1); }
                    else if (ls.Count == 1) { this.Birthdate = new DateTime(ls[0], 1, 1); }
                }

                this.Country = Object.Properties["country"] != null ? (string)Object.Properties["country"].Value : "";
                this.DisplayName = Object.Properties["display_name"] != null ? (string)Object.Properties["display_name"].Value : "";
                this.Email = Object.Properties["email"] != null ? (string)Object.Properties["email"].Value : "";
                this.ExternalUrl = Object.Properties["external_urls"] != null ? new ExternalUrl((PSObject)Object.Properties["external_urls"].Value) : new ExternalUrl();
                this.Followers = Object.Properties["followers"] != null ? new FollowerInfo((PSObject)Object.Properties["followers"].Value) : new FollowerInfo();
                this.FullDetailUri = Object.Properties["href"] != null ? (string)Object.Properties["href"].Value : "";
                this.Id = Object.Properties["id"] != null ? (string)Object.Properties["id"].Value : "";
                this.Images = Object.Properties["images"] != null ? ((object[])Object.Properties["images"].Value).Select(i => new ImageInfo((PSObject)i)).ToList() : new List<ImageInfo>();
                this.ProductSubscription = Object.Properties["product"] != null ? (string)Object.Properties["product"].Value : "";
                this.Uri = Object.Properties["uri"] != null ? (string)Object.Properties["uri"].Value : "";

            }
        }

        // Methods.

        public override string ToString() {
            return this.Id;
        }

    }
}

