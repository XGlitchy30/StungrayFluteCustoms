--[[
Counterlunge
Card Author: Pretz
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[During the Battle Phase: Target 1 face-up monster you control; it cannot be targeted or destroyed by card effects until the end of the next Damage Step,
	then, if this card was Set by a card effect before activation, it gains 2000 ATK until the end of the next Damage Step.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantBattleTimings()
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		--Register flag if Set by a card effect
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_SSET)
		ge:SetOperation(s.operation)
		Duel.RegisterEffect(ge,0)
	end)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	for ec in eg:Iter() do
		local reason=ec:GetReason()
		if reason==0 or reason&REASON_EFFECT==REASON_EFFECT then
			ec:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
		end
	end
end

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase() and xgl.ExceptOnDamageCalc() and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or e:GetHandler():HasFlagEffect(id))
end
function s.thfilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if c:HasFlagEffect(id) then
		e:SetCategory(CATEGORY_ATKCHANGE)
		Duel.SetTargetParam(1)
		if tc:IsCanChangeATK() then
			local p,loc=tc:GetResidence()
			Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,p,loc,2000)
		end
	else
		e:SetCategory(0)
		Duel.SetTargetParam(0)
	end 
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local c=e:GetHandler()
		local eset={}
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_CANNOT_BE_DESTROYED_OR_TARGETED_BY_EFFECTS)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(1)
		local reg1=tc:RegisterEffect(e1)
		if reg1 then
			table.insert(eset,e1)
		end
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		local reg2=tc:RegisterEffect(e2)
		if reg2 then
			table.insert(eset,e2)
		end
		if reg1 and reg2 and not tc:IsImmuneToEffect(e1) and not tc:IsImmuneToEffect(e2) and tc:IsRelateToChain() and tc:IsFaceup() and Duel.GetTargetParam()==1 then
			local e3,_,reg3=tc:UpdateATK(2000,0,{c,true})
			if reg3 then
				table.insert(eset,e3)
			end
		end
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DAMAGE_STEP_END)
		e3:SetOperation(s.resetop)
		e3:SetLabelObject(eset)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local eset=e:GetLabelObject()
	for _,eff in ipairs(eset) do
		eff:Reset()
	end
	e:Reset()
end