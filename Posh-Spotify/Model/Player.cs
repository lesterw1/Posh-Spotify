/*

    Player Object Model

    https://developer.spotify.com/web-api/get-information-about-the-users-current-playback/

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;

    public enum PlayerRepeatState { Off, Track, Context }
    public enum DeviceType { Computer, Smartphone, Speaker}

    /*===================*/
    /*== Player Object ==*/
    /*===================*/

    // Player object

    public class Player {

        public Context Context { get; set; }
        public Device Device { get; set; }
        public bool IsPlaying { get; set; }
        public DateTime PlayerFetchedOn { get; set; }
        public TimeSpan Progress { get; set; }
        public PlayerRepeatState RepeatState { get; set; }
        public bool ShuffleState { get; set; }
        public Track Track { get; set; }

        public Player() {
            this.Context = new Context();
            this.Device = null;
            this.IsPlaying = false;
            this.PlayerFetchedOn = DateTime.Now.ToLocalTime();
            this.Progress = new TimeSpan(0);
            this.RepeatState = PlayerRepeatState.Off;
            this.ShuffleState = false;
            this.Track = null;
        }

        public Player(PSObject Object) : this() {

            if (Object != null) {

                this.Context = (Object.Properties["context"] != null && Object.Properties["context"].Value != null) ? new Context((PSObject)Object.Properties["context"].Value) : new Context();
                this.Device = Object.Properties["device"] != null ? new Device((PSObject)Object.Properties["device"].Value) : null;
                this.IsPlaying = Object.Properties["is_playing"] != null ? (bool)Object.Properties["is_playing"].Value : false;
                this.PlayerFetchedOn = Object.Properties["timestamp"] != null ? (DateTimeOffset.FromUnixTimeMilliseconds((long)Object.Properties["timestamp"].Value)).DateTime.ToLocalTime() : DateTime.Now.ToLocalTime();
                this.Progress = Object.Properties["progress_ms"] != null ? (new TimeSpan(TimeSpan.TicksPerMillisecond * (int)Object.Properties["progress_ms"].Value)) : new TimeSpan(0);

                if (Object.Properties["repeat_state"] != null) {
                    if ((string)Object.Properties["repeat_state"].Value == "off") {
                        this.RepeatState = PlayerRepeatState.Off;
                    } else if ((string)Object.Properties["repeat_state"].Value == "track") {
                        this.RepeatState = PlayerRepeatState.Track;
                    } else if ((string)Object.Properties["repeat_state"].Value == "context") {
                        this.RepeatState = PlayerRepeatState.Context;
                    }
                }

                this.ShuffleState = Object.Properties["shuffle_state"] != null ? (bool)Object.Properties["shuffle_state"].Value : false;
                this.Track = (Object.Properties["item"] != null && Object.Properties["item"].Value != null) ? new Track((PSObject)Object.Properties["item"].Value) : null;

            }

        }

        // Methods.

        public override string ToString() {
            return this.Device.Name.ToString();
        }

    }

    /*====================*/
    /*== Context Object ==*/
    /*====================*/

    // Context object used by the player to describe what is playing (i.e. Album, Artist, Playlist)

    public class Context {

        // Backing fields.

        private ItemType type;

        // Properties in full object.

        public ExternalUrl ExternalUrl { get; set; }
        public string FullDetailUri { get; set; }
        public ItemType ItemType { get { return this.type; } }
        public string Uri { get; set; }

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
                this.type = Object.Properties["type"] != null ? (ItemType)Object.Properties["type"].Value : ItemType.Album;
                this.Uri = Object.Properties["uri"] != null ? (string)Object.Properties["uri"].Value : "";
            }
        }

        // Methods.

        public override string ToString() {
            return this.ItemType.ToString();
        }

    }

    /*===================*/
    /*== Device Object ==*/
    /*===================*/

    // Device object used by the player to describe which device is playing

    public class Device {

        // Properties in full object.

        public DeviceType DeviceType { get; set; }
        public string Id { get; set; }
        public bool IsActive { get; set; }
        public bool IsRestricted { get; set; }
        public string Name { get; set; }
        public int Volume { get; set; }

        public Device() {
            this.DeviceType = NewGuy.PoshSpotify.DeviceType.Computer;
            this.Id = null;
            this.IsActive = false;
            this.IsRestricted = false;
            this.Name = "";
            this.Volume = 0;
        }

        public Device(PSObject Object) : this() {

            if (Object.Properties["type"] != null) {
                if ((string)Object.Properties["type"].Value == "Computer") {
                    this.DeviceType = NewGuy.PoshSpotify.DeviceType.Computer;
                } else if ((string)Object.Properties["type"].Value == "Smartphone") {
                    this.DeviceType = NewGuy.PoshSpotify.DeviceType.Smartphone;
                } else if ((string)Object.Properties["type"].Value == "Speaker") {
                    this.DeviceType = NewGuy.PoshSpotify.DeviceType.Speaker;
                }
            }

            this.Id = Object.Properties["id"] != null ? (string)Object.Properties["id"].Value : null;
            this.IsActive = Object.Properties["is_active"] != null ? (bool)Object.Properties["is_active"].Value : false;
            this.IsRestricted = Object.Properties["is_restricted"] != null ? (bool)Object.Properties["is_restricted"].Value : false;
            this.Name = Object.Properties["name"] != null ? (string)Object.Properties["name"].Value : "";
            this.Volume = Object.Properties["volume_percent"] != null ? (int)Object.Properties["volume_percent"].Value : 0;

        }

        // Methods.

        public override string ToString() {
            return this.Name.ToString();
        }

    }

}

