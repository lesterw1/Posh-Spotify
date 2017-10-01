/*

    ImageInfo Object Model

    https://developer.spotify.com/web-api/object-model/#image-object

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;

    public class ImageInfo {

        public int Height { get; set; }
        public string Url { get; set; }
        public int Width { get; set; }

        public ImageInfo() {
            this.Height = 0;
            this.Url = "";
            this.Width = 0;
        }

        public ImageInfo(PSObject Object) : this() {
            if (Object != null) {
                this.Height = Object.Properties["height"] != null && Object.Properties["height"].Value is int ? (int)Object.Properties["height"].Value : 0;
                this.Url = Object.Properties["url"] != null ? (string)Object.Properties["url"].Value : "";
                this.Width = Object.Properties["width"] != null && Object.Properties["width"].Value is int ? (int)Object.Properties["width"].Value : 0;
            }
        }

        // Methods.

        public override string ToString() {
            return this.Url;
        }

    }
}

