--[[
Cleric of Luminence
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ Level 1 monsters
	Xyz.AddProcedure(c,nil,1,2,nil,nil,Xyz.InfiniteMats)
	--Once per turn, when a card or effect is activated that targets this card on the field, or when this card is targeted for an attack (Quick Effect): You can detach 1 material from this card; it gains 1300 DEF until the end of this turn.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:OPT()
	e2:SetCondition(function(e,tp,eg) return eg:IsContains(e:GetHandler()) end)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e3)
end

--E2
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanUpdateDEF(1300,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,e:GetHandler(),1,tp,1300)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() and c:IsCanUpdateDEF(1300,e,tp) then
		c:UpdateDEF(1300,RESET_PHASE|PHASE_END)
	end
end