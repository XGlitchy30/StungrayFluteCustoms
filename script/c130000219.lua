--[[
Paladino Atlantico
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--If you have no cards in your Extra Deck: You can Tribute 1 "Atlantean" monster; Special Summon this card from your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCondition(xgl.ExactFieldGroupCountCond(LOCATION_EXTRA,0,0))
	e1:SetCost(xgl.TributeCost(
			xgl.ArchetypeFilter(SET_ATLANTEAN),
			1,
			1,
			false,
			false,
			true,
			true,
			1
		)
	)
	e1:SetSpecialSummonSelfFunctions(true)
	c:RegisterEffect(e1)
	--If this card is sent to the GY to activate a WATER monster's effect: You can draw 1 card.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.drawcond)
	e2:SetDrawFunctions()
	c:RegisterEffect(e2)
	
end
s.listed_series={SET_ATLANTEAN}

--E2
function s.drawcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsMonsterEffect()
		and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end