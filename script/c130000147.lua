--[[
Ancestagon Frenzy
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[During your turn: Apply 1 of these effects, depending on the current Phase.
	● Main Phase 1: Reveal 2 "Ancestagon" Pendulum Monsters from your Deck, your opponent randomly picks 1 of them for you to place in your Pendulum Zone or Special Summon (your choice), and you add the other card to your Extra Deck face-up.
	● Main Phase 2: Place 1 or 2 "Ancestagon" Pendulum Monster(s) from your Deck in your Pendulum Zone.
	You can only activate 1 "Ancestagon Frenzy" per turn, also you cannot Special Summon Dinosaur monsters the Duel you activate this card, except "Ancestagon" monsters.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOEXTRA)
	e1:SetCustomCategory(CATEGORY_PLACE_IN_PZONE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_MAIN_END,0)
	e1:HOPT(true)
	e1:SetFunctions(
		xgl.TurnPlayerCond(0),
		xgl.SSRestrictionCost(s.excfilter,true,0,id,nil,1,nil,nil,s.lizardCheck),
		s.target,
		s.activate,
		s.zones
	)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ANCESTAGON}

function s.excfilter(c)
	return not c:IsRace(RACE_DINOSAUR) or c:IsSetCard(SET_ANCESTAGON)
end
function s.lizardCheck(_,c)
	return not c:IsOriginalRace(RACE_DINOSAUR) or c:IsOriginalSetCard(SET_ANCESTAGON)
end

--E1
function s.filter(c,e,tp,pzchk,ftchk,techk)
	return c:IsSetCard(SET_ANCESTAGON) and c:IsType(TYPE_PENDULUM)
		and ((pzchk and c:IsCanBePlacedInPZone(e,tp)) or (ftchk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
		and (not techk or c:IsAbleToExtraFaceup(e,tp))
end
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0x1f
	local p0,p1=Duel.CheckLocation(tp,LOCATION_PZONE,0),Duel.CheckLocation(tp,LOCATION_PZONE,1)
	local spchk=Duel.GetCurrentPhase()==PHASE_MAIN1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,2,nil,e,tp,false,true,true)
	if p0==p1 or spchk then
		return zone
	elseif p0 then
		return zone&~0x1
	elseif p1 then
		return zone&~0x10
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ph=Duel.GetCurrentPhase()
	local pzchk=Duel.CheckPendulumZones(tp)
	local ftchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b1 = ph==PHASE_MAIN1 and (pzchk or ftchk) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,2,nil,e,tp,pzchk,ftchk,true)
	local b2 = ph==PHASE_MAIN2 and pzchk and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,true,false,false)
	if chk==0 then
		return b1 or b2
	end
	Duel.SetConditionalCustomOperationInfo(b2,0,CATEGORY_PLACE_IN_PZONE,nil,1,tp,LOCATION_DECK)
	Duel.SetConditionalOperationInfo(b1,0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	local pzchk=Duel.CheckPendulumZones(tp)
	local ftchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b1 = ph==PHASE_MAIN1 and (pzchk or ftchk) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,2,nil,e,tp,pzchk,ftchk,true)
	local b2 = ph==PHASE_MAIN2 and pzchk and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,true,false,false)
	if b1 then
		local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp,pzchk,ftchk,true)
		if #g1<2 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg1=g1:Select(tp,2,2,nil)
		Duel.ConfirmCards(1-tp,sg1)
		local tc=sg1:RandomSelect(1-tp,1):GetFirst()
		Duel.Hint(HINT_CARD,0,tc:GetCode())
		local opt=Duel.SelectEffect(tp,
			{pzchk and tc:IsCanBePlacedInPZone(e,tp), STRING_PLACE_IN_PZONE},
			{ftchk and tc:IsCanBeSpecialSummoned(e,0,tp,false,false), STRING_SPECIAL_SUMMON}
		)
		if opt==1 then
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		elseif opt==2 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
		sg1:RemoveCard(tc)
		Duel.SendtoExtraP(sg1,nil,REASON_EFFECT)
		
	elseif b2 then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp,true,false,false)
		local ct=0
		for i=0,1 do
			if Duel.CheckLocation(tp,LOCATION_PZONE,i) then ct=ct+1 end
		end
		if ct>0 and #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local sg=g:Select(tp,1,ct,nil)
			local sc=sg:GetFirst()
			for sc in sg:Iter() do
				Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end
	end
end