--[[
The Valley of Linaan
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:Activation()
	--[[If a monster(s) is Special Summoned (except during the Damage Step): You can target 1 "Motherhood" Trap in your GY; place it on the top of of your Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_FZONE)
	e1:HOPT()
	e1:SetFunctions(
		s.tdcon,
		nil,
		xgl.SendtoTarget(LOCATION_DECK,TGCHECK_IT,s.tdfilter,LOCATION_GRAVE,0,1,1,nil),
		xgl.SendtoOperation(LOCATION_DECK,TGCHECK_IT,s.tdfilter,LOCATION_GRAVE,0,1,1,nil,SEQ_DECKTOP)
	)
	c:RegisterEffect(e1)
	--[[If this card would be destroyed, you can discard 1 "The Valley of Linaan" instead.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.desreptg)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_THE_VALLEY_OF_LINAAN}
s.listed_series={SET_MOTHERHOOD}

--E1
function s.tdfilter(c)
	return c:IsTrap() and c:IsSetCard(SET_MOTHERHOOD)
end

--E2
function s.repfilter(c)
	return c:IsCode(id) and c:IsDiscardable(REASON_EFFECT|REASON_REPLACE)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return
		not c:IsReason(REASON_REPLACE) and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_HAND,0,1,c)
	end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.DiscardHand(tp,s.repfilter,1,1,REASON_EFFECT|REASON_DISCARD|REASON_REPLACE,nil)
		return true
	else
		return false
	end
end