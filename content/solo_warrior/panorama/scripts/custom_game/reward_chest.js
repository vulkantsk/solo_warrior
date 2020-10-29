enabled = false
duration = -1
startTime = -1

function SelectGold()
{
	GameEvents.SendCustomGameEventToServer( "RewardChest_SelectReward", { reward: "gold"} );
    SetEnabled( false )
}

function SetEnabled( bool ) {
    enabled = bool
    $.GetContextPanel().SetHasClass( "Visible", bool )
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
    SetEnabled( false )
}

function RewardChest( data )
{
    SetEnabled( true )
    $("#RewardChestButtons").visible = true;
    $("#RewardChestItems").visible = false;
    $("#RewardChestButtonGold").GetChild(0).text = data.gold + " gold";

    startTime = data.start_time
    duration = data.duration
    
    for (var i = 1; i <= 6;i++)
    {
        $("#RewardChestItems").GetChild(i-1).itemname = data.items[i.toString()]
    }
}

function EndRewardChest( data )
{
    SetEnabled( false )
}

function Update() {
    $.Schedule( 0, Update )

    if ( !enabled ) {
        return
    }

    let now = Game.GetGameTime()
    let remaining = now - startTime
    let width = remaining / duration

    $( "#TimeRemaining" ).style.width = ( 200 - 200 * width ) + "px"
}

(function()
{
    GameEvents.Subscribe( "RewardChest", RewardChest)
    GameEvents.Subscribe( "EndRewardChest", EndRewardChest)
})();

Update()