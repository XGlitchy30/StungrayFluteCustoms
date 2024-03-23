--[[
Hidden Monastery of Necrovalley
Card Author: Sock
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:Activation()
	--"Gravekeeper's" monsters on the field gain 500 ATK/DEF.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GRAVEKEEPERS))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	e1:UpdateDefenseClone(c)
	--If a player would Tribute Summon a "Gravekeeper's" monster, "Gravekeeper's" monsters in their Deck can be Tributed as well.
	aux.RegisterSpecialTributeSummon(c)
	local e2z=Effect.CreateEffect(c)
	e2z:SetType(EFFECT_TYPE_FIELD)
	e2z:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	e2z:SetCode(EFFECT_ADD_EXTRA_TRIBUTE_GLITCHY)
	e2z:SetRange(LOCATION_FZONE)
	e2z:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e2z:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GRAVEKEEPERS))
	e2z:SetValue(s.value)
	c:RegisterEffect(e2z)
	
	--APPLY THE FOLLOWING EFFECTS, DEPENDING ON THE LEVELS OF "GRAVEKEEPER'S" MONSTERS YOU CONTROL
	
	--● 3+: Negate any card effect that changes Types, Attributes, ATK, or DEF in the GY.
	------Usual Necrovalley code for effects that change Types and Attributes in the GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_NECRO_VALLEY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_GRAVE,0)
	e3:SetCondition(s.contp)
	c:RegisterEffect(e3)
	local e3x=e3:Clone()
	e3x:SetTargetRange(0,LOCATION_GRAVE)
	e3x:SetCondition(s.conntp)
	c:RegisterEffect(e3x)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_NECRO_VALLEY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetCondition(s.contp)
	c:RegisterEffect(e4)
	local e4x=e4:Clone()
	e4x:SetTargetRange(0,1)
	e4x:SetCondition(s.conntp)
	c:RegisterEffect(e4x)
	---Custom effect to handle effects that change ATK or DEF in the GY
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_MODIFY_ATTACK)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(1,0)
	e5:SetCondition(s.lvcontp(3))
	e5:SetValue(s.atkmodlim)
	c:RegisterEffect(e5)
	local e5x=e5:Clone()
	e5x:SetTargetRange(0,1)
	e5x:SetCondition(s.lvconntp(3))
	c:RegisterEffect(e3x)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_MODIFY_DEFENSE)
	c:RegisterEffect(e6)
	local e6x=e6:Clone()
	e6x:SetTargetRange(0,1)
	e6x:SetCondition(s.lvconntp(3))
	c:RegisterEffect(e6x)
	
	--● 5+: Cards in the GY cannot be banished.
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_REMOVE)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTargetRange(LOCATION_GRAVE,0)
	e7:SetCondition(s.lvcontp(5))
	c:RegisterEffect(e7)
	local e7x=e7:Clone()
	e7x:SetTargetRange(0,LOCATION_GRAVE)
	e7x:SetCondition(s.lvconntp(5))
	c:RegisterEffect(e7x)
	
	--● 7+: Negate any card effect that would move a card in the GY to a different place.
	----Negate an effect when it resolves if it would move a card in the GY
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_CHAIN_SOLVING)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCondition(s.lvcon(7))
	e8:SetOperation(s.disop)
	c:RegisterEffect(e8)
	----Prevent non-activated effects from Special Summoning from the GY (e.g. unclassified summoning effects or delayed effects)
	local e8x=Effect.CreateEffect(c)
	e8x:SetType(EFFECT_TYPE_FIELD)
	e8x:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8x:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e8x:SetRange(LOCATION_FZONE)
	e8x:SetTargetRange(1,1)
	e8x:SetCondition(s.lvcon(7))
	e8x:SetTarget(s.cannotsptg)
	c:RegisterEffect(e8x)
	
	--● 9+: Once per turn, you can negate an activated card effect that targets a "Gravekeeper's" monster(s) (anywhere), and if you do, send it to the GY.
	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_DISABLE)
	e9:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e9:SetCode(EVENT_CHAIN_SOLVING)
	e9:SetRange(LOCATION_FZONE)
	e9:OPT()
	e9:SetCondition(s.negcon)
	e9:SetOperation(s.negop)
	c:RegisterEffect(e9)
end
s.listed_series={SET_GRAVEKEEPERS}

--E2
function s.extratributes(e,c)
	return c:IsMonster() and c:IsSetCard(SET_GRAVEKEEPERS)
