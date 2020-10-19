function SelectGold()
{
	GameEvents.SendCustomGameEventToServer( "RewardChest_SelectReward", { reward: "gold"} );
    $("#RewardChest").visible = false;
}

function SelectItems()
{
	GameEvents.SendCustomGameEventToServer( "RewardChest_SelectReward", { reward: "item"} );
    $("#RewardChestButtons").visible = false;
    $("#RewardChestItems").visible = true;
}

function SelectItem(item)
{
	GameEvents.SendCustomGameEventToServer( "RewardChest_SelectReward", { reward: item} );
    $("#RewardChest").visible = false;
}

function RewardChest( data )
{
    $("#RewardChest").visible = true;
    $("#RewardChestButtons").visible = true;
    $("#RewardChestItems").visible = false;
    $("#RewardChestButtonGold").GetChild(0).text = data.gold + " gold";
    
    for (var i = 1; i <= 6;i++)
    {
        $("#RewardChestItems").GetChild(i-1).itemname = data.items[i.toString()]
    }
}

function EndRewardChest( data )
{
    $("#RewardChest").visible = false;
}

(function()
{
    $("#RewardChest").visible = false;
    GameEvents.Subscribe( "RewardChest", RewardChest)
    GameEvents.Subscribe( "EndRewardChest", EndRewardChest)
})();