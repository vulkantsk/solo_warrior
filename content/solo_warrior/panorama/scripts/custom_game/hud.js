sTime = "00:00";

(function () {
	uhax(hax())
	
	GameEvents.Subscribe( "speedrun_time", OnTime);
	GameEvents.Subscribe( "speedrun_pb", OnPB);
	GameEvents.Subscribe( "speedrun_wr", OnWR);
})();

function OnTime(data)
{
	//$("#currenttime").text = SecondsToMinsNSecs(data["time"])
    sTime = SecondsToMinsNSecs(data["time"])
}
function OnPB(data)
{
	$("#personalbest").text = $.Localize("#speedrun_personalbest") + SecondsToMinsNSecs(data["time"])
}
function OnWR(data)
{	
	$("#worldrecord").text = $.Localize("#speedrun_worldrecord").replace("$TIME$", SecondsToMinsNSecs(data["time"]))
	$("#worldrecordAva").steamid = data["sid64"]
	$("#worldrecordName").steamid = data["sid32"]
}

function SecondsToMinsNSecs(seconds)
{
	var mins = Math.floor(seconds/60);
	var secs = Math.floor(seconds%60);
	
	if (mins < 10) {mins = "0"+mins}
	if (secs < 10) {secs = "0"+secs}
	
	return mins + ":" + secs;
}

function hax()
{
	var parent = $.GetContextPanel().GetParent();
	while(parent.id != "Hud")
		parent = parent.GetParent();
	
	parent.FindChildTraverse("TopBarDireTeamContainer").visible = false;
	
	return parent;
}
function uhax(parent)
{
	parent.FindChildTraverse("GameTime").text = sTime;
	
	$.Schedule(0.5, function () {
		uhax(parent)
	})
}