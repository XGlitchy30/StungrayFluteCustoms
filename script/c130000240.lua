--[[
Comandante Cristallo
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchymods_cardstats.lua")
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--If a "Crystal Beast" monster you control would inflict battle damage to your opponent, and that damage would be less than 1000, it is doubled instead.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_CRYSTAL_BEAST))
	e1:SetValue(s.damval)
	c:RegisterEffect(e1)
	--If there are 2 or more face-up "Crystal" cards in your Spell & Trap Zones: You can Special Summon this card from your hand.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:HOPT()
	e2:SetCondition(s.spcon)
	e2:SetSpecialSummonSelfFunctions()
	c:RegisterEffect(e2)
	--[[If this card is destroyed in a Monster Zone: You can activate this effect; the next time a "Crystal Beast" monster(s) you control you be destroyed this turn, it is not destroyed, also place this card in your Pendulum Zone with the following effect.
	● This card is also always treated as a Continuous Spell.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCustomCategory(CATEGORY_PLACE_IN_PZONE)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:HOPT()
	e3:SetCondition(s.pzcon)
	e3:SetTarget(s.pztg)
	e3:SetOperation(s.pzop)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		xgl.EnableGlobalSavesForPreviousTypeOnField()
	end)
end
s.listed_series={SET_CRYSTAL_BEAST}

--E1
function s.damval(e,damp)
	if e:GetOwnerPlayer()==1-damp and Duel.GetBattleDamage(damp)<1000 then
		return DOUBLE_DAMAGE
	else
		return -1
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_CRYSTAL),tp,LOCATION_STZONE,0,2,nil)
end

--E3
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanBePlacedInPZone() and Duel.CheckPendulumZones(tp)
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_PLACE_IN_PZONE,c,1,tp,0)
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_CRYSTAL_BEAST))
	e1:SetValue(1)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if c:IsRelateToChain() and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) and c:IsLocation(LOCATION_PZONE) then
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(id,3)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetLabel(0)
		e2:SetCondition(s.typcon)
		e2:SetValue(s.typval)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
function s.typcon(e)
	return e:GetLabel()==0
end
function s.typval(e,c)
	e:SetLabel(1)
	local eset1={c:GetCardEffect(EFFECT_DISABLE)}
	c:AssumeProperty(ASSUME_TYPE,c:GetType()|TYPE_CONTINUOUS)
	local eset2={c:GetCardEffect(EFFECT_DISABLE)}
	e:SetLabel(0)
	Duel.AssumeReset()
	if #eset2>#eset1 then
		return 0
	end
	return TYPE_CONTINUOUS
end