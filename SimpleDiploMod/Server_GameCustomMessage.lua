function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	local rg = {};
	--if(payload.Message == "Offer Allianze")then
	--	local target = tonumber(payload.TargetPlayerID);
	--	local preis = tonumber(payload.Wert);
	--	for _,pid in pairs(game.Game.Players)do
	--		if(pid.IsAI == true)then
	--			if(Mod.Settings.PublicAllies == true or (pid.ID == playerID or pid.ID == target))then
	--				local playerGameData = Mod.PlayerGameData;
	--				if(playerGameData[pid.ID].PendingAllianzes == nil)then
	--					playerGameData[pid.ID].PendingAllianzes = ",";
	--				end
	--				playerGameData[pid.ID].PendingAllianzes = playerGameData[pid.ID].PendingAllianzes .. playerID .. "," .. target .. "," .. preis .. ",";
	--				Mod.PlayerGameData = playerGameData;
	--				addmessage(playerID .. ",12,".. tostring(game.Game.NumberOfTurns+1) .. "," .. tostring(payload.Wert) .. ",",target);
	--			end
	--		end
	--	end
	--end
	if(payload.Message == "Read")then
		local playerGameData = Mod.PlayerGameData;
		playerGameData[playerID].NeueNachrichten = nil;
		Mod.PlayerGameData = playerGameData;
	end
	if(payload.Message == "Gift Money")then
		local playerGameData = Mod.PlayerGameData;
		local target = tonumber(payload.TargetPlayerID);
		playerGameData[playerID].Money = playerGameData[playerID].Money - tonumber(payload.Wert);
		playerGameData[target].Money = playerGameData[target].Money + tonumber(payload.Wert);
		Mod.PlayerGameData = playerGameData;
		addmessage(target .. ",10,".. tostring(game.Game.NumberOfTurns+1) .. "," .. tostring(payload.Wert) .. ",",playerID);
		addmessage(playerID .. ",11,".. tostring(game.Game.NumberOfTurns+1) .. "," .. tostring(payload.Wert) .. ",",target);
	end
 	if(payload.Message == "Peace")then
		local target = payload.TargetPlayerID;
		local preis = payload.Preis;
		local dauer = payload.duration;
		if(target> 50)then
			local rg = {};
			if(game.ServerGame.Game.Players[target].HumanTurnedIntoAI)then
				if(preis ~= 0)then
					rg.Message ="Also players that are turned into ais, don't accept peace offers that cost money";
					setReturnTable(rg);
				end
				local playerGameData = Mod.PlayerGameData;
				local preis = 0;
				local dauer = 0;
				if(playerGameData[playerID].Peaceoffers == nil)then
					playerGameData[playerID].Peaceoffers = ",";
				end
				offers = stringtotable(playerGameData[playerID].Peaceoffers);
				local num = 1;
				local remainingoffers = ",";
				local found = false;
				while(offers[num]~=nil and offers[num+1]~=nil and offers[num+2]~=nil and offers[num+2]~="")do
					if(tonumber(offers[num])==tonumber(an))then
						preis = tonumber(offers[num+1]);
						dauer = tonumber(offers[num+2]);
						found=true;
					else
						remainingoffers = remainingoffers .. offers[num] .. "," .. offers[num+1] .. "," .. offers[num+2] .. ",";
					end
					num = num + 3;
				end
				if(remainingoffers == ",")then
					playerGameData[playerID].Peaceoffers = nil;
				else
					playerGameData[playerID].Peaceoffers = remainingoffers;
				end
				if(playerGameData[target].Peaceoffers == nil)then
					playerGameData[target].Peaceoffers = ",";
				end
				offers = stringtotable(playerGameData[target].Peaceoffers);
				remainingoffers = ",";
				num = 1;
				while(offers[num]~=nil and offers[num+1]~=nil and offers[num+2]~=nil and offers[num+2]~="")do
					if(tonumber(offers[num])~=tonumber(playerID))then
						found=true;
						remainingoffers = remainingoffers .. offers[num] .. "," .. offers[num+1] .. "," .. offers[num+2] .. ",";
					end
					num = num + 3;
				end
				if(remainingoffers == ",")then
					playerGameData[target].Peaceoffers = nil;
				else
					playerGameData[target].Peaceoffers = remainingoffers;
				end
				Mod.PlayerGameData = playerGameData;
				for _,pID in pairs(game.ServerGame.Game.Players)do
					if(pID.ID == playerID or pID.ID == target)then
						addmessage(playerID .. ",2,"..tostring(game.Game.NumberOfTurns+dauer).. "," .. target .. ",",pID.ID);
					else
						addmessage(playerID .. ",2,".. tostring(game.Game.NumberOfTurns+dauer).. "," .. target .. ",",pID.ID);
					end
				end
				local publicGameData = Mod.PublicGameData;
				local remainingwar = ",";
				local withtable = stringtotable(Mod.PublicGameData.War[target]);
				for _,with in pairs(withtable) do
					if(tonumber(with)~=playerID)then
						remainingwar = remainingwar .. with .. ",";
					end
				end
				publicGameData.War[target] = remainingwar;
				remainingwar = ",";
				local withtable = stringtotable(Mod.PublicGameData.War[playerID]);
				for _,with in pairs(withtable) do
					if(tonumber(with)~=target)then
						remainingwar = remainingwar .. with .. ",";
					end
				end
				publicGameData.War[playerID] = remainingwar;
				Mod.PublicGameData = publicGameData;
				local privateGameData = Mod.PrivateGameData;
				if(privateGameData.Cantdeclare==nil)then
					privateGameData.Cantdeclare = {};
				end
				num = game.Game.NumberOfTurns;
				while(num < game.Game.NumberOfTurns+dauer)do
					if(privateGameData.Cantdeclare[num] == nil)then
						privateGameData.Cantdeclare[num] = ",";
					end
					privateGameData.Cantdeclare[num] = privateGameData.Cantdeclare[num] .. target .. "," .. playerID .. ",";
					num = num +1;
				end
				Mod.PrivateGameData = privateGameData;
			else
				local playerGameData = Mod.PlayerGameData;
				local existingpeaceoffers = ",";
 				if(playerGameData[target].Peaceoffers~=nil)then
					existingpeaceoffers=playerGameData[target].Peaceoffers;
				end
				local existingofferssplit = stringtotable(existingpeaceoffers);
				local num = 1;
				local match = false;
				while(existingofferssplit[num] ~=nil)do
					if(tonumber(existingofferssplit[num]) == playerID)then
						match = true;
					end
					num=num+2;
				end
				--playerGameData[playerID].NeueNachrichten = playerGameData[pID].NeueNachrichten ..  playerID .. ",1," .. duration .. "," .. target .. ",";
				--playerGameData[target].Nachrichten = playerGameData[pID].Nachrichten ..  playerID .. ",1,".. duration .. "," .. target .. ",";
				if(match == false)then
					playerGameData[target].Peaceoffers = existingpeaceoffers .. playerID .. "," .. preis .. "," .. dauer .. ",";
					Mod.PlayerGameData=playerGameData;
					for _,pID in pairs(game.ServerGame.Game.Players)do
						if(pID.ID ~= playerID or pID.ID ~= target)then
							addmessage(playerID .. ",1," .. dauer .. ",".. target .. ",",pID.ID);
						else
							addmessage(playerID .. ",1," .. dauer .. ",".. target .. ",",pID.ID);
						end
					end
					rg.Message ='The Offer has been submitted';
					setReturnTable(rg);
				else
					rg.Message ='The player has already a pending peace offer by you.';
					setReturnTable(rg);
				end
			end
		else
			local publicGameData = Mod.PublicGameData;
			local remainingwar = ",";
			local withtable = stringtotable(Mod.PublicGameData.War[target]);
			for _,with in pairs(withtable) do
				if(tonumber(with)~=playerID)then
					remainingwar = remainingwar .. with .. ",";
				end
			end
			publicGameData.War[target] = remainingwar;
			remainingwar = ",";
			local withtable = stringtotable(Mod.PublicGameData.War[playerID]);
			for _,with in pairs(withtable) do
				if(tonumber(with)~=target)then
					remainingwar = remainingwar .. with .. ",";
				end
			end
			publicGameData.War[playerID] = remainingwar;
			Mod.PublicGameData = publicGameData;
			local privateGameData = Mod.PrivateGameData;
			if(privateGameData.Cantdeclare == nil)then
				privateGameData.Cantdeclare = {};
			end
			num = game.Game.NumberOfTurns;
			while(num < game.Game.NumberOfTurns+dauer)do
				if(privateGameData.Cantdeclare[num] == nil)then
					privateGameData.Cantdeclare[num] = ",";
				end
				privateGameData.Cantdeclare[num] = privateGameData.Cantdeclare[num] .. target .. "," .. playerID .. ",";
				num = num +1;
			end
			Mod.PrivateGameData = privateGameData;
			for _,pID in pairs(game.ServerGame.Game.Player)do
				if(pID.ID == playerID or pID.ID == target)then
					addmessage(playerID .. ",2," .. tostring(game.Game.NumberOfTurns+dauer) .. "," .. target .. ",",pID.ID);
				else
					addmessage(playerID .. ",2,".. tostring(game.Game.NumberOfTurns+dauer) .. "," .. target .. ",",pID.ID);
				end
			end
			rg.Message = 'The AI accepted your offer';
			setReturnTable(rg);
			--accept peace cause ai
		end
	else
		rg.Message = 'Bug';
		setReturnTable(rg);
  	end
	if(payload.Message == "Accept Peace" or payload.Message == "Decline Peace")then
		local playerGameData = Mod.PlayerGameData;
		local an = payload.TargetPlayerID;
		local preis = 0;
		local dauer = 0;
		offers = stringtotable(playerGameData[playerID].Peaceoffers);
		local num = 1;
		local remainingoffers = ",";
		local found = false;
		while(offers[num]~=nil and offers[num+1]~=nil and offers[num+2]~=nil and offers[num+2]~="")do
			if(tonumber(offers[num])==tonumber(an))then
				preis = tonumber(offers[num+1]);
				dauer = tonumber(offers[num+2]);
				found=true;
			else
				remainingoffers = remainingoffers .. offers[num] .. "," .. offers[num+1] .. "," .. offers[num+2] .. ",";
			end
			num = num + 3;
		end
		if(remainingoffers == ",")then
			playerGameData[playerID].Peaceoffers = nil;
		else
			playerGameData[playerID].Peaceoffers = remainingoffers;
		end
		offers = stringtotable(playerGameData[an].Peaceoffers);
		remainingoffers = ",";
		num = 1;
		while(offers[num]~=nil and offers[num+1]~=nil and offers[num+2]~=nil and offers[num+2]~="")do
			if(tonumber(offers[num])~=tonumber(playerID))then
				found=true;
				remainingoffers = remainingoffers .. offers[num] .. "," .. offers[num+1] .. "," .. offers[num+2] .. ",";
			end
			num = num + 3;
		end
		if(remainingoffers == ",")then
			playerGameData[an].Peaceoffers = nil;
		else
			playerGameData[an].Peaceoffers = remainingoffers;
		end
		if(payload.Message == "Accept Peace")then
			if(found == true)then
				playerGameData[an].Money = Mod.PlayerGameData[an].Money + preis;
				playerGameData[playerID].Money = Mod.PlayerGameData[playerID].Money - preis;
				Mod.PlayerGameData=playerGameData;
				for _,pID in pairs(game.ServerGame.Game.Players)do
					if(pID.ID == playerID or pID.ID == target)then
						addmessage(playerID .. ",2,"..tostring(game.Game.NumberOfTurns+dauer).. "," .. an .. ",",pID.ID);
					else
						addmessage(playerID .. ",2,".. tostring(game.Game.NumberOfTurns+dauer).. "," .. an .. ",",pID.ID);
					end
				end
				local publicGameData = Mod.PublicGameData;
				local remainingwar = ",";
				local withtable = stringtotable(Mod.PublicGameData.War[an]);
				for _,with in pairs(withtable) do
					if(tonumber(with)~=playerID)then
						remainingwar = remainingwar .. with .. ",";
					end
				end
				publicGameData.War[an] = remainingwar;
				remainingwar = ",";
				local withtable = stringtotable(Mod.PublicGameData.War[playerID]);
				for _,with in pairs(withtable) do
					if(tonumber(with)~=an)then
						remainingwar = remainingwar .. with .. ",";
					end
				end
				publicGameData.War[playerID] = remainingwar;
				Mod.PublicGameData = publicGameData;
				local privateGameData = Mod.PrivateGameData;
				if(privateGameData.Cantdeclare==nil)then
					privateGameData.Cantdeclare = {};
				end
				num = game.Game.NumberOfTurns;
				while(num < game.Game.NumberOfTurns+dauer)do
					if(privateGameData.Cantdeclare[num] == nil)then
						privateGameData.Cantdeclare[num] = ",";
					end
					privateGameData.Cantdeclare[num] = privateGameData.Cantdeclare[num] .. an .. "," .. playerID .. ",";
					num = num +1;
				end
				Mod.PrivateGameData = privateGameData;
			else
				local rg = {};
				rg.Message = "1";
				setReturnTable(rg);
			end
		else
			Mod.PlayerGameData=playerGameData;
			for _,pID in pairs(game.ServerGame.Game.Players)do
				if(pID.ID == playerID or pID.ID == target)then
					addmessage(playerID .. ",3,".. "," .. an .. ",",pID.ID);
				else
					addmessage(playerID .. ",3,".. "," .. an .. ",",pID.ID);
				end
			end
		end
	end
	if(payload.Message == "Territory Sell")then
		local target = tonumber(payload.TargetPlayerID);--target == 0 = everyone
		local Preis = payload.Preis;
		local targetterr = tonumber(payload.TargetTerritoryID);
		local playerGameData = Mod.PlayerGameData;
		if(target == 0)then
			--option everyone
			local addedoffers = 0;
			local alreadyoffered = -1;
			for _,pid in pairs(game.ServerGame.Game.Players)do
				if(pid.IsAI == false and pid.ID ~= playerID)then
					local existingterroffers = ",";
					if(playerGameData[pid.ID].Terrselloffers~=nil)then
						existingterroffers=playerGameData[pid.ID].Terrselloffers;
					end
					if(HasTerritoryOffer(existingterroffers,playerID,targetterr)==false)then
						existingterroffers = existingterroffers .. tostring(playerID) .. ',' .. tostring(targetterr) .. ',' .. Preis .. ',';
						playerGameData[pid.ID].Terrselloffers = existingterroffers;
						addedoffers = addedoffers + 1;
					else
						alreadyoffered = alreadyoffered + 1;
					end
				end
			end
			if(addedoffers==0)then
				rg.Message ='Everyone has already a pending territory sell offer for that territoy by you.';
				setReturnTable(rg);
			else
				if(alreadyoffered > 0)then
					rg.Message ='You successfully added ' .. tostring(addedoffers) .. ' Territory Sell Offers ' .. '\n' .. tostring(alreadyoffered) .. ' players had already a territory sell offer for that territory';
				else
					rg.Message ='You successfully added ' .. tostring(addedoffers) .. ' Territory Sell Offers';
				end
				setReturnTable(rg);
				Mod.PlayerGameData = playerGameData;
			end
		else
			local existingterroffers = ",";
			if(playerGameData[target].Terrselloffers~=nil)then
				existingterroffers=playerGameData[target].Terrselloffers;
			end
			if(HasTerritoryOffer(existingterroffers,playerID,targetterr))then
				rg.Message ='The player has already a pending territory sell offer by you for that territory.';
				setReturnTable(rg);
			else
				existingterroffers = existingterroffers .. tostring(playerID) .. ',' .. tostring(targetterr) .. ',' .. Preis .. ',';
				playerGameData[target].Terrselloffers = existingterroffers;
				Mod.PlayerGameData = playerGameData;
				rg.Message ='The player recieved the offer.';
				setReturnTable(rg);
			end
		end
	end
	if(payload.Message == "Deny Territory Sell")then
		local removed = false;
		local von = tonumber(payload.TargetPlayerID);
		local terr = tonumber(payload.TargetTerritoryID);
		local num = 1;
		local existingterroffers = stringtotable(Mod.PlayerGameData[playerID].Terrselloffers);
		local remainingoffers = ",";
		while(existingterroffers[num+2] ~= nil)do
			if(tonumber(existingterroffers[num]) ~= von or tonumber(existingterroffers[num+1]) ~= terr)then
				remainingoffers = remainingoffers .. existingterroffers[num] .. ",".. existingterroffers[num+1] .. "," .. existingterroffers[num+2] .. ",";
			end
			num = num+3;
		end
		local playerdata = Mod.PlayerGameData;
		playerdata[playerID].Terrselloffers=remainingoffers;
		Mod.PlayerGameData = playerdata;
		addmessage(von .. ",4,".. tostring(game.Game.NumberOfTurns) .. "," .. terr .. ",",playerID);
		addmessage(playerID .. ",5,".. tostring(game.Game.NumberOfTurns) .. "," .. terr .. ",",playerID);
	end
