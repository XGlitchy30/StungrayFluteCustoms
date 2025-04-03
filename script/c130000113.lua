--[[
Dian Keto the Disco Master
Card Author: pretzelsnake
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchymods_link.lua")
Duel.LoadScript("glitchymods_lifepoints.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ monsters
	Link.AddProcedure(c,nil,2)
	--[[This linked card, and monsters linked to this card, are treated as being Extra Linked. (Monsters treated as being Extra Linked by this effect are not treated as being co-linked unless they are
	co-linked.)]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BECOME_EXTRA_LINKED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.eltg)
	c:RegisterEffect(e1)
	--[[Extra Linked monsters gain 500 ATK.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsExtraLinked))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	--[[While you control an Extra Linked monster, your LP is increased by 1000 for each.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_UPDATE_LP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetValue(s.lpval)
	c:RegisterEffect(e3)
	xgl.RegisterContinuousLPModifier()
end

--E1
function s.eltg(e,c)
	local h=e:GetHandler()
	if c==h then
		return h:IsLinked()
	else
		local g=h:GetLinkedGroup()
		return g and g:IsContains(c)
	end
end

--E3
function s.lpval(e,tp)
	return Duel.GetMatchingGroupCount(Card.IsExtraLinked,tp,LOCATION_MZONE,0,nil)*1000
end