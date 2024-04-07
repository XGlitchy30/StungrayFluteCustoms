--[[
Resurrected Realm
Card Author: Fishy
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchylib_delayed_event.lua")
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+1
	end
	
	c:Activation()
	--All monsters on the field and in the GYs are also treated as Zombie monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetTarget(s.rctg)
	e1:SetValue(RACE_ZOMBIE)
	c:RegisterEffect(e1)
	--If a monster(s) is Special Summoned from the GY: That monster(s) gains 300 ATK.
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,EVENT_SPSUMMON_SUCCESS,s.cfilter,id,LOCATION_FZONE,false,LOCATION_FZONE,nil,id+1,true)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(0,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_CUSTOM+s.progressive_id)
	e2:SetRange(LOCATION_SZONE)
	e2:SetFunctions(nil,nil,s.atktg,s.atkop)
	c:RegisterEffect(e2)
end

--E1
function s.rctg(e,c)
	if c:GetFlagEffect(1)==0 then
		c:RegisterFlagEffect(1,0,0,0)
		local eff
		if c:IsLocation(LOCATION_MZONE) then
			eff={Duel.GetPlayerEffect(c:GetControler(),EFFECT_NECRO_VALLEY)}
		else
			eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		end
		c:ResetFlagEffect(1)
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
	end
	return true
end

--E2
function s.cfilter(c,e,tp,eg,ep,ev,re,r,rp,se,event)
	return c:IsSummonLocation(LOCATION_GRAVE)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if eg then
		local c=e:GetHandler()
		local g
		local sg=eg:Filter(aux.Faceup(aux.NOT(Card.HasFlagEffectLabel)),nil,id+2,c:GetFieldID())
		if sg:GetClassCount(Card.GetFlagEffectLabel,id+1)>1 then
			g=aux.SelectUnselectGroup(sg,e,tp,1,#sg,aux.SimultaneousEventGroupCheck(id+1,sg),1,tp,HINTMSG_FACEUP,aux.SimultaneousEventGroupCheck(id+1,sg),false,false)
		else
			g=sg:Clone()
		end
		Duel.HintSelection(g)
		for tc in aux.Next(g) do
			tc:RegisterFlagEffect(id+2,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1,c:GetFieldID())
		end
		Duel.SetTargetCard(g)
		local residences={0,0}
		for tc in aux.Next(g) do
			local p=tc:GetControler()+1
			residences[p]=residences[p]|tc:GetLocation()
		end
		for p=1,2 do
			local locs=residences[p]
			if locs~=0 then
				Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,p-1,locs,300)
			end
		end
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if not g then return end
	g=g:Filter(Card.IsFaceup,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		tc:UpdateATK(300,true,{c,true})
	end
end