--[[
Undying Draugon
Card Author: pretzelsnake
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Once per Chain, when a card or effect is activated that targets this card in your GY (Quick Effect): You can Special Summon it, but place it on top of the Deck when it leaves the field.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e1:SetFunctions(
		s.spcon,
		nil,
		xgl.SpecialSummonSelfTarget(),
		xgl.SpecialSummonSelfOperation(LOCATION_DECK)
	)
	c:RegisterEffect(e1)
end
--E1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end