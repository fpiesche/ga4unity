# Google Analytics for Unity3D, 2012 florian@yellowkeycard.net

# CAVEAT: This will only work on its own for native builds. For Web Player builds, you will need
#   to add Google Analytics' ga.js to the page the game is embedded in.

# USAGE: drop in your assets folder. Attach to any GameObject as a Component.
#   Call SetID method with your GA Tracking ID (UA-12345678-9) and the domain DeviceName
#   you're using in GA. From then on, just call either of the two methods to log info/events
#   to Google Analytics.

# METHODS:
# LogInfo(Prefix as string)
#      - logs system info (OS, Device Name, Device Type) as events with category Prefix.
# LogEvent(EventCat as string, Event as string, EventLabel as string, EventValue as single)
#      - logs an event to Google Analytics with the custom text/value as above.

import UnityEngine

class GoogleAnalytics (MonoBehaviour):

	public DebugInfo as bool = false
	public GAImageURL as string = "http://www.google-analytics.com/__utm.gif?"
	public Initialised as bool = false
	public RequestParameters as Hashtable = {}

	def SetID (TrackingID as string, Domain as string):

		# calculate domain hash
		DomainHash = 0
		tmpVar = 0
		DomainLength = Domain.Length - 1
		while DomainLength >= 0:
			character = System.Convert.ToInt32(Domain[DomainLength])
			DomainHash = (DomainHash << 6 & 268435455) + character + (character << 14)
			tmpVar = DomainHash & 266338304
			if tmpVar != 0:
				DomainHash = DomainHash ^ tmpVar >> 21
			DomainLength -= 1
		self.RequestParameters["DomainHash"] = DomainHash.ToString()
		self.RequestParameters["AnalyticsVersion"] = "utmwv=5.2.5"
		self.RequestParameters["TrackingID"] = "utmac=" + TrackingID
		self.RequestParameters["Domain"] = "utmhn=" + Domain
		self.RequestParameters["RequestNum"] = "utms=1"
		self.RequestParameters["ReferrerURL"] = "utmr=-"
		self.RequestParameters["PageURL"] = "utmp=%2F"
		self.RequestParameters["DocumentTitle"] = "utmdt=GA4UnityRequest"
		self.RequestParameters["ScreenResolution"] = "utmsr=" + Screen.currentResolution.width + "x" + Screen.currentResolution.height
		self.RequestParameters["ColourDepth"] = "utmsc=32-bit"
		self.RequestParameters["CharacterSet"] = "utmcs=-"
		self.RequestParameters["Language"] = "utmul="
		self.RequestParameters["FlashVersion"] = "utmfl=-"
		self.RequestParameters["JavaEnabled"] = "utmje=-"
		self.RequestParameters["RequestType"] = "utmt=event"
		self.RequestParameters["utmhid"] = "utmhid=" + Mathf.RoundToInt(Random.value * 2147483647).ToString()

		if Application.internetReachability == NetworkReachability.NotReachable:
			Debug.Log("Internet not available, skipping init.")
			return false

		if self.DebugInfo == true:
			Debug.Log("Firing initial pageview...")

		PageviewParams = ["AnalyticsVersion", "TrackingID", "Domain", "RequestNum", "RandomNum", "PageURL", "DocumentTitle", "CharacterSet", "ReferrerURL", "Language", "FlashVersion", "JavaEnabled", "ScreenResolution", "utmhid"]
		if Application.platform != RuntimePlatform.WindowsWebPlayer and Application.platform != RuntimePlatform.OSXWebPlayer:
			RequestURL = GAImageURL + self.GetCookieData(true)
			for param in PageviewParams:
				RequestURL += "&" + self.RequestParameters[param]
			StartCoroutine(makeRequest(RequestURL))
		else:
			Application.ExternalCall("pageTracker._trackPageview")

		self.Initialised = true
		return true


	def GetCookieData (ShortCookie as bool):
		self.RequestParameters["RandomNum"] = "utmn=" + Mathf.RoundToInt(Random.value * 2147483647).ToString()
		currentTime = ((System.DateTime.Now.Ticks - 621355968000000000) / 10000000).ToString()
		if ShortCookie == true:
			return "utmcc=" + WWW.EscapeURL("__utma=" + self.RequestParameters["DomainHash"] + "." + Mathf.RoundToInt(Random.value * 2147483647).ToString() + "." + currentTime + "." + currentTime + "." + currentTime + ".1;")
		else:
			return "utmcc=" + WWW.EscapeURL("__utma=" + self.RequestParameters["DomainHash"] + "." + Mathf.RoundToInt(Random.value * 2147483647).ToString() + "." + currentTime + "." + currentTime + "." + currentTime + ".1;+__utmb=" + self.RequestParameters["DomainHash"] + ";+__utmc=" + self.RequestParameters["DomainHash"] + ";+__utmz=" + self.RequestParameters["DomainHash"] + "." + currentTime + ".2utmcsr=google|utmccn=(organic)|utmctr=none|utmcmd=organic;")


	def LogInfo (Prefix as string):
		if self.DebugInfo == true:
			Debug.Log("Logging system info...")
		self.LogEvent(WWW.EscapeURL(Prefix) + "SysInfo", "OperatingSystem", WWW.EscapeURL(SystemInfo.operatingSystem), 0.0)
		self.LogEvent(WWW.EscapeURL(Prefix) + "SysInfo", "DeviceName", WWW.EscapeURL(SystemInfo.deviceModel), 0.0)
		self.LogEvent(WWW.EscapeURL(Prefix) + "SysInfo", "DeviceType", WWW.EscapeURL(SystemInfo.deviceType.ToString()), 0.0)


	def LogEvent (EventCat as string, Event as string, EventLabel as string, EventValue as single):
		if Application.platform != RuntimePlatform.WindowsWebPlayer and Application.platform != RuntimePlatform.OSXWebPlayer:
			if self.Initialised == false:
				Debug.LogError("ERROR: Google Analytics library not initialised. Call SetID() first!")
				return
			else:
				if self.DebugInfo == true:
					Debug.Log("Logging event...")
				EventData = "utme=" + WWW.EscapeURL("5(" + EventCat + "*" + Event + "*" + EventLabel + ")(" + EventValue.ToString() + ")")
				RequestURL = self.GAImageURL + self.GetCookieData(true) + "&" + EventData
				EventParameters = ["AnalyticsVersion", "TrackingID", "Domain", "RequestType", "RequestNum", "RandomNum", "CookieData", "CharacterSet", "ReferrerURL", "Language", "FlashVersion", "JavaEnabled", "ScreenResolution", "utmhid"]
				for param in EventParameters:
						RequestURL += "&" + self.RequestParameters[param]
				StartCoroutine(makeRequest(RequestURL))
		else:
			Application.ExternalCall("pageTracker._trackEvent", EventCat, Event, EventLabel, EventValue.ToString())


	def makeRequest (RequestURL as string) as IEnumerator:
		if self.DebugInfo == true:
			Debug.Log("Google Analytics request: " + RequestURL)
		if Application.internetReachability == NetworkReachability.NotReachable:
			if self.DebugInfo == true:
				Debug.Log("No internet connectivity; ignoring request")
			return
		else:
			pageviewRequest = WWW(RequestURL)
			yield pageviewRequest