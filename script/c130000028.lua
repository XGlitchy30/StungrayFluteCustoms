--[[
Malefic Kaiser Dragon
Card Author: Sock
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--There can only be 1 "Malefic" monster on the field.
	c:SetUniqueOnField(1,1,aux.MaleficUniqueFilter(c),LOCATION_MZONE)
	--Cannot be Normal Summoned/Set. Must be Special Summoned (from your hand) by banishing 1 "Kaiser Dragon" from your Extra Deck. 
	aux.AddMaleficSummonProcedure(c,CARD_KAISER_DRAGON,LOCATION_EXTRA)
	--If there is no face-up Field Spell on the field, destroy this card.
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_SELF_DESTROY)
	e7:SetCondition(s.descon)
	c:RegisterEffect(e7)
	--Other monsters you control cannot declare an attack. 
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetTarget(s.antarget)
	c:RegisterEffect(e8)
	--Must be Special Summoned by own procedure
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e9:SetCode(EFFECT_SPSUMMON_CONDITION)
	e9:SetValue(aux.FALSE)
	c:RegisterEffect(e9)
end
s.listed_names={CARD_KAISER_DRAGON}
s.listed_series={SET_MALEFIC}

function s.descon(e)
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.antarget(e,c)
	return c~=e:GetHandler()
end