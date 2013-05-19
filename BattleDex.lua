BattleDex = {};
BattleDex.default_options = {
};

function BattleDex.OnReady()

	-- init database
	_G.BattleDexDB = _G.BattleDexDB or {};
	_G.BattleDexDB.pets = _G.BattleDexDB.pets or {};

	-- set up default options
	_G.BattleDexPrefs = _G.BattleDexPrefs or {};
	for k,v in pairs(BattleDex.default_options) do
		if (not _G.BattleDexPrefs[k]) then
			_G.BattleDexPrefs[k] = v;
		end
	end
end

function BattleDex.OnEvent(frame, event, ...)

	if (event == 'ADDON_LOADED') then
		local name = ...;
		if name == 'BattleDex' then
			BattleDex.OnReady();
		end
		return;
	end

	if (event == 'PET_BATTLE_OPENING_DONE') then
		BattleDex.RecordBattle();
	end
end


function BattleDex.RecordBattle()

	if (not C_PetBattles.IsWildBattle()) then
		return;
	end

	-- get pet info

	local s1 = C_PetBattles.GetPetSpeciesID(2, 1);
	local s2 = C_PetBattles.GetPetSpeciesID(2, 2);
	local s3 = C_PetBattles.GetPetSpeciesID(2, 3);

	local l1 = C_PetBattles.GetLevel(2, 1);
	local l2 = C_PetBattles.GetLevel(2, 2);
	local l3 = C_PetBattles.GetLevel(2, 3);

	local r1 = C_PetBattles.GetBreedQuality(2, 1);
	local r2 = C_PetBattles.GetBreedQuality(2, 2);
	local r3 = C_PetBattles.GetBreedQuality(2, 3);

	-- record each pet

	BattleDex.RecordPet(s1, l1, r1, 0);
	BattleDex.RecordPet(s2, l2, r2, s1);
	BattleDex.RecordPet(s3, l3, r3, s1);
end

function BattleDex.RecordPet(species, level, quality, primary)

	print(string.format("s=%d, l=%d, q=%d, p=%d", species, level, quality, primary));

	_G.BattleDexDB.pets[species] = _G.BattleDexDB.pets[species] or {};

	local key = primary.."_"..level.."_"..quality;

	_G.BattleDexDB.pets[species][key] = _G.BattleDexDB.pets[species][key] or 0;
	_G.BattleDexDB.pets[species][key] = _G.BattleDexDB.pets[species][key] + 1;
end


-- ############################# Slash Commands #############################

SLASH_BattleDex1 = '/bd';
SLASH_BattleDex2 = '/battledex';

function SlashCmdList.BattleDex(msg, editBox)
end

-- ############################# Event Frame #############################

BattleDex.EventFrame = CreateFrame("Frame");
BattleDex.EventFrame:Show();
BattleDex.EventFrame:SetScript("OnEvent", BattleDex.OnEvent);
BattleDex.EventFrame:SetScript("OnUpdate", BattleDex.OnUpdate);
BattleDex.EventFrame:RegisterEvent("ADDON_LOADED");
BattleDex.EventFrame:RegisterEvent("PET_BATTLE_OPENING_DONE");
