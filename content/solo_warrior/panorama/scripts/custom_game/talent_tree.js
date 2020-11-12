var TALENTS_CONTAINER;
var TALENTS_LAYOUT = {
    "lastColumn": -1
};
var talentsData = {
    "talentsCount": 0,
};

function OnTalentsData(event) {
    var parsedTalents = JSON.parse(event.talents);
    for(var i=0; i < parsedTalents.length; i++) {
        talentsData[parsedTalents[i].id] = parsedTalents[i].data
    }
    BuildTalentTree(parsedTalents);
    talentsData.talentsCount += parsedTalents.length;
    if(talentsData.talentsCount >= event.count) {
	    GameEvents.SendCustomGameEventToServer( "talent_tree_get_state", {});
	    TALENTS_LAYOUT[TALENTS_LAYOUT["lastColumn"]].SetHasClass("last", true);
    }
}

function OnTalentsState(event) {
    var talentPoints = event.points;
    var parsedStateData = JSON.parse(event.talents);
    for(var i=0; i < parsedStateData.length; i++) {
        var talentId = parsedStateData[i].id;
        var talentColumn = talentsData[talentId].Column;
        var talentRow = talentsData[talentId].Row;
        talentsData[talentId].panel.SetHasClass("disabled", parsedStateData[i].disabled);
        talentsData[talentId].panel.levelLabel.text = parsedStateData[i].level + " / " + parsedStateData[i].maxlevel;
    }
    TALENTS_LAYOUT["TalentPointsLabel"].text = $.Localize("talent_tree_current_talent_points").replace("%POINTS%", talentPoints);
}

function BuildTalentTree(parsedTalents) {
    for (var key in parsedTalents) {
        var talentColumn = parsedTalents[key].data["Column"];
        var talentRow = parsedTalents[key].data["Row"];
        CreateTalentPanel(talentRow, talentColumn, parsedTalents[key].id);
    }
}

function CreateTalentPanel(row, column, talentId) {
    if (TALENTS_LAYOUT[column]) {
        if (TALENTS_LAYOUT[column][row]) {
            var talentPanel = $.CreatePanel("Panel", TALENTS_LAYOUT[column][row], "HeroTalent" + talentId);
            talentPanel.BLoadLayout("file://{resources}/layout/custom_game/talent_tree/talent.xml", false, false);
            talentPanel.hittest = false;
            talentPanel.hittestchildren = true;
			talentPanel.Data().ShowTalentTooltip = ShowTalentTooltip;
			talentPanel.Data().HideTalentTooltip = HideTalentTooltip;
			talentPanel.Data().OnTalentClick = OnTalentClick;
			var talentImagePanel = talentPanel.FindChildTraverse("TalentImage");
			if(talentImagePanel) {
			    talentImagePanel.SetImage(talentsData[talentId].Icon);
			}
			if(column > TALENTS_LAYOUT["lastColumn"]) {
			    TALENTS_LAYOUT["lastColumn"] = column;
			}
			talentsData[talentId].panel = talentPanel;
			talentsData[talentId].panel.levelLabel = talentPanel.FindChildTraverse("TalentLevel");
        } else {
            TALENTS_LAYOUT[column][row] = CreateTalentRow(row, column);
            CreateTalentPanel(row, column, talentId);
        }
    } else {
        var talentColumnPanel = $.CreatePanel("Panel", TALENTS_CONTAINER, "");
        talentColumnPanel.SetHasClass("TalentTreeColumn", true);
        TALENTS_LAYOUT[column] = talentColumnPanel;
        talentColumnPanel.hittest = false;
        talentColumnPanel.hittestchildren = true;
        var titleRow = CreateTalentRow(row, column, true);
        var titleLabel = $.CreatePanel("Label", titleRow, "");
        titleLabel.SetHasClass("TitleLabel", true);
        titleLabel.text = $.Localize("#talent_tree_column_" + column + "_title");
        titleRow.hittest = false;
        titleRow.hittestchildren = true;
        CreateTalentPanel(row, column, talentId);
    }
}

function CreateTalentRow(row, column, isTitleRow) {
    if (TALENTS_LAYOUT[column]) {
        var talentRowPanel = $.CreatePanel("Panel", TALENTS_LAYOUT[column], "");
        talentRowPanel.SetHasClass("TalentTreeRow", true);
        if(isTitleRow == null) {
            TALENTS_LAYOUT[column][row] = talentRowPanel;
        }
        return talentRowPanel
    }
}

function ShowTalentTooltip(talentId) {
    var talentName = $.Localize("#talent_tree_talent_" + talentId);
    var talentIcon = talentsData[talentId].Icon;
    var talentDescription = $.Localize("#talent_tree_talent_" + talentId + "_Description");
	$.DispatchEvent("DOTAShowTitleImageTextTooltip", $.GetContextPanel(), talentName, talentIcon, talentDescription);
}

function HideTalentTooltip() {
    $.DispatchEvent("DOTAHideTitleImageTextTooltip", $.GetContextPanel());
}

function OnTalentClick(talentId) {
    var context = $.GetContextPanel();
    if(!context.BHasClass("disabled")) {
        GameEvents.SendCustomGameEventToServer( "talent_tree_level_up_talent", {"id": id});
        Game.EmitSound("General.SelectAction");
    }
}

(function() {
    TALENTS_CONTAINER = $("#TalentTreeColumnsContainer");
    TALENTS_LAYOUT["TalentPointsLabel"] = $("#CurrentTalentPoints");
    GameEvents.Subscribe("talent_tree_get_talents_from_server", OnTalentsData);
    GameEvents.Subscribe("talent_tree_get_state_from_server", OnTalentsState);
	GameEvents.SendCustomGameEventToServer( "talent_tree_get_talents", {});
})();

