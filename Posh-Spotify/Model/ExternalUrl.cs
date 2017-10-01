/*

    ExternalUrl Object Model

    https://developer.spotify.com/web-api/object-model/#external-url-object

    NOTE: The above documentation describes this as a list yet the JSON object that is returned is never a list from what I have seen, just another
    object. So in cases where another object has an ExternalUrl field I will treat it as one item instead of as a list. Also note, the documentation
    uses a Key/Value pairing for the data and only mentions 1 possible key as an exampe but doesn't mention whether there are more than 1 possible
    key. For now I am just going to check for the existence of that 1 possible key and set it accordingly. If there are other keys they will be
    ignored.

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;

    public class ExternalUrl {

        public string Type { get; set; }
        public string Url { get; set; }

        public ExternalUrl() {
            this.Type = "";
            this.Url = "";
        }

        public ExternalUrl(PSObject Object) : this() {
            if (Object != null) {
                if (Object.Properties["spotify"] != null) {
                    this.Type = "spotify";
                    this.Url = (string)Object.Properties["spotify"].Value;
                }
            }
        }

        // Methods.

        public override string ToString() {
            return this.Url;
        }

    }
}

