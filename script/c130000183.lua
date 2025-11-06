--[[
Orea Arbor, the Sylvan Spirit Speaker
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--3 Level 7 Plant monsters
	--Once per turn, you can also Xyz Summon "Orea Arbor, the Sylvan Spirit Speaker" by using a "Sylvan" Xyz Monster you control with no materials as material.
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PLANT),7,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
	--Must be Xyz Summoned.
	c:AddMustBeXyzSummoned()
	--If you control "Mount Sylvania": You can detach 1 material from this card; excavate cards from the top of your Deck until you reveal a Plant monster, send it to the GY and add any excavated "Sylvan" Spell/Traps to your hand, also place the rest on the bottom of the Deck in any order, also you cannot Special Summon monsters, except "Sylvan" monsters, for the rest of this turn.
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(id,1)
    e1:SetCategory(CATEGORY_DECKDES|CATEGORIES_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:HOPT()
    e1:SetFunctions(
		xgl.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_MOUNT_SYLVANIA),LOCATION_ONFIELD,0,1),
		Cost.DetachFromSelf(1,1,nil),
		s.target,
		s.operation
	)
    c:RegisterEffect(e1)
end
s.listed_names={id,CARD_MOUNT_SYLVANIA}
s.listed_series={SET_SYLVAN}

function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp) and c:IsSetCard(SET_SYLVAN,lc,SUMMON_TYPE_XYZ,tp) and c:GetOverlayCount()==0
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	return true
end

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_DECK,0,1,nil,RACE_PLANT)
	end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.stfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(SET_SYLVAN)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerCanDiscardDeck(tp,1) then
		local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_DECK,0,nil,RACE_PLANT)
		local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		local seq=-1
		local sc=nil
		for tc in g:Iter() do
			if tc:GetSequence()>seq then
				seq=tc:GetSequence()
				sc=tc
			end
		end
		
		local sortct=0
		if seq==-1 then
			Duel.ConfirmDecktop(tp,dcount)
			Duel.SortDeckbottom(tp,tp,dcount)
		else
			Duel.ConfirmDecktop(tp,dcount-seq)
			local dg=Duel.GetDecktopGroup(tp,dcount-seq)
			local xg=dg:Filter(s.stfilter,nil)
			if sc:IsAbleToGrave() and (#xg==0 or xg:IsExists(Card.IsAbleToHand,1,nil)) then
				Duel.DisableShuffleCheck()
				if Duel.SendtoGraveAndCheck(sc,nil,REASON_EFFECT|REASON_EXCAVATE) then
					local tg=xg:Filter(Card.IsAbleToHand,nil)
					Duel.Search(tg,nil,REASON_EFFECT|REASON_EXCAVATE)
					Duel.ShuffleHand(tp)
				end
			end
			sortct=sortct+dg:FilterCount(aux.PLChk,nil,tp,LOCATION_DECK)
		end
		
		if sortct>0 then
			Duel.MoveToDeckBottom(sortct,tp)
			Duel.SortDeckbottom(tp,tp,sortct)
		end
	end
	
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(id,2)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not c:IsSetCard(SET_SYLVAN) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end