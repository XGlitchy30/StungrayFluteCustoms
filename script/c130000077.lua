--[[
The Wanderer in Linaan
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If this card is Normal Summoned: You can Set 1 "Motherhood" Trap from your Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetSSetFunctions(nil,nil,s.setfilter,LOCATION_DECK,0,1,1,nil)
	c:RegisterEffect(e1)
	--[[If this card is in your GY, and you control no monsters: You can activate this effect; during your End Phase of this turn, send 1 Psychic monster from your Deck to the GY, but it cannot
	activate effects in the GY this turn, and if you do, Special Summon this card from your GY]]
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MOTHERHOOD}

--E1
function s.setfilter(c)
	return c:IsTrapType() and c:IsSetCard(SET_MOTHERHOOD)
end

--E2
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetTurnPlayer()==tp end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()~=tp then return end
	local c=e:GetHandler()
	local ac=(c:IsRelateToChain() and c:IsControler(tp)) and c or nil
	xgl.DelayedOperation(ac,PHASE_END,id,e,tp,s.delayedop,s.delayedcond,nil,nil,aux.Stringid(id,2),aux.Stringid(id,3))
end
function s.delayedcond(ag,e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.delayedop(ag,e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Hint(HINT_CARD,tp,id)
		if Duel.SendtoGraveAndCheck(g) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(STRING_CANNOT_TRIGGER)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD_PHASE_END)
			g:GetFirst():RegisterEffect(e1)
			if ag and #ag>0 then
				local c=ag:GetFirst()
				if c:HasFlagEffectLabel(id,e:GetLabel()) and Duel.GetMZoneCount(tp)>0 then
					Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
function s.tgfilter(c)
	return c:IsMonsterType() and c:IsRace(RACE_PSYCHIC) and c:IsAbleToGrave()
end