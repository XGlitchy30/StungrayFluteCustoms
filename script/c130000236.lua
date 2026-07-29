--[[
Fiume
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")

if not Kappa then
	Kappa = {}
	Duel.LoadScript("glitchylib_archetypes.lua",false)
end

function s.initial_effect(c)
	c:Activation()
	--You can only control 1 "River".
	c:SetUniqueOnField(1,0,id)
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
	--Any battle damage you would take from attacks involving your "Kappa" monsters is halved.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsKappa))
	e2:SetValue(aux.ChangeBattleDamage(0,HALF_DAMAGE))
	c:RegisterEffect(e2)
	--If a "Kappa" monster(s) is Normal or Special Summoned (except during the Damage Step): You can target 1 face-up monster your opponent controls; it loses 200 ATK/DEF.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,0)
	e3:SetCategory(CATEGORIES_ATKDEF)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetFunctions(s.statscon,nil,s.statstg,s.statsop)
	c:RegisterEffect(e3)
	e3:SpecialSummonEventClone(c)
end
s.listed_names={id}
s.listed_series={SET_KAPPA}
s.lists_kappa_monster=true

--E3
function s.cfilter(c)
	return c:IsFaceup() and c:IsKappa()
end
function s.statscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.statstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then
		return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end
	local g=Duel.Select(HINTMSG_ATKDEF,true,tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,-200)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,tp,-200)
end

function s.statsop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		tc:UpdateATKDEF(-200,-200,true,{e:GetHandler(),true})
	end
end