--[[
Percussion Beetle Snap
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If this card is in your hand: You can attach this card to a LIGHT Xyz Monster you control as material.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCustomCategory(CATEGORY_ATTACH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.attg,
		s.atop
	)
	c:RegisterEffect(e1)
	--[[If this card is detached from an Xyz Monster: You can add 1 "Percussion Beetle" card from your GY to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_MOVE)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetSearchFunctions(xgl.ArchetypeFilter(SET_PERCUSSION_BEETLE),LOCATION_GRAVE,1,1,nil)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PERCUSSION_BEETLE}

--E1
function s.atfilter(c,h,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_LIGHT) and h:IsCanBeAttachedTo(c,e,tp)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExists(false,s.atfilter,tp,LOCATION_MZONE,0,1,nil,c,e,tp) end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,c,1,tp,LOCATION_MZONE)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		local g=Duel.Select(HINTMSG_ATTACHTO,false,tp,s.atfilter,tp,LOCATION_MZONE,0,1,1,nil,c,e,tp)
		if Duel.Highlight(g) then
			Duel.Attach(c,g:GetFirst(),false,e,tp)
		end
	end
end

--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not (c:IsLocation(LOCATION_DECK|LOCATION_HAND) or c:IsBanished(POS_FACEDOWN) or not c:IsPreviousLocation(LOCATION_OVERLAY))
end