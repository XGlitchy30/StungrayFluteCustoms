--[[
The Valley of the Gravekeepers
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	aux.NecroValleyFilterMod=true
	c:Activation()
	--"Gravekeeper's" monsters gain 500 ATK/DEF. 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GRAVEKEEPERS))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	e1:UpdateDefenseClone(c)
	--While a "Gravekeeper's" monster is face-up on the field, apply the following effects.	
	----You cannot banish cards from the GYs. If you control "Gravekeeper's Priestess", this effect is also applied to your opponent.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(s.gkcon_simple())
	e2:SetTarget(s.rmlimit)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetTargetRange(0,1)
	e2x:SetCondition(s.gkcon_simple(3381441))
	c:RegisterEffect(e2x)
	
	----Negate any of your card effects that would move a card in the GY(s) to a different place. If you control "Gravekeeper's Chief", this effect is also applied to your opponent.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.gkcon_simple())
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	----Prevent non-activated effects from Special Summoning from the GY (e.g. unclassified summoning effects or delayed effects)
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_FIELD)
	e3x:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3x:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3x:SetRange(LOCATION_FZONE)
	e3x:SetTargetRange(1,0)
	e3x:SetCondition(s.gkcon_simple())
	e3x:SetTarget(s.cannotsptg)
	c:RegisterEffect(e3x)
	local e3y=e3x:Clone()
	e3y:SetTargetRange(0,1)
	e3y:SetCondition(s.gkcon_simple(62473983))
	c:RegisterEffect(e3y)
	
	----Prevent selection of cards in the GY at the time of resolution if the activating player is affected by the last bulleted effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(CARD_THE_VALLEY_OF_GRAVEKEEPERS)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(1,0)
	e4:SetCondition(s.gkcon_simple())
	c:RegisterEffect(e4)
	local e4x=e4:Clone()
	e4x:SetTargetRange(0,1)
	e4x:SetCondition(s.gkcon_simple(62473983))
	c:RegisterEffect(e4x)
	
	----Negate any of your card effects that changes names, Types, Attributes or Levels/Ranks/Link Ratings in the GY. If you control "Gravekeeper's Commandant", this effect also applies to your opponent.
	local e3z=Effect.CreateEffect(c)
	e3z:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3z:SetCode(EVENT_CHAIN_SOLVING)
	e3z:SetRange(LOCATION_FZONE)
	e3z:SetCondition(s.gkcon_simple())
	e3z:SetOperation(s.elemsabfix)
	c:RegisterEffect(e3z)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_MODIFY_ATTACK)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(1,0)
	e5:SetCondition(s.gkcon_simple())
	e5:SetTarget(s.atkmodlim)
	c:RegisterEffect(e5)
	local e5x=e5:Clone()
	e5x:SetTargetRange(0,1)
	e5x:SetCondition(s.gkcon_simple(17393207))
	c:RegisterEffect(e5x)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_MODIFY_DEFENSE)
	c:RegisterEffect(e6)
	local e6x=e5x:Clone()
	e6x:SetTargetRange(0,1)
	e6x:SetCode(EFFECT_CANNOT_MODIFY_DEFENSE)
	c:RegisterEffect(e6x)
	local e7=e5:Clone()
	e7:SetCode(EFFECT_CANNOT_MODIFY_LEVEL_X)
	c:RegisterEffect(e7)
	local e7x=e5x:Clone()
	e7x:SetTargetRange(0,1)
	e7x:SetCode(EFFECT_CANNOT_MODIFY_LEVEL_X)
	c:RegisterEffect(e7x)
	local e8=e5:Clone()
	e8:SetCode(EFFECT_CANNOT_MODIFY_CODE)
	c:RegisterEffect(e8)
	local e8x=e5x:Clone()
	e8x:SetTargetRange(0,1)
	e8x:SetCode(EFFECT_CANNOT_MODIFY_CODE)
	c:RegisterEffect(e8x)
	local e9=e5:Clone()
	e9:SetCode(EFFECT_CANNOT_MODIFY_ATTRIBUTE)
	c:RegisterEffect(e9)
	local e9x=e5x:Clone()
	e9x:SetTargetRange(0,1)
	e9x:SetCode(EFFECT_CANNOT_MODIFY_ATTRIBUTE)
	c:RegisterEffect(e9x)
	local e10=e5:Clone()
	e10:SetCode(EFFECT_CANNOT_MODIFY_RACE)
	c:RegisterEffect(e10)
	local e10x=e5x:Clone()
	e10x:SetTargetRange(0,1)
	e10x:SetCode(EFFECT_CANNOT_MODIFY_RACE)
	c:RegisterEffect(e10x)
end
s.listed_names={3381441,62473983,17393207}
s.listed_series={SET_GRAVEKEEPERS}
s.TypeAttrInGYCodes={45702014,18214905,72819261,46425662,19036557,83032858,70856343,9069157}

