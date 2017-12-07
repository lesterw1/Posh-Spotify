/*

    Context Object Model

    Context object used as a base class for most objects. Objects such as Artist, Album, Track, etc. all contain four main properties:

        ExtnernalUrl
        FullDetailUri
        Type
        Uri

    https://developer.spotify.com/web-api/object-model/#context-object

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;

    /*===================*/
    /*== ItemType Enum ==*/
    /*===================*/

    public enum ItemType {
        Album,
        Artist,
        Playlist,
        Track,
        User
    }

    /*====================*/
    /*== Context Object ==*/
    /*====================*/

    // Context object used as a base class for most objects.

    public class Context {

        // Backing fields.

        protected ItemType type;

        // Properties.

        public ExternalUrl ExternalUrl { get; set; }
        public string FullDetailUri { get; set; }
        public ItemType Type { get { return this.type; } }
        public string Uri { get; set; }

        // Constructors.

        public Context() {
            this.ExternalUrl = new ExternalUrl();
            this.FullDetailUri = "";
            this.type = ItemType.Album;
            this.Uri = "";
        }

        public Context(PSObject Object) : this() {
            if (Object != null) {
                this.ExternalUrl = Object.Properties["external_urls"] != null ? new ExternalUrl((PSObject)Object.Properties["external_urls"].Value) : new ExternalUrl();
                this.FullDetailUri = Object.Properties["href"] != null ? (string)Object.Properties["href"].Value : "";
                this.type = Object.Properties["type"] != null ? (ItemType)Enum.Parse(typeof(ItemType), ((string)Object.Properties["type"].Value), true) : ItemType.Album;
                this.Uri = Object.Properties["uri"] != null ? (string)Object.Properties["uri"].Value : "";
            }
        }

        // Methods.

        public override string ToString() {
            return this.Type.ToString();
        }

    }

}

