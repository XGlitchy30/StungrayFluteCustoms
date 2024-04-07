--[[
Whimsical Introspection
Card Author: Sock
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--You can only control 1 "Whimsical Introspection".
	c:SetUniqueOnField(1,0,id)
	--When this card is activated: Declare 1 Monster Type; during your turn only, monsters in the GYs become that Type.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--Once while this card is face-up on the field, if a monster(s) is sent to the GY: Each player shuffles their Deck.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetFunctions(s.shcon,nil,aux.DummyTarget,s.shop)
	c:RegisterEffect(e2)
end

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:GetHandler():SetHint(CHINT_RACE,rc)
	Duel.SetTargetParam(rc)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=Duel.GetTargetParam()
	if not rc then return end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e1:SetCondition(aux.TurnPlayerCond(0))
	e1:SetTarget(s.rctg)
	e1:SetValue(rc)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
	--Special hidden effect to handle interactions with effect that care about the Type of a monster that is sent to the GY from a different location when resolving (see Transmodify)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(CARD_ZOMBIE_WORLD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetCondition(aux.TurnPlayerCond(0))
	e2:SetValue(s.val(rc))
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e2)
end
function s.rctg(e,c)
	if c:GetFlagEffect(1)==0 then
		c:RegisterFlagEffect(1,0,0,0)
		local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		c:ResetFlagEffect(1)
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
	end
	return true
end
function s.val(race)
	return  function(e,c,re,chk)
				if chk==0 then return true end
				return race
			end
end

--E2
function s.shcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsMonster,1,nil)
end
function s.shop(e,tp,eg,ep,ev,re,r,rp)
	local turnp=Duel.GetTurnPlayer()
	for p=turnp,1-turnp,1-2*turnp do
		Duel.ShuffleDeck(p)
	end
end