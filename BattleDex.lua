BattleDex = {};
BattleDex.default_options = {
};

function BattleDex.OnReady()

	-- init database
	_G.BattleDexDB = _G.BattleDexDB or {};
	_G.BattleDexDB.pets = _G.BattleDexDB.pets or {};

	-- set up default options
	_G.BattleDexPrefs = _G.BattleDexPrefs or {};
	local k,v;
	for k,v in pairs(BattleDex.default_options) do
		if (not _G.BattleDexPrefs[k]) then
			_G.BattleDexPrefs[k] = v;
		end
	end

	GameTooltip:HookScript("OnTooltipSetUnit", BattleDex.AlterTooltip);
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

	--print(string.format("s=%d, l=%d, q=%d, p=%d", species, level, quality, primary));

	_G.BattleDexDB.pets[species] = _G.BattleDexDB.pets[species] or {};

	local key = primary.."_"..level.."_"..quality;

	_G.BattleDexDB.pets[species][key] = _G.BattleDexDB.pets[species][key] or 0;
	_G.BattleDexDB.pets[species][key] = _G.BattleDexDB.pets[species][key] + 1;
end

function BattleDex.AlterTooltip()

	local _, unit = GameTooltip:GetUnit();
        if (not unit) then return; end;
	if (not UnitIsWildBattlePet(unit)) then return; end;

	local species = UnitBattlePetSpeciesID(unit);

	-- is this pet in our DB at all?
	if (not _G.BattleDexDB.pets[species]) then
		GameTooltip:AddLine("|cFF9999FFNever battled");
		GameTooltip:Show();
		return;
	end

	-- make a new data structure of [primary -> {quality: count, quality:count}]
	local counts = {};
	local k,v;
	for k,v in pairs(_G.BattleDexDB.pets[species]) do
		local itr = string.gmatch(k, "%d+");
		local pri = tonumber(itr());
		local lvl = tonumber(itr());
		local qul = tonumber(itr());

		--GameTooltip:AddLine(string.format("%d / %d / %d", pri, qul, v));

		counts[pri] = counts[pri] or {};
		counts[pri][qul] = v;
	end

	-- colors
	local _, _, _, col0 = GetItemQualityColor(0);
	local _, _, _, col1 = GetItemQualityColor(1);
	local _, _, _, col2 = GetItemQualityColor(2);
	local _, _, _, col3 = GetItemQualityColor(3);

	-- output
	for k,v in pairs(counts) do
		local pri = k;
		local num1 = v[1] or 0;
		local num2 = v[2] or 0;
		local num3 = v[3] or 0;
		local num4 = v[4] or 0;

		local nums = string.format("|c%s%d|r/|c%s%d|r/|c%s%d|r/|c%s%d|r", col0,num1,col1,num2,col2,num3,col3,num4);

		if (pri == 0) then
			GameTooltip:AddLine("Primary: "..nums);
		else
			local name = C_PetJournal.GetPetInfoBySpeciesID(pri);
			GameTooltip:AddLine(name..": "..nums);
		end
	end

	GameTooltip:Show();
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
