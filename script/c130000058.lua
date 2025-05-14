--[[
Stand in the Snow
Card Author: pretzelsnake
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[While this card is Set, if it was not Set this turn: You can target 1 face-up card on the field; change it to face-down Defense Position (if it is a monster)
	or Set it (if it is a Spell/Trap).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		--Register Setting
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
end
--E0
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
	end
end

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsFacedown() and not c:HasFlagEffect(id)
end
function s.filter(c)
	if not c:IsFaceup() then return false end
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsCanTurnSet()
	else
		return c:IsSSetable(true)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local exc=xgl.GetSelfTargetExceptionForSpellTrap(e)
	if chkc then
		return chkc:IsOnField() and chkc~=exc and s.filter(chkc)
	end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exc) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exc):GetFirst()
	if tc:IsLocation(LOCATION_MZONE) then
		e:SetCategory(CATEGORY_POSITION)
		Duel.SetCardOperationInfo(tc,CATEGORY_POSITION)
	else
		e:SetCategory(0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		if tc:IsLocation(LOCATION_MZONE) then
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		else
			if tc:IsFaceup() and tc:IsSSetable(true) then
				if tc:IsStatus(STATUS_LEAVE_CONFIRMED) then
					tc:CancelToGrave()
				end
				Duel.ChangePosition(tc,POS_FACEDOWN)
				Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
			end
		end
	end
end