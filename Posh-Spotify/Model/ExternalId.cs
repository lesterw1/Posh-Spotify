/*

    ExternalId Object Model

    https://developer.spotify.com/web-api/object-model/#external-id-object

    NOTE: The above documentation describes this as a list yet the JSON object that is returned is never a list from what I have seen, just another
    object. So in cases where another object has an ExternalId field I will treat it as one item instead of as a list. Also note, the documentation
    uses a Key/Value pairing for the data and only mentions 3 possible keys as an exampe but doesn't mention whether there are more than 3 possible
    keys. For now I am just going to check for the existence of those 3 possible keys and set it accordingly. If there are other keys they will be
    ignored.

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;

    public class ExternalId {

        public string Type { get; set; }
        public string Id { get; set; }

        public ExternalId() {
            this.Type = "";
            this.Id = "";
        }

        public ExternalId(PSObject Object) : this() {
            if (Object != null) {
                if (Object.Properties["isrc"] != null) {
                    this.Type = "isrc";
                    this.Id = (string)Object.Properties["isrc"].Value;
                } else if (Object.Properties["ean"] != null) {
                    this.Type = "ean";
                    this.Id = (string)Object.Properties["ean"].Value;
                } else if (Object.Properties["upc"] != null) {
                    this.Type = "upc";
                    this.Id = (string)Object.Properties["upc"].Value;
                }
            }
        }

        // Methods.

        public override string ToString() {
            return this.Id;
        }

    }
}