end
function addmessage(message,spieler)
	if(Mod.PlayerGameData[spieler] ~= nil)then
		local playerdata = Mod.PlayerGameData;
		if(playerdata[spieler].Nachrichten== nil)then
			playerdata[spieler].Nachrichten = ",";
		end
		if(playerdata[spieler].NeueNachrichten== nil)then
			playerdata[spieler].NeueNachrichten = ",";
		end
		playerdata[spieler].Nachrichten = playerdata[spieler].Nachrichten .. message;
		playerdata[spieler].NeueNachrichten = playerdata[spieler].NeueNachrichten .. message;
		Mod.PlayerGameData = playerdata;
	end
end
function HasTerritoryOffer(data,von,terr)
	local num = 1;
	data = stringtotable(data);
	while(data[num] ~= nil)do
		if(tonumber(data[num]) == von)then
			if(tonumber(data[num+1]) == terr)then
				return true;
			end
		end
		num = num+3;
	end
	return false;
end
function stringtotable(variable)
	local chartable = {};
	if(variable ~= nil)then
		while(string.len(variable)>0)do
			chartable[tablelength(chartable)] = string.sub(variable, 1 , 1);
			variable = string.sub(variable, 2);
		end
		local newtable = {};
		local tablepos = 0;
		local executed = false;
		for _, elem in pairs(chartable)do
			if(elem == ",")then
				tablepos = tablepos + 1;
				newtable[tablepos] = "";
				executed = true;
			else
				if(executed == false)then
					tablepos = tablepos + 1;
					newtable[tablepos] = "";
					executed = true;
				end
				if(newtable[tablepos] == nil)then
					newtable[tablepos] = elem;
				else
					newtable[tablepos] = newtable[tablepos] .. elem;
				end
			end
		end
		return newtable;
	else
		return {};
	end
end
function tablelength(T)
	local count = 0;
	for _,elem in pairs(T)do
		count = count + 1;
	end
	return count;
end
