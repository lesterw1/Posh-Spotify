/*

    Copyright Object Model

    https://developer.spotify.com/web-api/object-model/#copyright-object

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;

    public class Copyright {

        public string Text { get; set; }
        public string Type { get; set; }
        
        public Copyright() {
            this.Text = "";
            this.Type = "";
        }

        public Copyright(PSObject Object) : this() {
            if (Object != null) {
                this.Text = Object.Properties["text"] != null ? (string)Object.Properties["text"].Value : "";
                this.Type = Object.Properties["type"] != null ? (string)Object.Properties["type"].Value : "";
            }
        }

        // Methods.

        public override string ToString() {
            return this.Text;
        }

    }
}

