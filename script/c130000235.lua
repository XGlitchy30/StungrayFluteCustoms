--[[
Delta Paradiso
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
	c:Activation()
	--"Kappa" monsters you control gain 200 ATK/DEF.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsKappa))
	e1:SetValue(200)
	c:RegisterEffect(e1)
	e1:UpdateDefenseClone(c)
	--If your "Kappa" monster is attacked, your opponent's monster loses 200 ATK/DEF during damage calculation only
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(-200)
	c:RegisterEffect(e2)
	e2:UpdateDefenseClone(c)
	--If this card is in your GY: You can target 1 "Kappa" monster you control; its Level becomes 2, also add this card to your hand.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,0)
	e3:SetCategory(CATEGORY_LVCHANGE|CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:HOPT()
	e3:SetFunctions(nil,nil,s.thtg,s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_KAPPA}
s.lists_kappa_monster=true

--E2
function s.atkcon(e)
	local d=Duel.GetAttackTarget()
	return Duel.IsPhase(PHASE_DAMAGE_CAL) and d and d:IsControler(e:GetHandlerPlayer()) and d:IsFaceup() and d:IsKappa()
end
function s.atktg(e,c)
	return c==Duel.GetAttacker()
end

--E3
function s.lvfilter(c)
	return c:IsFaceup() and c:IsKappa() and not c:IsLevel(2)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,g,#g,tp,-math.abs(g:GetFirst():GetLevel()-2))
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		xgl.ChangeLevel(tc,2,true,{c,true})
	end
	if c:IsRelateToChain() then
		Duel.Search(c)
	end
end