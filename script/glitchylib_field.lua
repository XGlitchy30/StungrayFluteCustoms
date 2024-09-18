function Card.FieldEffect(c,code,range,selfzones,oppozones,f,val,cond,reset,rc,prop)
--CONTINUOUS EFFECTS (EFFECT_TYPE_FIELD)
	if not range then range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE end
	if not selfzones then selfzones=0 end
	if oppozones==true then
		oppozones=selfzones
	elseif not oppozones then
		oppozones=0
	end
	if not rc then rc=c end
	local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_FIELD)
	if prop and prop~=0 then
		e:SetProperty(prop)
	end
	e:SetRange(range)
	e:SetCode(code)
	if cond then
		e:SetCondition(cond)
	end
	e:SetTargetRange(selfzones,oppozones)
	if f then
		e:SetTarget(f)
	end
	if val then
		e:SetValue(val)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	--c:RegisterEffect(e)
	return e
end

-----------------------------------------------------------------------
function Card.UpdateATKField(c,atk,range,selfzones,oppozones,f,cond,reset,rc,prop)
	local e=c:FieldEffect(EFFECT_UPDATE_ATTACK,range,selfzones,oppozones,f,atk,cond,reset,rc,prop)
	c:RegisterEffect(e)
	return e
end
function Card.UpdateDEFField(c,def,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_UPDATE_DEFENSE,range,selfzones,oppozones,f,def,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.UpdateATKDEFField(c,atk,def,range,selfzones,oppozones,f,cond,reset,rc)
	def = def or atk
	local e1=c:FieldEffect(EFFECT_UPDATE_ATTACK,range,selfzones,oppozones,f,atk,cond,reset,rc)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(def)
	c:RegisterEffect(e2)
	return e1,e2
end
function Card.ChangeATKField(c,atk,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_SET_ATTACK_FINAL,range,selfzones,oppozones,f,atk,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.ChangeDEFField(c,def,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_SET_DEFENSE_FINAL,range,selfzones,oppozones,f,def,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end

function Card.AddTypeField(c,typ,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_ADD_TYPE,range,selfzones,oppozones,f,typ,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end

function Card.ChangeAttributeField(c,attr,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_CHANGE_ATTRIBUTE,range,selfzones,oppozones,f,attr,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end

function Card.ChangeRaceField(c,race,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_CHANGE_RACE,range,selfzones,oppozones,f,race,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end

function Card.UpdateLevelField(c,lv,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_UPDATE_LEVEL,range,selfzones,oppozones,f,lv,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.ChangeLevelField(c,lv,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_CHANGE_LEVEL,range,selfzones,oppozones,f,lv,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end

--Battle-related
function Card.InflictPiercingDamageField(c,range,selfzones,oppozones,f,val,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_PIERCE,range,selfzones,oppozones,f,val,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.CanAttackDirectlyField(c,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_DIRECT_ATTACK,range,selfzones,oppozones,f,nil,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.CanAttackWhileInDefensePositionField(c,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_DEFENSE_ATTACK,range,selfzones,oppozones,f,1,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.CannotTargetForAttacksField(c,val,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_CANNOT_SELECT_BATTLE_TARGET,range,selfzones,oppozones,f,val,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.MustAttackField(c,range,selfzones,oppozones,f,cond,reset,rc)
	local e=c:FieldEffect(EFFECT_MUST_ATTACK,range,selfzones,oppozones,f,nil,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end

function Card.SetMaximumNumberOfAttacksField(c,ct,range,selfzones,oppozones,f,cond,reset,rc)
	if not ct or type(ct)~="number" then ct=2 end
	local e=c:FieldEffect(EFFECT_EXTRA_ATTACK,range,selfzones,oppozones,f,ct-1,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
function Card.SetMaximumNumberOfAttacksOnMonstersField(c,ct,range,selfzones,oppozones,f,cond,reset,rc)
	if not ct or type(ct)~="number" then ct=2 end
	local e=c:FieldEffect(EFFECT_EXTRA_ATTACK_MONSTER,range,selfzones,oppozones,f,ct-1,cond,reset,rc)
	c:RegisterEffect(e)
	return e
end
--Protections
function Card.CannotBeDestroyedByBattleField(c,val,range,selfzones,oppozones,f,cond,prop,reset,rc)
	val = val and val or 1
	local e=c:FieldEffect(EFFECT_INDESTRUCTABLE_BATTLE,range,selfzones,oppozones,f,val,cond,reset,rc,prop)
	c:RegisterEffect(e)
	return e
end
function Card.CannotBeDestroyedByEffectsField(c,val,range,selfzones,oppozones,f,cond,prop,reset,rc)
	val = val and val or 1
	local e=c:FieldEffect(EFFECT_INDESTRUCTABLE_EFFECT,range,selfzones,oppozones,f,val,cond,reset,rc,prop)
	c:RegisterEffect(e)
	return e
end
function Card.CannotBeTargetedByEffectsField(c,val,range,selfzones,oppozones,f,cond,prop,reset,rc)
	prop = prop and prop or 0
	val = val and val or 1
	local e=c:FieldEffect(EFFECT_CANNOT_BE_EFFECT_TARGET,range,selfzones,oppozones,f,val,cond,reset,rc,EFFECT_FLAG_IGNORE_IMMUNE|prop)
	c:RegisterEffect(e)
	return e
end
function Card.UnaffectedField(c,val,range,selfzones,oppozones,f,cond,prop,reset,rc)
	if type(val)=="number" then
		val=aux.UnaffectedProtections[val]
	end
	local e=c:FieldEffect(EFFECT_IMMUNE_EFFECT,range,selfzones,oppozones,f,val,cond,reset,rc,prop)
	c:RegisterEffect(e)
	return e
end