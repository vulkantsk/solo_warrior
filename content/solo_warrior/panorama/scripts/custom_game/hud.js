sTime = "00:00";

(function () {
	uhax(hax())
	
	GameEvents.Subscribe( "speedrun_time", OnTime);
	GameEvents.Subscribe( "speedrun_pb", OnPB);
	GameEvents.Subscribe( "speedrun_wr", OnWR);
	GameEvents.Subscribe( "dprint_client", OnPrint);
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
	
	if (parent.BHasClass("HUDFlipped"))
	{
		parent.FindChildTraverse("TalentTreeWindowButton").style.horizontalAlign = "right"
	}
	
	parent.FindChildTraverse("TopBarDireTeamContainer").visible = false;
	parent.FindChildTraverse("TopBarRadiantScore").visible = false;
	
	parent.FindChildTraverse("AghsStatusContainer").visible = false;
	
	parent.FindChildTraverse("HUDElements").FindChildTraverse("level_stats_frame").visible = false;
	parent.FindChildTraverse("HUDElements").FindChildTraverse("StatBranch").visible = false; 
	parent.FindChildTraverse("HUDElements").FindChildTraverse("PortraitBacker").style.width = "160px;";
	parent.FindChildTraverse("HUDElements").FindChildTraverse("PortraitBackerColor").style.width = "160px;";
	parent.FindChildTraverse("StatBranch").SetHasClass("ShowStatBranch", false)
	parent.FindChildTraverse("StatBranch").style.visibility = "collapse;";
	parent.FindChildTraverse("StatBranch").enabled = false;
	parent.FindChildTraverse("StatBranch").hittest = false;
	parent.FindChildTraverse("StatBranch").hittestchildren = false;
	parent.FindChildTraverse("StatBranch").SetPanelEvent("onhover", function () {
		parent.FindChildTraverse("StatBranch").enabled = false;
		parent.FindChildTraverse("StatBranch").hittest = false;
		parent.FindChildTraverse("StatBranch").hittestchildren = false;
	})	

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
	//parent.SetHasClass("HUDFlipped", false)
	
	parent.FindChildTraverse("GameTime").text = sTime;
	
	var items = parent.FindChildrenWithClassTraverse("AbilityDraftUpgradeHeader")
	for (i = 0; i < items.length; i++)
	{
		var desc = items[i].GetParent().GetParent().FindChildTraverse("SellPriceLabel")
		if (desc != null)
		{
			desc.text = $.Localize("sw_sell_price")
		}
	}
	
	$.Schedule(0.5, function () {
		uhax(parent)
	})
}

function OnPrint(data)
{
	$.Msg(data["msg"])
}