end
function s.value(e,c)
	return s.extratributes,LOCATION_DECK,0,POS_FACEUP
end

--E3
function s.contp(e)
	return not Duel.IsPlayerAffectedByEffect(e:GetHandler():GetControler(),EFFECT_NECRO_VALLEY_IM)
end
function s.conntp(e)
	return not Duel.IsPlayerAffectedByEffect(1-e:GetHandler():GetControler(),EFFECT_NECRO_VALLEY_IM)
end

--General Level condition for bulleted effects
function s.lvfilter(c,lv)
	return c:IsFaceup() and c:IsSetCard(SET_GRAVEKEEPERS) and c:IsLevelAbove(lv)
end
function s.lvcon(lv)
	return	function(e,tp)
				if not tp then tp=e:GetHandlerPlayer() end
				return Duel.IsExists(false,s.lvfilter,tp,LOCATION_MZONE,0,1,nil,lv)
			end
end
--E5
function s.lvcontp(lv)
	return	function(e)
				return s.contp(e) and s.lvcon(lv)(e,e:GetHandlerPlayer())
			end
end
function s.lvconntp(lv)
	return	function(e)
				return s.conntp(e) and s.lvcon(lv)(e,e:GetHandlerPlayer())
			end
end
function s.atkmodlim(e,c,p,r)
	return not e:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY_IM) and c:IsLocation(LOCATION_GRAVE) and r&REASON_EFFECT==REASON_EFFECT
end

--E8
function s.disfilter(c,not_im0,not_im1,re)
	if c:IsControler(0) then return not_im0 and c:IsHasEffect(EFFECT_NECRO_VALLEY) and c:IsRelateToEffect(re)
	else return not_im1 and c:IsHasEffect(EFFECT_NECRO_VALLEY) and c:IsRelateToEffect(re) end
end
function s.discheck(ev,category,re,not_im0,not_im1)
	local ex,tg,ct,p,v=Duel.GetOperationInfo(ev,category)
	if not ex then return false end
	if (category==CATEGORY_LEAVE_GRAVE or v==LOCATION_GRAVE) and ct>0 and not tg then
		if p==0 then return not_im0
		elseif p==1 then return not_im1
		elseif p==PLAYER_ALL then return not_im0 or not_im1
		elseif p==PLAYER_EITHER then return not_im0 and not_im1
		end
	end
	if tg and #tg>0 then
		return tg:IsExists(s.disfilter,1,nil,not_im0,not_im1,re)
	end
	return false
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if not Duel.IsChainDisablable(ev) or tc:IsHasEffect(EFFECT_NECRO_VALLEY_IM) then return end
	local res=false
	local not_im0=not Duel.IsPlayerAffectedByEffect(0,EFFECT_NECRO_VALLEY_IM)
	local not_im1=not Duel.IsPlayerAffectedByEffect(1,EFFECT_NECRO_VALLEY_IM)
	if not res and s.discheck(ev,CATEGORY_SPECIAL_SUMMON,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_REMOVE,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_TOHAND,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_TODECK,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_TOEXTRA,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_EQUIP,re,not_im0,not_im1) then res=true end
	if not res and s.discheck(ev,CATEGORY_LEAVE_GRAVE,re,not_im0,not_im1) then res=true end
	if res then Duel.NegateEffect(ev) end
end
function s.cannotsptg(e,c,sp,sumtype,sumpos,target_p,sumeff)
	return c:IsLocation(LOCATION_GRAVE) and sumeff and not sumeff:IsActivated() and not sumeff:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE)
		and not Duel.IsPlayerAffectedByEffect(c:GetControler(),EFFECT_NECRO_VALLEY_IM) and not c:IsHasEffect(EFFECT_NECRO_VALLEY_IM)
		and not sumeff:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY_IM)
end

--E9
function s.tfilter(c)
	return c:IsFaceupEx() and c:IsMonster() and c:IsSetCard(SET_GRAVEKEEPERS)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and s.lvcon(9)(e,tp) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and g:IsExists(s.tfilter,1,nil) and Duel.IsChainDisablable(ev)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SelectEffectYesNo(tp,c) then
		if Duel.NegateEffect(ev) then
			local rc=re:GetHandler()
			if rc and rc:IsRelateToChain(ev) and rc:IsAbleToGrave() then
				Duel.SendtoGrave(rc,REASON_EFFECT)
			end
		end
	end
end