--[[
Fire Formation - Boyang
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[When this card is activated: Target up to 3 "Fire Formation" Continuous Spell/Traps in your GY; shuffle them into the Deck.]]
	local e1=c:Activation(false,true,nil,nil,
		xgl.SendtoTarget(LOCATION_DECK,true,s.filter,LOCATION_GRAVE,0,1,3,nil),
		xgl.SendtoOperation(LOCATION_DECK,TGCHECK_IT),
		true)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	c:RegisterEffect(e1)
	--[["Fire Fist" monsters you control gain 300 ATK.]]
	c:UpdateATKField(300,LOCATION_SZONE,LOCATION_MZONE,0,aux.TargetBoolFunction(Card.IsSetCard,SET_FIRE_FIST))
end
s.listed_series={SET_FIRE_FORMATION,SET_FIRE_FIST}
--E1
function s.filter(c)
	return c:IsSpellTrap() and c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(SET_FIRE_FORMATION)
end