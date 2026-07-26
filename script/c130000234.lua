--[[
Covo Kappa
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")

function s.initial_effect(c)
	c:Activation()
	--You can only control 1 "Kappa Lair".
	c:SetUniqueOnField(1,0,id)
	--"Kappa" monsters you control gain 200 ATK/DEF.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_KAPPA))
	e1:SetValue(200)
	c:RegisterEffect(e1)
	e1:UpdateDefenseClone(c)
	--Once per turn, during your End Phase: You can target 1 face-up monster your opponent controls; it loses ATK/DEF equal to the number of face-up "Kappa" monsters you control x 200.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE|PHASE_END)
	e2:OPT()
	e2:SetFunctions(xgl.TurnPlayerCond(0),nil,s.statstg,s.statsop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_KAPPA}
s.lists_kappa_monster=true

--E1
function s.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_KAPPA)
end
function s.statstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end
	local ct=Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_MZONE,0,nil)
	local g=Duel.Select(HINTMSG_ATKDEF,true,tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,-ct*200)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,tp,-ct*200)
end

function s.statsop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		local ct=Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_MZONE,0,nil)
		if ct>0 then
			local val=-ct*200
			tc:UpdateATKDEF(val,val,true,{e:GetHandler(),true})
		end
	end
end