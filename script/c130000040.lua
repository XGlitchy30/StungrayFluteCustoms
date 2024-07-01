--[[
Moblins' Confrontation
Card Author: Pretz
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Change the battle position of 1 "Moblins" monster you control; all other monsters currently on the field lose 600 ATK/DEF until the end of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantBattleTimings()
	e1:SetFunctions(aux.ExceptOnDamageCalc,aux.LabelCost,s.target,s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_MOBLINS}

--E1
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_MOBLINS) and c:IsCanChangePosition() and not c:IsHasEffect(EFFECT_CANNOT_USE_AS_COST)
		and Duel.IsExists(false,Card.IsCanChangeStats,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	local g=Duel.Select(HINTMSG_POSITION,false,tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	if #g>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if Duel.PositionChange(tc)>0 then
			return tc
		end
	end
	return
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetLabel()==1 and s.cost(e,tp,eg,ep,ev,re,r,rp,0)
	end
	e:SetLabel(0)
	local tc=s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.SetTargetCard(tc)
	local g=Duel.Group(Card.IsCanChangeStats,tp,LOCATION_MZONE,LOCATION_MZONE,tc)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,g,#g,PLAYER_ALL,LOCATION_MZONE,-600)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local g=Duel.Group(Card.IsCanChangeStats,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThis(tc))
	for sc in aux.Next(g) do
		sc:UpdateATKDEF(-600,-600,RESET_PHASE|PHASE_END,{c,true})
	end
end