# Nabto P2P RTSP demo app for iOS

Simple iOS app demonstrating P2P tunnelling of a remote RTSP/TCP feed and video playback using FFMPG and Nabto.

First, if you have not installed Cocoapods, do so: `sudo gem install cocoapods`

Next, run `pod install` to install the Nabto P2P libraries and a precompiled version of FFMPG.

Open `Nabto.xcworkspace` and run the app.

Note that this simple demo does not (yet) demonstrate authentication and authorization (pairing) - see this blog post for further discussion: https://www.nabto.com/rtsp-p2p-streaming-through-nabto with reference to another example that demonstrates this.

