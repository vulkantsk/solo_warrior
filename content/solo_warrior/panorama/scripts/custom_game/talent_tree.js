var TALENTS_CONTAINER;
var TALENTS_LAYOUT = {};
var talentsData = {};

function OnTalentsData(event) {
    var parsedTalents = JSON.parse(event.talents);
    for(var i=0; i < parsedTalents.length; i++) {
        talentsData[parsedTalents[i].id] = parsedTalents[i].data
    }
    BuildTalentTree(parsedTalents);
}

function BuildTalentTree(parsedTalents) {

    for (var key in parsedTalents) {
        var talentColumn = parsedTalents[key].data["Column"];
        var talentRow = parsedTalents[key].data["Row"];
        CreateTalentPanel(talentRow, talentColumn, parsedTalents[key].id)
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
        TALENTS_LAYOUT[column]["titleRow"] = titleRow;
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

function ShowTalentTooltip(id) {
    $.Msg("Show"+ id);
}

function HideTalentTooltip() {
    $.Msg("Hide");
}

function OnTalentClick(id) {
    $.Msg("click" + id);
}

(function() {
    TALENTS_CONTAINER = $("#TalentTreeColumnsContainer");
    GameEvents.Subscribe("talent_tree_get_talents_from_server", OnTalentsData);
	GameEvents.SendCustomGameEventToServer( "talent_tree_get_talents", {});
})();

