--[[
Hieratic Dragon King of Hor
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 Level 6 Dragon monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),6,2)
	--[[If you Summon a Normal Monster(s) to your field (except during the Damage Step): You can draw 1 card]]
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_PLAYER_TARGET,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT(nil,3)
	e1:SetFunctions(
		s.drawcon,
		nil,
		xgl.DrawTarget(0,1),
		xgl.DrawOperation()
	)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	e1:FlipSummonEventClone(c)
	--[[You can either detach 1 material from this card, or Tribute 1 monster from your hand or field, then target 1 monster your opponent controls; destroy it. If you Tributed a monster to activate
	this effect, the destroyed monster's effects are negated in the GY.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(nil,s.descost,s.destg,s.desop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end

--E1
function s.spcfilter(c,tp)
	return c:IsControler(tp) and c:IsSummonPlayer(tp) and c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.spcfilter,1,nil,tp)
end

--E2
function s.rlfilter(c)
	return c:IsMonsterType() and c:IsReleasable()
end
function s.rlcheck(sg,tp,exg)
	return Duel.IsExists(true,aux.TRUE,tp,0,LOCATION_MZONE,1,sg)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Cost.Detach(1,1,nil)(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=Duel.CheckReleaseGroupCost(tp,s.rlfilter,1,true,s.rlcheck,nil)
	if b2 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	if chk==0 then return b1 or b2 end
	local opt=xgl.Option(tp,nil,nil,{b1,STRING_DETACH},{b2,STRING_RELEASE})
	Duel.SetTargetParam(opt)
	if opt==0 then
		Cost.Detach(1,1,nil)(e,tp,eg,ep,ev,re,r,rp,chk)
	elseif opt==1 then
		local g=Duel.SelectReleaseGroupCost(tp,s.rlfilter,1,1,true,s.rlcheck,nil)
		Duel.Release(g,REASON_COST)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local isCostChecked=e:GetLabel()==1
		e:SetLabel(0)
		return isCostChecked or Duel.IsExists(true,aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	end
	e:SetLabel(0)
	local g=Duel.Select(HINTMSG_DESTROY,true,tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) and tc:IsMonsterType() and e:IsActivated() and Duel.GetTargetParam()==1 then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
end