--[[
Queltz Paranoia
Card Author: LimitlessSocks
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Declare different card names, up to twice the number of "Queltz" Ritual Monsters you control; for each of those declared card names, your opponent must reveal and banish 1 copy of that card
	from their Deck, face-down, if possible. Then, for each declared card they did not banish from their Deck, you must banish the top 3 cards of your Deck, face-down.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_MAIN_END|TIMING_END_PHASE)
	e1:HOPT(true)
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
end
s.listed_series={SET_QUELTZ}

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsRitualMonster() and c:IsSetCard(SET_QUELTZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		local rg=Duel.GetDecktopGroup(tp,3)
		return #g>0
			and (Duel.IsExists(false,Card.IsAbleToRemove,tp,0,LOCATION_DECK,1,nil,1-tp,POS_FACEDOWN,REASON_RULE) or rg:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN,REASON_RULE)==3)
	end
	e:SetLabel(0)
	s.announce_filter={}
	local announcedNames={}
	local i=0
	local max=2*#g
	while i<max do
		i=i+1
		local ac=0
		if #s.announce_filter==0 then
			ac=Duel.AnnounceCard(tp)
		else
			ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
		end
		table.insert(announcedNames,ac)
		table.insert(s.announce_filter,ac)
		table.insert(s.announce_filter,OPCODE_ISCODE)
		table.insert(s.announce_filter,OPCODE_NOT)
		if i>1 then
			table.insert(s.announce_filter,OPCODE_AND)
		end
		if i<max and not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			i=max
		end
	end
	e:SetLabel(table.unpack(announcedNames))
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_EITHER,LOCATION_DECK)
	if #announcedNames==1 then
		Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local announcedNames={e:GetLabel()}
	local ct=0
	for _,code in ipairs(announcedNames) do
		Duel.Hint(HINT_CARD,0,code)
		local tc=Duel.Select(HINTMSG_REMOVE,false,1-tp,s.rmfilter,tp,0,LOCATION_DECK,1,1,nil,1-tp,code):GetFirst()
		if tc then
			Duel.ConfirmCards(tp,tc)
			Duel.Remove(tc,POS_FACEDOWN,REASON_RULE,PLAYER_NONE,1-tp)
		else
			ct=ct+1
		end
	end
	if ct>0 then
		local g=Duel.GetDecktopGroup(tp,ct*3)
		if #g>0 then
			Duel.DisableShuffleCheck()
			Duel.BreakEffect()
			Duel.Remove(g,POS_FACEDOWN,REASON_RULE)
		end
	end
end
function s.rmfilter(c,p,code)
	return c:IsCode(code) and c:IsAbleToRemove(p,POS_FACEDOWN,REASON_RULE)
end