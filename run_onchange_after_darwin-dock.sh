#!/bin/sh

dockutil --no-restart --remove all
dockutil --no-restart --add "/Applications/Arc.app"
dockutil --no-restart --add "/Applications/Webstorm.app"
dockutil --no-restart --add "/Applications/iTerm.app"
dockutil --no-restart --add "/Applications/Spark.app"
dockutil --no-restart --add "/Applications/Spotify.app"
dockutil --no-restart --add "/System/Applications/Notes.app"

killall Dock
