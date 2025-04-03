Glitchy.ScriptSingleAsEquip = false		--If set to true, changes the behavior of the Single Effect functions, making them register EFFECT_TYPE_EQUIP effects

function Glitchy.CreateSingleEffect(c,code,val,reset,rc,range,cond,prop,desc)
	local typ = not xgl.ScriptSingleAsEquip and EFFECT_TYPE_SINGLE or EFFECT_TYPE_EQUIP
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    end
	
	if not prop then prop=0 end
	
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if range and typ==EFFECT_TYPE_SINGLE then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	e:SetCode(code)
	if val then
		e:SetValue(val)
	end
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		if rc==c and not donotdisable then
			reset = reset|RESET_DISABLE
			prop=prop|EFFECT_FLAG_COPY_INHERIT
		else
			prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		end
		if reset&RESET_EVENT==0 then
			reset=reset|RESET_EVENT|RESETS_STANDARD
		end
		e:SetReset(reset,rct)
	end
	
	if desc then
		prop=prop|EFFECT_FLAG_CLIENT_HINT
		e:SetDescription(desc)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end	
	
	return e
end

function Glitchy.ForEach(f,loc1,loc2,exc,n)
	if not loc1 then loc1=0 end
	if not loc2 then loc2=0 end
	if not n then n=1 end
	return	function(e,c)
				local tp=e:GetHandlerPlayer()
				local exc= (type(exc)=="boolean" and exc) and e:GetHandler() or (exc) and exc or nil
				return Duel.GetMatchingGroupCount(f,tp,loc1,loc2,exc,e,tp)*n
			end
end

--ATKDEF MODIFIERS
function Card.UpdateATK(c,atk,reset,rc,range,cond,prop,desc)
	local typ = not xgl.ScriptSingleAsEquip and EFFECT_TYPE_SINGLE or EFFECT_TYPE_EQUIP
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    elseif type(range)=="boolean" then
		donotdisable=range
	end
	
	if not prop then prop=0 end
	
	local att=c:GetAttack()
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if type(range)=="number" and not xgl.ScriptSingleAsEquip then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	e:SetCode(EFFECT_UPDATE_ATTACK)
	e:SetValue(atk)
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		if rc==c and not donotdisable then
			reset = reset|RESET_DISABLE
			prop=prop|EFFECT_FLAG_COPY_INHERIT
		else
			prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	
	local reg=c:RegisterEffect(e)
	
	if reset then
		return e,c:GetAttack()-att,reg
	else
		return e,reg
	end
end
function Card.UpdateDEF(c,def,reset,rc,range,cond,prop,desc)
	local typ = EFFECT_TYPE_SINGLE
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    elseif type(range)=="boolean" then
		donotdisable=range
	end
	
	if not prop then prop=0 end
	
	local df=c:GetDefense()
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if type(range)=="number" and not xgl.ScriptSingleAsEquip then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	e:SetCode(EFFECT_UPDATE_DEFENSE)
	e:SetValue(def)
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		if rc==c and not donotdisable then
			reset = reset|RESET_DISABLE
			prop=prop|EFFECT_FLAG_COPY_INHERIT
		else
			prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	
	c:RegisterEffect(e)
	if reset then
		return e,c:GetDefense()-df
	else
		return e
	end
end
function Card.UpdateATKDEF(c,atk,def,reset,rc,range,cond,prop,desc)
	local typ = EFFECT_TYPE_SINGLE
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    elseif type(range)=="boolean" then
		donotdisable=range
	end
	local rc = rc and rc or c
	
	if not atk then
		atk=def
	elseif not def then
		def=atk
	end
	
	if not prop then prop=0 end
	
	local oatk,odef=c:GetAttack(),c:GetDefense()
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	
	if type(range)=="number" and not xgl.ScriptSingleAsEquip then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	
	e:SetCode(EFFECT_UPDATE_ATTACK)
	e:SetValue(atk)
	
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		if rc==c and not donotdisable then
			reset = reset|RESET_DISABLE
			prop=prop|EFFECT_FLAG_COPY_INHERIT
		else
			prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	
	c:RegisterEffect(e)
	
	local e1x
	if def~=0 then
		e1x=e:Clone()
		e1x:SetCode(EFFECT_UPDATE_DEFENSE)
		e1x:SetValue(def)
	
		c:RegisterEffect(e1x)
	end
	
	if not reset then
		return e,e1x
	else
		return e,e1x,c:GetAttack()-oatk,c:GetDefense()-odef
	end
