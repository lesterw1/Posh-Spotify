/*

    FollowerInfo Object Model

    https://developer.spotify.com/documentation/web-api/reference/object-model/#followers-object

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;

    public class FollowerInfo {

        public string FullDetailUri { get; set; }
        public int TotalFollowers { get; set; }

        public FollowerInfo() {
            this.FullDetailUri = "";
            this.TotalFollowers = 0;
        }

        public FollowerInfo(PSObject Object) : this() {
            if (Object != null) {
                this.FullDetailUri = Object.Properties["href"] != null ? (string)Object.Properties["href"].Value : "";
                this.TotalFollowers = (Object.Properties["total"] != null && Object.Properties["total"].Value is int) ? (int)Object.Properties["total"].Value : 0;
            }
        }

        // Methods.

        public override string ToString() {
            return this.TotalFollowers.ToString();
        }

    }
}

