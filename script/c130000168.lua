--[[
Vixen Brew - Bottle of Die-On-Me-Not
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Activate the following effect depending on if this card was Set before activation.
	● If yes: Special Summon 1 Spellcaster monster from your GY or face-up Extra Deck in Defense Position.
	● If no: Add 1 Spellcaster monster from your GY or face-up Extra Deck to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
end

--E1
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and Duel.GetMZoneCountFromLocation(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local actchk=e:IsHasType(EFFECT_TYPE_ACTIVATE)
	if chk==0 then
		if not actchk then return false end
		local pos=not c:IsStatus(STATUS_ACT_FROM_HAND) and c:IsLocation(LOCATION_SZONE) and c:IsFacedown() and POS_FACEDOWN or 0
		local f = pos~=0 and s.spfilter or s.thfilter
		return Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,e,tp)
	end
	local pos=not c:IsStatus(STATUS_ACT_FROM_HAND) and e:GetActivateLocation()&LOCATION_SZONE>0 and c:IsPreviousPosition(POS_FACEDOWN) and POS_FACEDOWN or 0
	Duel.SetTargetParam(pos)
	local cat = pos~=0 and CATEGORY_SPECIAL_SUMMON or CATEGORY_TOHAND
	e:SetCategory(cat)
	Duel.SetOperationInfo(0,cat,nil,1,tp,LOCATION_GRAVE|LOCATION_EXTRA)
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,pos~=0 and 1 or 2))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local pos=Duel.GetTargetParam()
	if pos~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.Necro(s.spfilter),tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.Necro(s.thfilter),tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil)
		if #g>0 then
			Duel.Search(g)
		end
	end
end