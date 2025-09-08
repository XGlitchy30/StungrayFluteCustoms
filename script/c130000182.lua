--[[
Sylvan Honeybelle
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--If you control a "Sylvan" monster: You can Special Summon this card from your hand, and if you do, you can excavate the top card of your Deck, and if it is a Plant monster, send it to the GY. Otherwise, place it on the bottom of your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		xgl.LocationGroupCond(aux.FaceupFilter(Card.IsSetCard,SET_SYLVAN),LOCATION_MZONE,0,1),
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--If this card is excavated from the Deck and sent to the GY by a card effect: You can Special Summon 1 "Sylvan" monster from your hand.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.spcon)
	e2:SetSpecialSummonFunctions(nil,nil,xgl.ArchetypeFilter(SET_SYLVAN),LOCATION_HAND,0,1,1,nil)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SYLVAN}

--E1
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.SelectYesNo(tp,STRING_ASK_EXCAVATE) then
		Duel.ConfirmDecktop(tp,1)
		local g=Duel.GetDecktopGroup(tp,1)
		local tc=g:GetFirst()
		if tc:IsRace(RACE_PLANT) then
			Duel.DisableShuffleCheck()
			Duel.SendtoGrave(g,REASON_EFFECT|REASON_EXCAVATE)
		else
			Duel.MoveSequence(tc,1)
		end
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_EXCAVATE) and c:IsReason(REASON_EFFECT)
end