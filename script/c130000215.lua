--[[
Night Artist
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 Effect Monsters with different names
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2,s.lcheck)
	--Can only be Link Summoned once per turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--Material check
	local mc=Effect.CreateEffect(c)
	mc:SetType(EFFECT_TYPE_SINGLE)
	mc:SetCode(EFFECT_MATERIAL_CHECK)
	mc:SetValue(s.valcheck)
	c:RegisterEffect(mc)
	--If this card is Link Summoned using a Link Monster as material: You can target 1 Link Monster in your GY; equip it to this card. This card gains ATK equal to the equipped monster's Link Rating x 300.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetLabel(0)
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() and e:GetLabel()==1 end)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,s.eqval,Card.EquipByEffectAndLimitRegister,e1)
	mc:SetLabelObject(e1)
	--If this card is sent from the Spell & Trap Zone to the GY: Draw 1 card.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,1)
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:HOPT()
	e4:SetCondition(s.spcon)
	e4:SetDrawFunctions(0,1)
	c:RegisterEffect(e4)
end
s.listed_names={id}

function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentProperty(Card.GetCode,lc,sumtype,tp)
end

--E0
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLinkSummoned()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK
end

--MC
function s.valcheck(e,c)
	if c:GetMaterial():IsExists(Card.IsType,1,nil,TYPE_LINK,c,SUMMON_TYPE_LINK,e:GetHandlerPlayer()) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end

--E1
function s.filter(c,handler,e,tp)
	return c:IsMonsterType(TYPE_LINK) and handler:IsCanBeEquippedWith(c,e,tp,REASON_EFFECT)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,c,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,c,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	Duel.SetCustomOperationInfo(0,CATEGORY_EQUIP,g,1,0,0,c)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToChain() and tc and tc:IsRelateToChain() and c:IsCanBeEquippedWith(tc,e,tp,REASON_EFFECT)
		and c:EquipByEffectAndLimitRegister(e,tp,tc) and c:GetEquipGroup():IsContains(tc) and tc:IsOriginalType(TYPE_LINK) then
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,0,0,aux.Stringid(id,2))
		local lk=tc:Level()
		if lk>0 then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_OWNER_RELATE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			e2:SetValue(lk*300)
			tc:RegisterEffect(e2)
		end
	end
end

--E4
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end