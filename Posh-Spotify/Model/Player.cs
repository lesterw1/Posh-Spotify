/*

    Player Object Model

    Context - Object representing the context of the player (i.e. Album, Artist, Playlist).
    PlayerContext - Object containing a Context object and the current progress of that Context (i.e. IsPlaying, Progress, Track).
    Device - Object representing a particular device and current device information (i.e. Name, ID, Volume).
    Player - Object containing a PlayerContext and a Device object along with player settings (i.e. ShuffleState, RepeatState).

    https://developer.spotify.com/web-api/get-information-about-the-users-current-playback/

*/

namespace NewGuy.PoshSpotify {

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;

    public enum PlayerRepeatState { Off, Track, Context }
    public enum DeviceType { Computer, Smartphone, Speaker}

    /*===========================*/
    /*== Player Context Object ==*/
    /*===========================*/

    // Player Context object used to hold current Context and Context related progress.

    public class PlayerContext {

        public Context Context { get; set; }
        public bool IsPlaying { get; set; }
        public DateTime PlayerFetchedOn { get; set; }
        public TimeSpan Progress { get; set; }
        public Track Track { get; set; }

        public PlayerContext() {
            this.Context = new Context();
            this.IsPlaying = false;
            this.PlayerFetchedOn = DateTime.Now.ToLocalTime();
            this.Progress = new TimeSpan(0);
            this.Track = null;
        }

        public PlayerContext(PSObject Object) : this() {

            if (Object != null) {

                this.Context = (Object.Properties["context"] != null && Object.Properties["context"].Value != null) ? new Context((PSObject)Object.Properties["context"].Value) : new Context();
                this.IsPlaying = Object.Properties["is_playing"] != null ? (bool)Object.Properties["is_playing"].Value : false;
                this.PlayerFetchedOn = Object.Properties["timestamp"] != null ? (DateTimeOffset.FromUnixTimeMilliseconds((long)Object.Properties["timestamp"].Value)).DateTime.ToLocalTime() : DateTime.Now.ToLocalTime();
                this.Progress = Object.Properties["progress_ms"] != null ? (new TimeSpan(TimeSpan.TicksPerMillisecond * (int)Object.Properties["progress_ms"].Value)) : new TimeSpan(0);
                this.Track = (Object.Properties["item"] != null && Object.Properties["item"].Value != null) ? new Track((PSObject)Object.Properties["item"].Value) : null;

            }

        }

        // Methods.

        public override string ToString() {
            return this.Track.Name.ToString();
        }

    }

    /*===================*/
    /*== Player Object ==*/
    /*===================*/

    // Player object which adds a Device and Device state information to the PlayerContext.

    public class Player : PlayerContext {

        public Device Device { get; set; }
        public PlayerRepeatState RepeatState { get; set; }
        public bool ShuffleState { get; set; }

        public Player() : base() {
            this.Device = null;
            this.RepeatState = PlayerRepeatState.Off;
            this.ShuffleState = false;
        }

        public Player(PSObject Object) : base(Object) {

            if (Object != null) {

                this.Device = Object.Properties["device"] != null ? new Device((PSObject)Object.Properties["device"].Value) : null;

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

            }

        }

        // Methods.

        public override string ToString() {
            return this.Device.Name.ToString();
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

            if (Object != null) {

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
                this.Volume = (Object.Properties["volume_percent"] != null && Object.Properties["volume_percent"].Value != null) ? (int)Object.Properties["volume_percent"].Value : 0;

            }

        }

        // Methods.

        public override string ToString() {
            return this.Name.ToString();
        }

    }

}