end
function Card.ChangeATK(c,atk,reset,rc,range,cond,prop,desc)
	local typ = EFFECT_TYPE_SINGLE
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    elseif type(range)=="boolean" then
		donotdisable=range
	end
	local rc = rc and rc or c
	
	if not prop then prop=0 end
	
	local oatk=c:GetAttack()
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	
	if type(range)=="number" and not xgl.ScriptSingleAsEquip then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	
	e:SetCode(EFFECT_SET_ATTACK_FINAL)
	e:SetValue(atk)
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		if rc==c and not donotdisable then
			reset = reset|RESET_DISABLE
			prop=prop|EFFECT_FLAG_COPY_INHERIT
		else
			prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	c:RegisterEffect(e)
	if not reset then
		return e
	else
		local natk=c:GetAttack()
		return e,oatk,natk,natk-oatk
	end
end
function Card.ChangeDEF(c,def,reset,rc,range,cond,prop,desc)
	local typ = EFFECT_TYPE_SINGLE
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    elseif type(range)=="boolean" then
		donotdisable=range
	end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    end
	local rc = rc and rc or c
	
	if not prop then prop=0 end
	
	local odef=c:GetDefense()
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	
	if type(range)=="number" and not xgl.ScriptSingleAsEquip then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	
	e:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e:SetValue(def)
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		if rc==c and not donotdisable then
			reset = reset|RESET_DISABLE
			prop=prop|EFFECT_FLAG_COPY_INHERIT
		else
			prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	
	c:RegisterEffect(e)
	if not reset then
		return e
	else
		local ndef=c:GetDefense()
		return e,odef,ndef,ndef-odef
	end
end
function Card.ChangeATKDEF(c,atk,def,reset,rc,range,cond,prop,desc)
	local typ = EFFECT_TYPE_SINGLE
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local donotdisable=false
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    elseif type(range)=="boolean" then
		donotdisable=range
	end
	
	if type(rc)=="table" then
        donotdisable=rc[2]
        rc=rc[1]
    end
	local rc = rc and rc or c
	
	if not prop then prop=0 end
	
	if not atk then
		atk=def
	elseif not def then
		def=atk
	end
	
	local oatk=c:GetAttack()
	local odef=c:GetDefense()
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	
	if type(range)=="number" and not xgl.ScriptSingleAsEquip then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	
	e:SetCode(EFFECT_SET_ATTACK_FINAL)
	e:SetValue(atk)
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		if rc==c and not donotdisable then
			reset = reset|RESET_DISABLE
			prop=prop|EFFECT_FLAG_COPY_INHERIT
		else
			prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	c:RegisterEffect(e)
	
	local e1x=e:Clone()
	e1x:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e1x:SetValue(def)
	c:RegisterEffect(e1x)
	if not reset then
		return e,e1x
	else
		local natk,ndef=c:GetAttack(),c:GetDefense()
		return e,e1x,oatk,natk,odef,ndef,natk-oatk,ndef-odef
	end
end

function Card.HalveATK(c,reset,rc,range,cond,prop,desc)
	local atk=math.floor(c:GetAttack()/2 + 0.5)
	return c:ChangeATK(atk,reset,rc,range,cond,prop,desc)
end
function Card.HalveDEF(c,reset,rc,range,cond,prop,desc)
	local def=math.floor(c:GetDefense()/2 + 0.5)
	return c:ChangeDEF(def,reset,rc,range,cond,prop,desc)
end
function Card.DoubleATK(c,reset,rc,range,cond,prop,desc)
	local atk=c:GetAttack()*2
	return c:ChangeATK(atk,reset,rc,range,cond,prop,desc)
end
function Card.DoubleDEF(c,reset,rc,range,cond,prop,desc)
	local def=c:GetDefense()*2
	return c:ChangeDEF(def,reset,rc,range,cond,prop,desc)
end

