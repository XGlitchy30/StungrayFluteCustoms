--[[
Wrath of Memories
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:Activation(nil,{TIMING_STANDBY_PHASE,0})
	--You can only control 1 "Wrath of Memories".
	c:SetUniqueOnField(1,0,id)
	--During your Standby Phase: Banish 1 monster from your GY, then target 1 face-up monster the on the field; the monster on the field gains ATK equal to half the banished monster's ATK until the end of this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetRange(LOCATION_SZONE)
	e1:OPT()
	e1:SetFunctions(
		xgl.TurnPlayerCond(0),
		xgl.DummyCost,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
end
s.listed_names={id}

--E1
function s.cfilter(c)
	return c:GetAttack()>0 and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then
		return e:IsCostChecked() and Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil)
	end
	local v=0
	local tc=Duel.Select(HINTMSG_REMOVE,false,tp,s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc then
		v=math.floor(tc:GetAttack()/2 + 0.5)
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	end
	Duel.SetTargetParam(v)
	local g=Duel.Select(HINTMSG_ATKDEF,true,tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,v)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsFaceup() then
		local v=Duel.GetTargetParam()
		tc:UpdateATK(v,RESET_PHASE|PHASE_END,{e:GetHandler(),true})
	end
end