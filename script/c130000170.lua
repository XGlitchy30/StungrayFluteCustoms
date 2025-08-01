--[[
Vixen Brew - Flummoxing Flask
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If you control a Spellcaster monster: Choose 1 face-up card your opponent controls and apply 1 of these effects.
	● If the chosen card is a monster, change it to face-down Defense Position.
	● If the chosen card is a Spell/Trap, Set it (if possible). Otherwise, after activation, Set it face-down instead of sending it to the GY.
	● If this card was Set before activation, and is on the field at resolution, negate the chosen card's effects until the end of this turn.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_POSITION|CATEGORY_DISABLE)
	e1:SetCustomCategory(CATEGORY_SET_SPELLTRAP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetFunctions(
		xgl.LocationGroupCond(s.cfilter,LOCATION_MZONE,0,1),
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
end

--E1
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
function s.filter(c,pos)
	return c:IsFaceup()
		and ((c:IsLocation(LOCATION_MZONE) and c:IsCanTurnSet())
		or (c:IsSpellTrapOnField() and c:IsSSetable(true))
		or (pos and c:IsNegatable()))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local pos=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsStatus(STATUS_ACT_FROM_HAND) and c:IsLocation(LOCATION_SZONE) and c:IsFacedown() and POS_FACEDOWN or 0
		return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,1,nil,pos)
	end
	local pos=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsStatus(STATUS_ACT_FROM_HAND) and e:GetActivateLocation()&LOCATION_SZONE>0 and c:IsPreviousPosition(POS_FACEDOWN) and POS_FACEDOWN or 0
	Duel.SetTargetParam(pos)
	local cat = pos~=0 and CATEGORY_POSITION|CATEGORY_DISABLE or CATEGORY_POSITION
	e:SetCategory(cat)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
	Duel.SetPossibleCustomOperationInfo(0,CATEGORY_SET_SPELLTRAP,nil,1,1-tp,LOCATION_ONFIELD)
	if pos~=0 then
		Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local pos=Duel.GetTargetParam()
	local g=Duel.Select(HINTMSG_FACEUP,false,tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil,pos)
	if Duel.Highlight(g) then
		local tc=g:GetFirst()
		local b1=tc:IsLocation(LOCATION_MZONE) and tc:IsCanTurnSet()
		local b2=tc:IsSpellTrapOnField() and tc:IsSSetable(true)
		local b3=pos==POS_FACEDOWN and tc:IsNegatable() and tc:IsCanBeDisabledByEffect(e)
		local opt=Duel.SelectEffect(tp,{b1,STRING_CHANGE_POSITION},{b2,STRING_SET_SPELLTRAP},{b3,STRING_DISABLE})
		if opt==1 then
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		elseif opt==2 then
			if tc:IsStatus(STATUS_LEAVE_CONFIRMED) then
				tc:CancelToGrave()
			end
			Duel.ChangePosition(tc,tc:IsLocation(LOCATION_MZONE) and POS_FACEDOWN_DEFENSE or POS_FACEDOWN)
			Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
		elseif opt==3 then
			Duel.Negate(tc,e,RESET_PHASE|PHASE_END)
		end
	end
end