--OTHER STAT CHANGES
function Glitchy.AddType(c,ctyp,reset,rc,range,cond,prop,desc)
	local otyp=c:GetType()
	local e=xgl.CreateSingleEffect(c,EFFECT_ADD_TYPE,ctyp,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	if reset then
		return e,otyp,c:GetType()&ctyp
	else
		return e
	end
end
function Glitchy.ChangeAttribute(c,attr,reset,rc,range,cond,prop,desc)
	local oatt=c:GetAttribute()
	local e=xgl.CreateSingleEffect(c,EFFECT_CHANGE_ATTRIBUTE,attr,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	if reset then
		return e,oatt,c:GetAttribute()
	else
		return e
	end
end
function Glitchy.ChangeRace(c,race,reset,rc,range,cond,prop,desc)
	local orac=c:GetRace()
	local e=xgl.CreateSingleEffect(c,EFFECT_CHANGE_RACE,race,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	if reset then
		return e,orac,c:GetRace()
	else
		return e
	end
end
function Glitchy.UpdateLevel(c,lv,reset,rc,range,cond,prop,desc)
	local olv=c:GetLevel()
	local e=xgl.CreateSingleEffect(c,EFFECT_UPDATE_LEVEL,lv,reset,rc,range,cond,prop,desc)
	local reg=c:RegisterEffect(e)
	if reset then
		return e,c:GetLevel()-olv,reg
	else
		return e,reg
	end
end
function Glitchy.ChangeLevel(c,lv,reset,rc,range,cond,prop,desc)
	local olv=c:GetLevel()
	local e=xgl.CreateSingleEffect(c,EFFECT_CHANGE_LEVEL,lv,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	if reset then
		return e,c:GetLevel()-olv
	else
		return e
	end
end
function Glitchy.UpdateRank(c,lv,reset,rc,range,cond,prop,desc)
	local olv=c:GetRank()
	local e=xgl.CreateSingleEffect(c,EFFECT_UPDATE_RANK,lv,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	if reset then
		return e,c:GetRank()-olv
	else
		return e
	end
end
function Glitchy.ChangeRank(c,lv,reset,rc,range,cond,prop,desc)
	local olv=c:GetRank()
	local e=xgl.CreateSingleEffect(c,EFFECT_CHANGE_RANK,lv,reset,rc,range,cond,prop,desc)
	c:RegisterEffect(e)
	if reset then
		return e,c:GetRank()-olv
	else
		return e
	end
end

--PROTECTIONS

--Add full destruction protection (battle/effects/maintenance/costs)
function Card.CannotBeDestroyed(c,val,cond,reset,rc,range,prop,desc)
	local typ = EFFECT_TYPE_SINGLE
	
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if not prop then prop=0 end
	
	if not val then val=1 end
	
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if range then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	e:SetCode(EFFECT_INDESTRUCTABLE)
	e:SetValue(val)
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		prop=prop|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
		desc=desc or STRING_CANNOT_BE_DESTROYED_AT_ALL
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	if desc then
		e:SetDescription(desc)
	end
	
	c:RegisterEffect(e)
	
	return e
end

--Add battle destruction protection
function Card.CannotBeDestroyedByBattle(c,val,cond,reset,rc,range,prop,desc)
	local typ = EFFECT_TYPE_SINGLE
	
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if not prop then prop=0 end
	
	if not val then val=1 end
	
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if range then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	e:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e:SetValue(val)
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		prop=prop|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
		desc=desc or STRING_CANNOT_BE_DESTROYED_BY_BATTLE
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	if desc then
		e:SetDescription(desc)
	end
	
	local res=c:RegisterEffect(e)
	
	return e,res
end

--Add Tribute protection
function Card.CannotBeTributed(c,val,cond,reset,rc,range,prop,desc)
	local typ = EFFECT_TYPE_SINGLE
	rc = rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	prop = prop or 0
	val = val or 1
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(typ)
	if range then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e1:SetRange(range)
	end
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(val)
	if cond then
		e1:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		prop=prop|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
		desc=desc or STRING_CANNOT_BE_TRIBUTED
	end
	if prop~=0 then
		e1:SetProperty(prop)
	end
	if desc then
		e1:SetDescription(desc)
	end
	c:RegisterEffect(e1)
	
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	
	return e1,e2
end

--Protections: Immunity
UNAFFECTED_OTHER	= 0x1
UNAFFECTED_OPPO		= 0x2

function Auxiliary.imother(e,te)
	return e:GetOwner()~=te:GetOwner()
end
function Auxiliary.imoval(e,te)
	return e:GetOwnerPlayer()~=te:GetOwnerPlayer()
end

Auxiliary.UnaffectedProtections={
	[UNAFFECTED_OTHER]	= aux.imother;
	[UNAFFECTED_OPPO]	= aux.imoval;
}
function Card.Unaffected(c,immunity,cond,reset,rc,range,prop,desc)
	local typ = EFFECT_TYPE_SINGLE
	if not reset and not range then
		range = c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	end
	
	local rc = rc and rc or c
    local rct=1
    if type(reset)=="table" then
        rct=reset[2]
        reset=reset[1]
    end
	
	if not prop then prop=0 end
	
	if type(immunity)=="number" then
		immunity=aux.UnaffectedProtections[immunity]
	end
	
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if range then
		prop=prop|EFFECT_FLAG_SINGLE_RANGE
		e:SetRange(range)
	end
	e:SetCode(EFFECT_IMMUNE_EFFECT)
	e:SetValue(immunity)
	if cond then
		e:SetCondition(cond)
	end
	
	if reset then
		if type(reset)~="number" then reset=0 end
		prop=prop|EFFECT_FLAG_CANNOT_DISABLE
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	
	if prop~=0 then
		e:SetProperty(prop)
	end
	
	c:RegisterEffect(e)
	
	return e
end