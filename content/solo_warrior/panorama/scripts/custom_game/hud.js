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
	$("#personalpos").text = "#" + data["pos"] + "/" + data["max"] 
}
function OnWR(data)
{	
	$("#worldrecord").text = $.Localize("#speedrun_worldrecord").replace("$TIME$", SecondsToMinsNSecs(data["obj"]["1"]["time"]))
	$("#worldrecordAva").steamid = data["sid64"]
	$("#worldrecordName").steamid = data["obj"]["1"]["sid"]
	
	for(var i = 1; i <= 10; i++)
	{
		var j = i.toString()
		var record = data["obj"][j]
		
		if (record != null)
		{
			$("#sr"+j+"id").text = "#" + j
			$("#sr"+j+"name").steamid = record["sid"]
			$("#sr"+j+"time").text = SecondsToMinsNSecs(record["time"])
			$("#sr"+j+"id").GetParent().GetParent().SetHasClass("hide", false)
		}
		else
		{
			$("#sr"+j+"id").GetParent().GetParent().SetHasClass("hide", true)
		}
	}
}

function SecondsToMinsNSecs(seconds)
{
	var mins = Math.floor(seconds/60);
	var secs = Math.floor(seconds%60);
	
	if (mins < 10) {mins = "0"+mins}
	if (secs < 10) {secs = "0"+secs}
	
	return mins + ":" + secs;
}

function ShowRecords()
{
	$("#SpeedrunRecords").ToggleClass("hide")
}

function hax()
{
	var parent = $.GetContextPanel().GetParent();
	while(parent.id != "Hud")
		parent = parent.GetParent();
	
	parent.FindChildTraverse("TopBarDireTeamContainer").visible = false;
	parent.FindChildTraverse("TopBarRadiantScore").visible = false;
	
	var players = parent.FindChildrenWithClassTraverse("TopBarPlayerSlot")
	for (var i = 0; i < players.length; i++)
	{
		if (players[i].id != "RadiantPlayer0")
		{
			players[i].visible = false;
		}
		else
		{
			players[i].style.marginRight = "15px;"
		}
	}
	
	return parent;
}
function uhax(parent)
{
	parent.FindChildTraverse("GameTime").text = sTime;
	
	$.Schedule(0.5, function () {
		uhax(parent)
	})
}