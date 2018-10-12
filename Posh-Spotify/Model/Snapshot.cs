/*

    Snapshot Object Model

    Snapshots are returned by commands that modify playlists. It represents the current state of the playlist after the modification has occurred.
    It can be used by certain playlist commands during future requests to ensure changes are being made to a known state. These changes will be merged
    with any other changes made by other clients or users.

*/

namespace NewGuy.PoshSpotify {

    using System.Management.Automation;

    public class Snapshot {

        public string Id { get; set; }

        public Snapshot() {
            this.Id = "";
        }

        public Snapshot(PSObject Object) : this() {
            if (Object != null) {
                this.Id = Object.Properties["snapshot_id"] != null ? (string)Object.Properties["snapshot_id"].Value : "";
            }
        }

        // Methods.

        public override string ToString() {
            return this.Id;
        }

    }
}

