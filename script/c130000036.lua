--[[
Moblins' Packmate
Card Author: Pretz
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchylib_normalsummon.lua")
function s.initial_effect(c)
	c:IsSummonableByOpponent()
	aux.RegisterSummonableByOpponentGlobalCheck(c)
	--[[At the start of the Battle Phase: You can reveal this card in your hand; immediately after this effect resolves, the turn player Normal Summons it to your field]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e1:SetRange(LOCATION_HAND)
	e1:OPT()
	e1:SetFunctions(nil,xgl.RevealSelfCost(),s.sumtg,s.sumop)
	c:RegisterEffect(e1)
	--[[If this card is Normal Summoned: You can send 1 other "Moblins" monster you control to the GY; this card cannot be destroyed this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetFunctions(
		nil,
		xgl.ToGraveCost(xgl.ArchetypeFilter(SET_MOBLINS),LOCATION_MZONE,0,1,1,true),
		nil,
		s.operation
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MOBLINS}

--E1
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local p=Duel.GetTurnPlayer()
		if p==tp then
			return c:IsSummonable(true,nil)
		else
			return c:HasFlagEffect(FLAG_SUMMONABLE_BY_OPPONENT)
		end
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SUMMON)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		local p=Duel.GetTurnPlayer()
		if p==tp then
			Duel.Summon(tp,c,true,nil)
		else
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(id,1)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SPSUM_PARAM)
			e2:SetCode(EFFECT_SUMMON_PROC)
			e2:SetTargetRange(POS_FACEUP_ATTACK,1)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e2)
			Duel.Summon(p,c,true,e2)
		end
	end
end

--E2
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		c:CannotBeDestroyed(1,nil,RESET_PHASE|PHASE_END)
	end
end