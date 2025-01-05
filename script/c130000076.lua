--[[
Alone, in Linaan
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If this card is sent to the GY: You can add 1 "The Valley of Linaan" from your Deck to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:HOPT()
	e1:SetSearchFunctions(aux.FilterBoolFunction(Card.IsCode,CARD_THE_VALLEY_OF_LINAAN))
	c:RegisterEffect(e1)
	--[[If an attack is declared involving your "Linaan" monster: You can equip this card from your GY to that monster as an Equip Spell with the following effect.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.atcon)
	e2:SetTarget(s.atg)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_THE_VALLEY_OF_LINAAN}
s.listed_series={SET_LINAAN}

--E2
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetBattleMonster(tp)
	return a and a:IsFaceup() and a:IsSetCard(SET_LINAAN)
end
function s.atg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local a=Duel.GetBattleMonster(tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and a:IsCanBeEquippedWith(c,e,tp) end
	Duel.SetTargetCard(a)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,tp,0)
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
	end
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local a=Duel.GetFirstTarget()
	if a:IsRelateToChain() and a:IsControler(tp) and c:IsRelateToChain() and a:IsCanBeEquippedWith(c,e,tp) and xgl.EquipToOtherCardAndRegisterLimit(e,tp,c,a) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end