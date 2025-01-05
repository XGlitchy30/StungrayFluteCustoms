--[[
Hieratic Dragon of Sekh
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--[[If a "Hieratic" monster you control is Tributed (except during the Damage Step): You can Special Summon this card from your Pendulum Zone.]]
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1:SetCode(EVENT_RELEASE)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT()
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--[[If this card is in your hand or GY: You can detach 1 material from a Dragon Xyz Monster you control; Special Summon this card, but banish it when it leaves the field.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(nil,s.spcost2,s.sptg,s.spop2)
	c:RegisterEffect(e2)
	--[[(Quick Effect): You can target 1 "Hieratic" monster you control; Tribute 1 other "Hieratic" monster from your hand or field, and if you do, that target gains 1000 ATK.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_RELEASE|CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetFunctions(aux.dscon,nil,s.atktg,s.atkop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_HIERATIC}

--E1
function s.spcfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(SET_HIERATIC)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.spcfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_DRAGON)
end
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST,g) end
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST,g)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E3
function s.rlfilter(c)
	return (c:IsMonster() or c:IsLocation(LOCATION_MZONE)) and c:IsSetCard(SET_HIERATIC) and c:IsReleasableByEffect()
end
function s.atkfilter(c,rg)
	return c:IsFaceup() and c:IsSetCard(SET_HIERATIC) and rg:IsExists(aux.TRUE,1,c)
end
function s.stardustCheck(c)
	if c:IsOnField() then return false end
	return not c:IsPublic() or (c:IsMonster() and c:IsSetCard(SET_HIERATIC) and c:IsReleasableByEffect())
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local rg=Duel.GetReleaseGroup(tp,true,false,REASON_EFFECT):Filter(s.rlfilter,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc,rg) end
	if chk==0 then return #rg>0 and Duel.IsExists(true,s.atkfilter,tp,LOCATION_MZONE,0,1,nil,rg) end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil,rg)
	if rg:IsExists(s.stardustCheck,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
	else
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,rg,1,tp,LOCATION_HAND|LOCATION_MZONE)
	end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,tp,1000)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local rg=Duel.GetReleaseGroup(tp,true,false,REASON_EFFECT):Filter(s.rlfilter,aux.ExceptThis(tc))
	if #rg==0 then return end
	Duel.HintMessage(tp,HINTMSG_RELEASE)
	local rsg=rg:Select(tp,1,1,nil)
	if #rsg>0 then
		local rc=rsg:GetFirst()
		if rc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,rg)
		else
			Duel.HintSelection(rg)
		end
		if Duel.Release(rsg,REASON_EFFECT) and tc:IsRelateToChain() and tc:IsFaceup() and tc:IsControler(tp) and tc:IsSetCard(SET_HIERATIC) then
			tc:UpdateATK(1000,true,{e:GetHandler(),true})
		end
	end
end