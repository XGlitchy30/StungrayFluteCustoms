--[[
Opening Shop
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Add 1 "Flamespear" monster from your Deck to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetSearchFunctions(s.thfilter)
	c:RegisterEffect(e1)
	--During your turn, except the turn this card is sent to the GY: You can banish this card from your GY; Special Summon 1 Spellcaster monster from your hand, GY, or face-up Extra Deck, and if you do, send the top card of your Deck to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		aux.exccon,
		aux.bfgcost,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FLAMESPEAR}

--E1
function s.thfilter(c)
	return c:IsMonsterType() and c:IsSetCard(SET_FLAMESPEAR)
end

--E2
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and Duel.GetMZoneCountFromLocation(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.DiscardDeck(tp,1,REASON_EFFECT)
	end
end