function Server_AdvanceTurn_Start (game,addNewOrder)
	AllAIs = {};
	for _,terr in pairs(game.ServerGame.LatestTurnStanding.Territories)do
		local Match = false;
		local CheckingID = terr.OwnerPlayerID;
		if(CheckingID ~= WL.PlayerID.Neutral)then
			if(game.Game.Players[CheckingID].IsAI)then
				for _,knownAIs in pairs(AllAIs)do
					if(CheckingID == knownAIs)then
						Match = true;
					end
				end
				if(Match == false)then
					AllAIs[tablelength(AllAIs)] = CheckingID;
				end
			end
		end
	end
end
function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if(order.proxyType == "GameOrderAttackTransfer")then
		if(result.IsAttack and game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID ~= WL.PlayerID.Neutral)then
			print('Attack');
			if(InWar(game.ServerGame.LatestTurnStanding.Territories[order.From].OwnerPlayerID,game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID) == true)then
				--Set attacks between
			else
				skipThisOrder(WL.ModOrderControl.Skip);
				--War declaration
				if(Mod.Settings.AllowAIDeclaration == false)then
					local Match = false;
					if(AllAIs == nil)then
						print('Fehler');
					end
					for _, AI in pairs(AllAIs)do
						if(game.ServerGame.LatestTurnStanding.Territories[order.From].OwnerPlayerID == AI)then
							Match = true;
						end
					end
					if(Match == false)then
						DeclearWar(game.ServerGame.LatestTurnStanding.Territories[order.From].OwnerPlayerID,game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID);
						--Allys declear war on order.From if not allied with order.From
					end
				else
					DeclearWar(game.ServerGame.LatestTurnStanding.Territories[order.From].OwnerPlayerID,game.ServerGame.LatestTurnStanding.Territories[order.To].OwnerPlayerID);
					--Allys declear war on order.From if not allied with order.From
				end
			end
		end
	end
	--War declearation through sanction card
	if(order.proxyType == "GameOrderPlayCardSanctions")then
		print('Sanction');
		skipThisOrder(WL.ModOrderControl.Skip);
		if(InWar(order.PlayerID,order.SanctionedPlayerID) == false)then
			if(Mod.Settings.AllowAIDeclaration == false)then
				local Match = false;
				if(AllAIs == nil)then
					print('Fehler');
				end
				for _, AI in pairs(AllAIs)do
					if(order.PlayerID == AI)then
						Match = true;
					end
				end
				if(Match == false)then
					DeclearWar(order.PlayerID,order.SanctionedPlayerID);
					--Allys declear war on order.PlayerID if not allied with order.PlayerID
				end
			else
				DeclearWar(order.PlayerID,order.SanctionedPlayerID);
				--Allys declear war on order.PlayerID if not allied with order.PlayerID
			end
		else
			--peace offer, but Allys are still in war
		end
	end
	--Ally offer & Peace declearation
	if(order.proxyType == "GameOrderPlayCardSpy")then
		
	end
end
function Server_AdvanceTurn_End (game,addNewOrder)
	--add new Allys
	--add new war decleartions
	if(RemainingDecerations ~= nil)then
		for _,P1 in pairs(RemainingDeclerations)do
			for _,P2 in pairs(P1)do
				if(RemainingDeclerations[P1][P2] == true)then
					War[P1][P2] = true;
					addNewOrder(WL.GameOrderEvent.Create(order.From, "The Player with the player ID " ..P1 .. " decleared war on " .. P2, nil, {}));
				end
			end
		end
	end
	if(Mod.Settings.SeeAllyTerritories)then
		--play on every ally a spy card
	end
end
function RemoveAlly(Player1,Player2)
end
function RemoveWar(Player1,Player2)
end
function DeclearWar(Player1,Player2)
	if(IsAlly(Player1,Player2)==false)then
		if(RemainingDeclerations == nil)then
			RemainingDeclerations = {{}};
		end
		local newstate = {};
		if(RemainingDeclerations[Player1] ~= nil)then
			for _,P2 in pairs(RemainingDeclerations[Player1])do
				newstate[P2] = true;	
			end
		end
		newstate[Player2] = true;
		RemainingDeclerations[Player1] = newstate;
	else
		RemoveAlly(Player1,Player2);
	end
end
function InWar(Player1,Player2)
	if(War == nil)then
		War = {{}};
	end
	if(War[Player1][Player2])then
		return true;
	end
	return false;
end
function DeclearAlly(Player1,Player2)
	
end
function IsAlly(Player1,Player2)
	return false;
end
function tablelength(T)
	local count = 0;
	for _,elem in pairs(T)do
		count = count + 1;
	end
	return count;
end