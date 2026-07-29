--[[
Kappa Rilassante
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
    --FLIP: Target 1 "Kappa" monster you control; it gains 200 ATK/DEF.
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORIES_ATKDEF)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    --If this card is destroyed by battle: You can add 1 "Kappa" monster from your Deck to your hand.
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:HOPT()
	e2:SetSearchFunctions(s.thfilter)
	c:RegisterEffect(e2)
end
s.listed_series={SET_KAPPA}
s.lists_kappa_monster=true

--E1
function s.filter(c)
	return c:IsFaceup() and c:IsKappa()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return true end
	local g=Duel.Select(HINTMSG_ATKDEF,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,200)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,tp,200)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsFaceup() then
		tc:UpdateATKDEF(200,200,true,{e:GetHandler(),true})
	end
end

--E2
function s.thfilter(c)
	return c:IsMonster() and c:IsKappa()
end