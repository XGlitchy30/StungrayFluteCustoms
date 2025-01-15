--[[
Legion Queltz
Card Author: LimitlessSocks
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--3 Level 3 monsters
	--[[Once per turn, you can also Xyz Summon "Legion Queltz" by revealing 1 "Queltz" card in your hand, then using 1 Normal Summoned monster, or 1 Ritual Monster, you control as material.]]
	Xyz.AddProcedure(c,nil,3,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
	--[[You cannot Special Summon monsters from the Extra Deck the turn you Special Summon this card, except FIRE Thunder monsters.]]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetCost(function(_,_,tp) return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end)
	e0:SetOperation(s.spcostop)
	c:RegisterEffect(e0)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	--[[If you control no other monsters: You can target 1 banished card; attach it to this card as material.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,2)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetFunctions(s.condition,xgl.InfoCost,s.target,s.operation)
	c:RegisterEffect(e1)
	--[[You can detach 1 material from this card; add 1 "Queltz" Ritual Monster from your Deck to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCost(xgl.CreateCost(xgl.InfoCost,xgl.DetachSelfCost()))
	e2:SetSearchFunctions(s.thfilter)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={SET_QUELTZ}

function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and (c:IsRitualMonster() or c:IsSummonType(SUMMON_TYPE_NORMAL))
end
function s.rvfilter(c)
	return c:IsSetCard(SET_QUELTZ) and not c:IsPublic()
end
function s.xyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) and Duel.IsExists(false,s.rvfilter,tp,LOCATION_HAND,0,1,nil) end
	local g=Duel.Select(HINTMSG_CONFIRM,false,tp,s.rvfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.BreakEffect()
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	return true
end

--E0
function s.counterfilter(c)
	return not (c:IsSummonLocation(LOCATION_EXTRA) and (c:IsFacedown() or not c:IsAttributeRace(ATTRIBUTE_FIRE,RACE_THUNDER)))
end
function s.spcostop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_OATH|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsAttributeRace(ATTRIBUTE_FIRE,RACE_THUNDER) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsOriginalAttributeRace(ATTRIBUTE_FIRE,RACE_THUNDER) end)
end

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_MZONE) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsCanBeAttachedTo(c,e) end
	if chk==0 then return c:IsType(TYPE_XYZ) and Duel.IsExistingTarget(Card.IsCanBeAttachedTo,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,c,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.SelectTarget(tp,Card.IsCanBeAttachedTo,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,c,e)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() then
		Duel.Attach(tc,c,false,e)
	end
end

--E2
function s.thfilter(c)
	return c:IsRitualMonster() and c:IsSetCard(SET_QUELTZ)
end