--[[
Dark Tidal King of Demonisu
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")

local FLAG_REGISTERED_FORCED_ATTACK = id+100

function s.initial_effect(c)
	c:EnableReviveLimit()
	--[[Must be Special Summoned by its own effect. You can Special Summon this card (from your hand) by sending 1 "Wave King of Demonisu" you control to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Once per turn: You can target 1 face-up monster your opponent controls; it must attack this card, if able.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:OPT()
	e3:SetFunctions(
		nil,
		nil,
		s.atktg,
		s.atkop
	)
	c:RegisterEffect(e3)
	--During the Battle Phase (Quick Effect): You can target 1 monster [on the field]; change its battle position.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,2)
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetHintTiming(0,TIMING_ATTACK)
	e4:SetFunctions(
		xgl.BattlePhaseCond(),
		nil,
		s.postg,
		s.posop
	)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_WAVE_KING_OF_DEMONISU}

--E2
function s.spfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_WAVE_KING_OF_DEMONISU) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST|REASON_SPSUMMON)
	g:DeleteGroup()
end

--E3
function s.filter(c,...)
	if not c:IsFaceup() then return false end
	local vals={...}
	if #vals==0 then return true end
	for _,v in ipairs(vals) do
		if c:HasFlagEffectLabel(id,v) then
			return false
		end
	end
	return true
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local vals={c:GetFlagEffectLabel(FLAG_REGISTERED_FORCED_ATTACK)}
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc,table.unpack(vals)) end
	if chk==0 then return Duel.IsExists(true,s.filter,tp,0,LOCATION_MZONE,1,nil,table.unpack(vals)) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,table.unpack(vals))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,3))
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetLabel(fid)
		e1:SetCondition(s.resetcon)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e2:SetValue(function(e,c) return c==e:GetOwner() and c:HasFlagEffectLabel(FLAG_REGISTERED_FORCED_ATTACK,fid) end)
		tc:RegisterEffect(e2)
		if not c:HasFlagEffectLabel(FLAG_REGISTERED_FORCED_ATTACK,fid) then
			c:RegisterFlagEffect(FLAG_REGISTERED_FORCED_ATTACK,RESET_EVENT|RESETS_STANDARD_FACEDOWN,0,1,fid)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_ADJUST)
			e3:SetLabel(fid)
			e3:SetCondition(s.resetcon2)
			e3:SetOperation(s.resetop2)
			Duel.RegisterEffect(e3,tp)
		end
	end
end
function s.resetcon(e)
	local c=e:GetOwner()
	if not c:HasFlagEffectLabel(FLAG_REGISTERED_FORCED_ATTACK,e:GetLabel()) then
		e:Reset()
		return false
	end
	return true
end
function s.resetcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	return not c:HasFlagEffectLabel(FLAG_REGISTERED_FORCED_ATTACK,e:GetLabel())
end
function s.resetop2(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local g=Duel.Group(Card.HasFlagEffectLabel,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,id,fid)
	for tc in aux.Next(g) do
		tc:GetFlagEffectWithSpecificLabel(id,fid,true)
	end
	e:Reset()
end

--E4
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end