--[[
Cavalcare le Rapide
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchylib_delayed_event.lua")

if not Kappa then
	Kappa = {}
	Duel.LoadScript("glitchylib_archetypes.lua",false)
end

function s.initial_effect(c)
	--You can only control 1 "Ride the Rapids".
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_CARD_TARGET)
	e0:SetHintTiming(TIMING_DAMAGE_STEP|TIMING_SUMMON|TIMING_SPSUMMON|TIMING_FLIPSUMMON,TIMING_DAMAGE_STEP|TIMING_SUMMON|TIMING_SPSUMMON|TIMING_FLIPSUMMON)
	e0:SetCondition(aux.StatChangeDamageStepCondition)
	c:RegisterEffect(e0)
	--"Kappa" monsters you control gain 200 ATK/DEF.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsKappa))
	e1:SetValue(200)
	c:RegisterEffect(e1)
	e1:UpdateDefenseClone(c)
	--Trigger Effect management
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON|CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.efftg,s.effop)
	c:RegisterEffect(e2)
	--Register events
	local reg1=aux.RegisterMergedDelayedEventGlitchy(c,id,{EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS,EVENT_FLIP},s.cfilter,s.flagid,nil,nil,nil,s.flagop,nil,nil,nil,true)
end
s.listed_names={id}
s.listed_series={SET_KAPPA}
s.lists_kappa_monster=true

function s.cfilter(c)
	return c:IsFaceup() and c:IsKappa()
end
function s.flagid(event,c,e,tp,eg,ep,ev,re,r,rp)
	if not c then
		return id,id+100
	end
	if event==EVENT_FLIP then
		return id+100
	end
	return id
end
function s.flagop(e,tp,eg,ep,ev,re,r,rp,obj,event,updatedEventID)
	local v=0
	if eg:IsExists(Card.HasFlagEffect,1,nil,id) then
		v=v|1
	end
	if eg:IsExists(Card.HasFlagEffect,1,nil,id+100) then
		v=v|2
	end
	return v
end

--
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local opt=Duel.GetTargetParam()
		if opt==0 then
			return s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		else
			return s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		end
	end

	local label=ev
	----If a "Kappa" monster(s) is Normal or Special Summoned (except during the Damage Step): You can target 1 "Kappa" monster in your GY; add it to your hand.
	local b1 = label&1==1 and s.thtg(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.IsPhase(PHASE_DAMAGE)
	----If a "Kappa" monster(s) is flipped face-up, even during the Damage Step: You can target 1 "Kappa" monster in your GY; Special Summon it in face-down Defense Position.
	local b2 = label&2==2 and s.sptg(e,tp,eg,ep,ev,re,r,rp,0)

	if chk==0 then
		return b1 or b2
	end
	local opt=0
	if b1 and b2 then
		opt=xgl.Option(id,tp,1,b1,b2)+1
	elseif b1 then
		opt=1
	elseif b2 then
		opt=2
	end
	Duel.SetTargetParam(opt)
	if opt==1 then
		e:SetCategory(CATEGORY_TOHAND)
		s.thtg(e,tp,eg,ep,ev,re,r,rp,chkc)
	elseif opt==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_SET)
		s.sptg(e,tp,eg,ep,ev,re,r,rp,chkc)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if opt==1 then
		return s.thop(e,tp,eg,ep,ev,re,r,rp)
	elseif opt==2 then
		return s.spop(e,tp,eg,ep,ev,re,r,rp)
	end
end

--E2
function s.thfilter(c)
	return c:IsMonster() and c:IsKappa() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_ATOHAND,true,tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Search(tc)
	end
end

--E3
function s.spfilter(c,e,tp)
	return c:IsKappa() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
	Duel.SetCardOperationInfo(g,CATEGORY_SET)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		Duel.ConfirmCards(1-tp,tc)
	end
end