function s.gkcon_simple(code)
	if code then
		return	function(e)
					local tp=e:GetHandlerPlayer()
					return Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,SET_GRAVEKEEPERS),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,code),tp,LOCATION_ONFIELD,0,1,nil)
				end
	else
		return	function(e)
					local tp=e:GetHandlerPlayer()
					return Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,SET_GRAVEKEEPERS),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
				end
	end
end

--E2
function s.rmlimit(e,c,p)
	if not (c:IsLocation(LOCATION_GRAVE) and not c:IsHasEffect(EFFECT_NECRO_VALLEY_IM)) then return false end
	return not Duel.IsPlayerAffectedByEffect(c:GetControler(),EFFECT_NECRO_VALLEY_IM)
end

--E3
function s.disfilter(c,not_im0,not_im1,re)
	if not c:IsRelateToEffect(re) then return false end
	if c:IsControler(0) then
		return not_im0
	else
		return not_im1
	end
end
function s.discheck(ev,category,re,not_im0,not_im1,isCustom)
	local ex,tg,ct,p,v
	if isCustom then
		ex,tg,ct,p,v=Duel.GetCustomOperationInfo(ev,category)
	else
		ex,tg,ct,p,v=Duel.GetOperationInfo(ev,category)
	end 
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
	if not Duel.IsChainDisablable(ev) or tc:IsHasEffect(EFFECT_NECRO_VALLEY_IM) or not Duel.IsPlayerAffectedByEffect(rp,CARD_THE_VALLEY_OF_GRAVEKEEPERS) then return end
	local res=false
	local not_im0=not Duel.IsPlayerAffectedByEffect(0,EFFECT_NECRO_VALLEY_IM)
	local not_im1=not Duel.IsPlayerAffectedByEffect(1,EFFECT_NECRO_VALLEY_IM)
	
	local categories={CATEGORY_SPECIAL_SUMMON,CATEGORY_REMOVE,CATEGORY_TOHAND,CATEGORY_TODECK,CATEGORY_TOEXTRA,CATEGORY_EQUIP,CATEGORY_ATKCHANGE,CATEGORY_DEFCHANGE,CATEGORY_LVCHANGE}
	for _,cat in ipairs(categories) do
		if s.discheck(ev,cat,re,not_im0,not_im1,false) then
			res=true
			break
		end
	end
	
	if not res and not re:GetHandler():IsOriginalCode(table.unpack(s.TypeAttrInGYCodes)) and s.discheck(ev,CATEGORY_LEAVE_GRAVE,re,not_im0,not_im1) then res=true end
	
	if not res then
		local custom_categories={CATEGORY_ATKCHANGE,CATEGORY_DEFCHANGE,CATEGORY_LVCHANGE,CATEGORY_CODE_CHANGE,CATEGORY_ATTRIBUTE_CHANGE,CATEGORY_RACE_CHANGE}
		for _,cat in ipairs(custom_categories) do
			if s.discheck(ev,cat,re,not_im0,not_im1,true) then
				res=true
				break
			end
		end
	end
	
	if res then
		Duel.NegateEffect(ev)
	end
end
function s.necrovalley_op(te,c)
	if not last_tp then last_tp=te:GetHandlerPlayer() end
	return Duel.IsPlayerAffectedByEffect(last_tp,CARD_THE_VALLEY_OF_GRAVEKEEPERS) and not Duel.IsPlayerAffectedByEffect(c:GetControler(),EFFECT_NECRO_VALLEY_IM)
end
function s.cannotsptg(e,c,sp,sumtype,sumpos,target_p,sumeff)
	return c:IsLocation(LOCATION_GRAVE) and sumeff and not sumeff:IsActivated() and not sumeff:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE)
		and not Duel.IsPlayerAffectedByEffect(c:GetControler(),EFFECT_NECRO_VALLEY_IM) and not c:IsHasEffect(EFFECT_NECRO_VALLEY_IM)
		and not sumeff:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY_IM)
end

--E5

function s.elemsabfix(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if not Duel.IsChainDisablable(ev) or tc:IsHasEffect(EFFECT_NECRO_VALLEY_IM) or (rp==1-tp and not Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,17393207),tp,LOCATION_ONFIELD,0,1,nil)) then return end
	local res=false
	local not_im0=not Duel.IsPlayerAffectedByEffect(0,EFFECT_NECRO_VALLEY_IM)
	local not_im1=not Duel.IsPlayerAffectedByEffect(1,EFFECT_NECRO_VALLEY_IM)
	if not res and s.discheck(ev,CATEGORY_LEAVE_GRAVE,re,not_im0,not_im1,false) and re:GetHandler():IsOriginalCode(table.unpack(s.TypeAttrInGYCodes)) then
		res=true
	end
	if res then
		Duel.NegateEffect(ev)
	end
end
function s.atkmodlim(e,c,p,r)
	return c:IsLocation(LOCATION_GRAVE) and r&REASON_EFFECT==REASON_EFFECT and not Duel.IsPlayerAffectedByEffect(c:GetControler(),EFFECT_NECRO_VALLEY_IM) and not e:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY_IM)
end