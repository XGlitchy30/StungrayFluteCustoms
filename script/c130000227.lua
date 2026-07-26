--[[
Sconvolgimento
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Target 1 face-up monster your opponent controls; this turn, your opponent must pay 700 LP to declare an attack with that monster or activate that monster's effects. During the End Phase, if your opponent paid 2000 or more LP this turn, destroy that monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--Track payment
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PAY_LPCOST)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s[0]=0
			s[1]=0
		end)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	s[ep]=s[ep]+ev
end

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then
		return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local c=e:GetHandler()
		local eid=e:GetFieldID()
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,eid,aux.Stringid(id,1))
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_ACTIVATE_COST)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetLabel(eid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.costcon)
		e1:SetCost(s.costchk)
		e1:SetTarget(s.costtg)
		e1:SetOperation(s.costop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_UNCOPYABLE)
		e2:SetCode(EFFECT_ATTACK_COST)
		e2:SetLabel(1-tp)
		e2:SetCondition(s.atcon)
		e2:SetCost(s.costchk)
		e2:SetOperation(s.atop)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2,true)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(id)
		e3:SetLabel(eid)
		e3:SetLabelObject(tc)
		e3:SetTargetRange(0,1)
		e3:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e3,tp)
		--During this End Phase, if your opponent paid 2000 or more LP this turn, destroy that monster.
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(id,2)
		e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE|PHASE_END)
		e4:OPT()
		e4:SetLabel(eid)
		e4:SetLabelObject(tc)
		e4:SetCondition(s.descon)
		e4:SetOperation(s.desop)
		e4:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e4,tp)
	end
end
function s.costcon(e)
	local eid=e:GetLabel()
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffectLabel(id,eid) then
		e:Reset()
		return false
	end
	return true
end
function s.costchk(e,te_or_c,tp)
	local ct=0
	for _,ce in ipairs({Duel.GetPlayerEffect(tp,id)}) do
		local tc=ce:GetLabelObject()
		if tc and tc:HasFlagEffectLabel(ce:GetLabel()) then
			ct=ct+1
		else
			ce:Reset()
		end
	end
	return Duel.CheckLPCost(tp,ct*700)
end
function s.costtg(e,te,tp) 
	return te:IsMonsterEffect() and te:GetHandler()==e:GetLabelObject()
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,700)
end

function s.atcon(e)
	return e:GetHandler():IsControler(e:GetLabel())
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsAttackCostPaid()~=2 and e:GetHandler():IsLocation(LOCATION_MZONE) then
		Duel.PayLPCost(tp,700)
		Duel.AttackCostPaid()
	end
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	if not s.costcon(e) then return false end
	return s[1-tp]>=2000
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local eid=e:GetLabel()
	local tc=e:GetLabelObject()
	if tc and tc:HasFlagEffectLabel(id,eid) then
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.Destroy(tc,REASON_EFFECT)
	end
end