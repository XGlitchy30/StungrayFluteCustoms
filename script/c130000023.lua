--[[
Yggdrasil's Blessing
Card Author: Pretz
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Each player can activate 1 Trap from their GY this turn, except "Yggdrasil's Blessing".
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.PlayerHasFlagEffect(0,id+100) then
		Duel.RegisterFlagEffect(0,id+100,RESET_PHASE|PHASE_END,0,1)
	else
		return
	end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_MOVE)
	e1:SetOperation(s.regop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,1,aux.Stringid(id,1))
end
function s.regfilter(c)
	return c:IsTrap() and not c:HasFlagEffect(id)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.regfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	for tc in g:Iter() do
		local te=tc:GetActivateEffect()
		if te then
			local flag1,flag2=te:GetProperty()
			local cond,target=te:GetCondition(),te:GetTarget()
			local e1=te:Clone()
			e1:SetProperty(flag1,flag2|EFFECT_FLAG2_FORCE_ACTIVATE_LOCATION)
			e1:SetRange(LOCATION_GRAVE)
			e1:SetValue(LOCATION_SZONE)
			e1:SetCondition(function(e,tp,...) return not e:GetHandler():IsCode(id) and not Duel.PlayerHasFlagEffect(tp,id) and (not cond or cond(e,...)) end)
			e1:SetTarget(s.replacetg(flag1&EFFECT_FLAG_CARD_TARGET>0,target))
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
		end
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
	end
end
function s.replacetg(tgchk,target)
	if not tgchk then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then return not target or target(e,tp,eg,ep,ev,re,r,rp,0) end
					Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
					if target then
						target(e,tp,eg,ep,ev,re,r,rp,chk)
					end
				end
	
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
					if chkc then return target and target(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
					if chk==0 then return not target or target(e,tp,eg,ep,ev,re,r,rp,0,chkc) end
					Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
					if target then
						target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
					end
				end
	end
end
			