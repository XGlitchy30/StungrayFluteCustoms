--[[
Wiccink Runes
Card Author: Aurora
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If you control a "Wiccink" monster: Target 1 face-up monster your opponent controls; its ATK becomes 0 until the end of this turn, also,
	if you control a "Wiccink Token", you can change all monsters on the field to Attack Position]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If a "Wiccink" card(s) is banished (except during the Damage Step): You can equip this card from your GY to 1 "Wiccink Token" you control as an Equip Spell with this effect]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.eqcon,nil,s.eqtg,s.eqop)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_WICCINK}
s.listed_series={SET_WICCINK}

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_WICCINK)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(TOKEN_WICCINK)
end
function s.atkfilter(c,check)
	return c:IsFaceup() and (c:IsCanChangeATK(0) or check)
end
function s.posfilter(c)
	return not c:IsAttackPos() and c:IsCanChangePosition()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local res=Duel.IsExists(false,s.filter,tp,LOCATION_ONFIELD,0,1,nil)
	local g=Duel.Group(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local check=res and #g>0
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.atkfilter(chkc,tp,check) end
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExists(true,s.atkfilter,tp,0,LOCATION_MZONE,1,nil,check)
	end
	local g=Duel.Select(HINTMSG_ATKCHANGE,true,tp,s.atkfilter,tp,0,LOCATION_MZONE,1,1,nil,check)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,c:GetControler(),c:GetLocation(),{0})
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,g,#g,PLAYER_ALL,POS_FACEUP_ATTACK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsCanChangeATK(0) then
		tc:ChangeATK(0,RESET_PHASE|PHASE_END,{e:GetHandler(),true})
	end
	local g=Duel.Group(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if Duel.IsExists(false,s.filter,tp,LOCATION_ONFIELD,0,1,nil) and #g>0 and Duel.SelectYesNo(tp,STRING_ASK_POSITION) then
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	end
end

--E2
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil)
end
function s.eqfilter(c,tp)
	return not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and s.eqfilter(c,tp) and Duel.IsExists(false,s.filter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local g=Duel.Select(HINTMSG_EQUIP,false,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			if Duel.EquipToOtherCardAndRegisterLimit(e,tp,c,tc) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_EQUIP)
				e1:SetCode(EFFECT_SET_BASE_ATTACK)
				e1:SetValue(s.atkval)
				c:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_SET_BASE_DEFENSE)
				e2:SetValue(s.defval)
				c:RegisterEffect(e2)
			end
		end
	end
end
function s.atkval(e,c)
	return c:GetBaseAttack()*2
end
function s.defval(e,c)
	return c:GetBaseDefense()*2
end