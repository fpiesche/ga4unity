# Google Analytics for Unity3D, 2012 Florian Piesche / florian@yellowkeycard.net / @ektoutie

CAVEAT: This will only work on its own for native builds. For Web Player builds, you will need
  to add Google Analytics' ga.js to the page the game is embedded in.

USAGE: drop in your assets folder. Attach to any GameObject as a Component.
   Call SetID method with your GA Tracking ID (UA-12345678-9) and the domain DeviceName
   you're using in GA. From then on, just call either of the two methods to log info/events
   to Google Analytics.


METHODS:

  LogInfo(Prefix as string)
      - logs system info (OS, Device Name, Device Type) as events with category Prefix.
  LogEvent(EventCat as string, Event as string, EventLabel as string, EventValue as single)
      - logs an event to Google Analytics with the custom text/value as above.


EXAMPLE:

  self.gaScript.SetID("UA-12345678-9", "mydomain.com")
  self.gaScript.LogInfo("myGame")
  self.gaScript.LogEvent("myGame", "startGame", "", 0.0)
  
