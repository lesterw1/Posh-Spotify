/*

    AuthenticationToken Model

    https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;
    using System.Linq;

    public class AuthenticationToken {

        // Properties.

        public string AccessToken { get; set; }
        public string TokenType { get; set; }
        public DateTime ExpiresOn { get; set; }
        public string RefreshToken { get; set; }
        public bool HasExpired { get { return DateTime.Now > ExpiresOn; } }
        public List<string> Scopes { get; set; }

        // Constructors.

        public AuthenticationToken () {
            this.AccessToken = "";
            this.TokenType = "";
            this.ExpiresOn = DateTime.Now;
            this.RefreshToken = "";
            this.Scopes = new List<string>();
        }

        public AuthenticationToken (string AccessToken, string TokenType, int TokenLifetime) : this() {
            this.AccessToken = AccessToken;
            this.TokenType = TokenType;
            this.ExpiresOn = DateTime.Now.AddSeconds(TokenLifetime);
        }

        public AuthenticationToken (PSObject Object) : this() {
            if (Object != null) {
                this.AccessToken = Object.Properties["access_token"] != null ? (string)Object.Properties["access_token"].Value : "";
                this.TokenType = Object.Properties["token_type"] != null ? (string)Object.Properties["token_type"].Value : "";
                this.ExpiresOn = Object.Properties["expires_in"] != null ? DateTime.Now.AddSeconds((int)Object.Properties["expires_in"].Value) : DateTime.Now;
                this.RefreshToken = Object.Properties["refresh_token"] != null ? (string)Object.Properties["refresh_token"].Value : "";
                this.Scopes = Object.Properties["scope"] != null ? ((string)Object.Properties["scope"].Value).Split(' ').Select(i => i).ToList() : new List<string>();
            }
        }

        // Methods.

        public override string ToString() {
            return this.AccessToken;
        }

    }
}
