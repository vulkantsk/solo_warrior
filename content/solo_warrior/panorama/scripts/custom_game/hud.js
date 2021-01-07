GameEvents.Subscribe( "speedrun_time", OnTime);
GameEvents.Subscribe( "speedrun_pb", OnPB);
GameEvents.Subscribe( "speedrun_wr", OnWR);

function OnTime(data)
{
	$("#currenttime").text = SecondsToMinsNSecs(data["time"])
}
function OnPB(data)
{
	$("#personalbest").text = $.Localize("#speedrun_personalbest") + SecondsToMinsNSecs(data["time"])
}
function OnWR(data)
{
	$("#worldrecord").text = $.Localize("#speedrun_worldrecord") + SecondsToMinsNSecs(data["time"])
}

function SecondsToMinsNSecs(seconds)
{
	var mins = Math.floor(seconds/60);
	var secs = Math.floor(seconds%60);
	
	if (mins < 10) {mins = "0"+mins}
	if (secs < 10) {secs = "0"+secs}
	
	return mins + ":" + secs;
}