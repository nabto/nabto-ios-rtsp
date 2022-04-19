# Nabto P2P RTSP demo app for iOS

Simple iOS app demonstrating Nabto 4/Micro P2P tunnelling of a remote RTSP/TCP feed and video playback using FFMPG and Nabto.

Note that this app demonstrates the legacy Nabto 4/Micro platform - new demo apps for Nabto 5/Edge will be provided in 2022. [Read more about Nabto 4 vs 5](https://docs.nabto.com/developer/guides/concepts/overview/edge-vs-micro.html). Most importanty, Nabto 4/Micro and Nabto 5/Edge are **100% incompatible**, so you cannot use this app for Nabto 5/Edge.

First, if you have not installed Cocoapods, do so: `sudo gem install cocoapods`

Next, run `pod install` to install the Nabto P2P libraries and a precompiled version of FFMPG.

Open `Nabto.xcworkspace` and run the app.

Note that this simple demo does not (yet) demonstrate authentication and authorization (pairing) - see this blog post for further discussion: https://www.nabto.com/rtsp-p2p-streaming-through-nabto with reference to another example that demonstrates this.

