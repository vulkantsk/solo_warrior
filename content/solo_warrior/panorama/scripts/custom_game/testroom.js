function SetRoom()
{
	GameEvents.SendCustomGameEventToServer( "TestRoom_SetRoom", { room: $("#MyEntry").text } );
}

function SetHero()
{
	GameEvents.SendCustomGameEventToServer( "TestRoom_SetHero", { room: $("#MyEntry").text } );
}

(function()
{
    $("#TestRoomButtons").visible = Game.GetMapInfo().map_display_name == "testroom";
})();