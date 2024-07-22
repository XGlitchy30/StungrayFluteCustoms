local _RegisterEffect = Card.RegisterEffect

local function IsEffectCode(code0,...)
	local x={...}
	for _,code in ipairs(x) do
		if code0==code then
			return true
		end
	end
	return false
end

local function IsPassiveEffect(type)
	local types={EFFECT_TYPE_SINGLE,EFFECT_TYPE_EQUIP,EFFECT_TYPE_TARGET,EFFECT_TYPE_XMATERIAL,EFFECT_TYPE_FIELD}
	for _,t in ipairs(types) do
		if type==t then
			return true
		end
	end
	return false
end

function Auxiliary.TableRemove(t, fnKeep)
    local j, n = 1, #t;

    for i=1,n do
        if (fnKeep(t, i, j)) then
            -- Move i's kept value to j's position, if it's not already there.
            if (i ~= j) then
                t[j] = t[i];
                t[i] = nil;
            end
            j = j + 1; -- Increment position of where we'll place the next kept value.
        else
            t[i] = nil;
        end
    end

    return t;
end


function Card.RegisterEffect(c,eff,...)
	local e=eff
	if e:IsHasType(EFFECT_TYPE_GRANT) then
		e=e:GetLabelObject()
	end
	local type,prop,code,cond,val=e:GetType(),e:GetProperty(),e:GetCode(),e:GetCondition(),e:GetValue()
	
	if IsPassiveEffect(type) and type~=EFFECT_TYPE_SINGLE then
	
		--[[Fix interaction between continuous original stats modifiers and lingering current+original stats modifiers (both activated and non): for example, if Shrink's effect is applied to a monster and Unstable Evolution is later equipped to that monster, the original ATK of that monster should be determined by the effect of Unstable Evolution. Currently, EDOPro applies the effects in an incorrect order, which means that Unstable Evolution's modifier is overwritten by the one of Shrink, even if the former was applied strictly after the latter. The interaction between Darkworld Shackles and Shrink is also problematic, as the ATK of a monster affected by Shackles is supposed to remain unchanged even after Shrink is applied to it.
		REMOVE THIS CODE ONLY AFTER THE BUG IS FIXED IN THE CORE]]
		
		if IsEffectCode(code,EFFECT_SET_BASE_ATTACK,EFFECT_SET_BASE_DEFENSE) and not aux.BaseStatsModCheck then
			aux.BaseStatsModCheck=true
			local ge=Effect.CreateEffect(c)
			ge:SetType(EFFECT_TYPE_FIELD)
			ge:SetCode(EFFECT_SET_ATTACK_FINAL)
			ge:SetProperty(EFFECT_FLAG_REPEAT|EFFECT_FLAG_DELAY)
			ge:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			ge:SetLabel(EFFECT_SET_BASE_ATTACK,EFFECT_SET_BASE_DEFENSE)
			ge:SetTarget(function(E,C)
				aux.PreventBaseStatsModLoop=true
				local elist={C:IsHasEffect(EFFECT_SET_BASE_ATTACK)}
				aux.PreventBaseStatsModLoop=false
				for _,eff in ipairs(elist) do
					if eff:GetType()~=EFFECT_TYPE_SINGLE then
						return true
					end
				end
				
				return false
			end)
			ge:SetValue(function(E,C)
				return C:GetAttack()
			end)
			Duel.RegisterEffect(ge,0)
			local ge2=Effect.CreateEffect(c)
			ge2:SetType(EFFECT_TYPE_FIELD)
			ge2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			ge2:SetProperty(EFFECT_FLAG_REPEAT|EFFECT_FLAG_DELAY)
			ge2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			ge2:SetLabel(EFFECT_SET_BASE_ATTACK,EFFECT_SET_BASE_DEFENSE)
			ge2:SetTarget(function(E,C)
				aux.PreventBaseStatsModLoop=true
				local elist={C:IsHasEffect(EFFECT_SET_BASE_DEFENSE)}
				aux.PreventBaseStatsModLoop=false
				for _,eff in ipairs(elist) do
					if eff:GetType()~=EFFECT_TYPE_SINGLE then
						return true
					end
				end
				
				return false
			end)
			ge2:SetValue(function(E,C)
				return C:GetDefense()
			end)
			Duel.RegisterEffect(ge2,0)
		end
	end
	
	local res=_RegisterEffect(c,e,...)
	
	return res
end

local _GetBaseAttack,_GetBaseDefense,_GetAttack,_GetDefense = Card.GetBaseAttack,Card.GetBaseDefense,Card.GetAttack,Card.GetDefense

aux.TempBaseAttack=math.maxinteger
aux.TempBaseDefense=math.maxinteger
aux.TempAttack=math.maxinteger
aux.TempDefense=math.maxinteger

function Auxiliary.CheckBaseStatsModCondition(c,ignore_linkchk)
	local ecodes={EFFECT_SET_BASE_ATTACK}
	if ignore_linkchk or not c:IsOriginalType(TYPE_LINK) then
		table.insert(ecodes,EFFECT_SET_BASE_DEFENSE)
	end
	for _,ecode in ipairs(ecodes) do
		local elist={c:IsHasEffect(ecode)}
		for _,e in ipairs(elist) do
			if e:GetType()~=EFFECT_TYPE_SINGLE then
				return true
			end
		end
	end
	
	return false
end

function Card.GetBaseAttack(c)
	if not aux.CheckBaseStatsModCondition(c) then
		return _GetBaseAttack(c)
	end
	
	if not c:IsOriginalType(TYPE_MONSTER) and not c:IsMonster() and not c:IsHasEffect(EFFECT_PRE_MONSTER) then
		return 0
	end
	if not c:IsLocation(LOCATION_MZONE) or c:IsStatus(STATUS_SUMMONING|STATUS_SPSUMMON_STEP) then
		return c:GetTextAttack()
	end
	if aux.TempBaseAttack~=math.maxinteger then
		return aux.TempBaseAttack
	end
	
	local batk,bdef=math.max(c:GetTextAttack(),0),math.max(c:GetTextDefense(),0)
	aux.TempBaseAttack=batk
	
	local swap=false
	if not c:IsOriginalType(TYPE_LINK) and c:IsHasEffect(EFFECT_SWAP_BASE_AD) then
		swap=true
	end
	local ecode=swap and EFFECT_SET_BASE_DEFENSE or EFFECT_SET_BASE_ATTACK
	local eset={c:IsHasEffect(ecode)}
	table.sort(eset,function(a,b) return a:GetFieldID() < b:GetFieldID() end)
	
	aux.TableRemove(eset,function(t,i,j)
		local eff=t[i]
		if eff:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE) then
			local code=eff:GetCode()
			if code==EFFECT_SET_BASE_ATTACK then
				batk=math.max(eff:Evaluate(c),0)
				aux.TempBaseAttack=batk
				return false
			elseif code==EFFECT_SET_BASE_DEFENSE then
				bdef=math.max(eff:Evaluate(c),0)
				return false
			end
		end
		return true
	end)
	
	for _,eff in ipairs(eset) do
		local code=eff:GetCode()
		if code==EFFECT_SET_BASE_ATTACK then
			batk=math.max(eff:Evaluate(c),0)
		elseif code==EFFECT_SET_BASE_DEFENSE then
			bdef=math.max(eff:Evaluate(c),0)
		elseif code==EFFECT_SWAP_BASE_AD then
			batk,bdef=bdef,batk
		end
		aux.TempBaseAttack=batk
	end
	
	aux.TempBaseAttack=math.maxinteger
	return batk
end
function Card.GetBaseDefense(c)
	if not aux.CheckBaseStatsModCondition(c,true) then
		return _GetBaseDefense(c)
	end
	if c:IsOriginalType(TYPE_LINK) or (not c:IsOriginalType(TYPE_MONSTER) and not c:IsMonster() and not c:IsHasEffect(EFFECT_PRE_MONSTER)) then
		return 0
	end
	if not c:IsLocation(LOCATION_MZONE) or c:IsStatus(STATUS_SUMMONING|STATUS_SPSUMMON_STEP) then
		return c:GetTextDefense()
	end
	if aux.TempBaseDefense~=math.maxinteger then
		return aux.TempBaseDefense
	end
	
	local batk,bdef=math.max(c:GetTextAttack(),0),math.max(c:GetTextDefense(),0)
	aux.TempBaseDefense=bdef
	
	local swap=false
	if not c:IsOriginalType(TYPE_LINK) and c:IsHasEffect(EFFECT_SWAP_BASE_AD) then
		swap=true
	end
	local ecode=swap and EFFECT_SET_BASE_ATTACK or EFFECT_SET_BASE_DEFENSE
	local eset={c:IsHasEffect(ecode)}
	table.sort(eset,function(a,b) return a:GetFieldID() < b:GetFieldID() end)
	
	aux.TableRemove(eset,function(t,i,j)
		local eff=t[i]
		if eff:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE) then
			local code=eff:GetCode()
			if code==EFFECT_SET_BASE_ATTACK then
				batk=math.max(eff:Evaluate(c),0)
				return false
			elseif code==EFFECT_SET_BASE_DEFENSE then
				bdef=math.max(eff:Evaluate(c),0)
				aux.TempBaseDefense=bdef
				return false
			end
		end
		return true
	end)
	
	for _,eff in ipairs(eset) do
		local code=eff:GetCode()
		if code==EFFECT_SET_BASE_ATTACK then
			batk=math.max(eff:Evaluate(c),0)
		elseif code==EFFECT_SET_BASE_DEFENSE then
			bdef=math.max(eff:Evaluate(c),0)
		elseif code==EFFECT_SWAP_BASE_AD then
			batk,bdef=bdef,batk
		end
		aux.TempBaseDefense=bdef
	end
	
	aux.TempBaseDefense=math.maxinteger
	return bdef
end

function Card.GetAttack(c)
	if not aux.CheckBaseStatsModCondition(c) then
		return _GetAttack(c)
	end
	if not c:IsOriginalType(TYPE_MONSTER) and not c:IsMonster() and not c:IsHasEffect(EFFECT_PRE_MONSTER) then
		return 0
	end
	if not c:IsLocation(LOCATION_MZONE) or c:IsStatus(STATUS_SUMMONING|STATUS_SPSUMMON_STEP) then
		return c:GetTextAttack()
	end
	if aux.TempAttack~=math.maxinteger then
		return aux.TempAttack
	end
	
	local batk,bdef=math.max(c:GetTextAttack(),0),math.max(c:GetTextDefense(),0)
	aux.TempBaseAttack=batk
	aux.TempAttack=batk
	
	local atk=-1
	local up_atk,upc_atk=0,0
	local swap_final=false
	
	local eset={}
	local ecodes={EFFECT_UPDATE_ATTACK,EFFECT_SET_ATTACK,EFFECT_SET_ATTACK_FINAL,EFFECT_SWAP_ATTACK_FINAL,EFFECT_SET_BASE_ATTACK}
	if not c:IsOriginalType(TYPE_LINK) then
		table.insert(ecodes,EFFECT_SWAP_AD)
		table.insert(ecodes,EFFECT_SWAP_BASE_AD)
		table.insert(ecodes,EFFECT_SET_BASE_DEFENSE)
	end
	
	for _,ecode in ipairs(ecodes) do
		local elist={c:IsHasEffect(ecode)}
		for _,e in ipairs(elist) do
			local l1,l2=e:GetLabel()
			if ecode~=EFFECT_SET_ATTACK_FINAL or (l1~=EFFECT_SET_BASE_ATTACK and l2~=EFFECT_SET_BASE_DEFENSE) then
				table.insert(eset,e)
			end
		end
	end
	table.sort(eset,function(a,b) return a:GetFieldID() < b:GetFieldID() end)
	
	local rev=false
	local revset={c:IsHasEffect(EFFECT_REVERSE_UPDATE)}
	for _,e in ipairs(revset) do
		if not e:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE) or not c:IsImmuneToEffect(e) then
			rev=true
			break
		end
	end
	
	local effects_atk,effects_atk_r={},{}
	
	aux.TableRemove(eset,function(t,i,j)
		local eff=t[i]
		if eff:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE) then
			local code=eff:GetCode()
			if code==EFFECT_SET_BASE_ATTACK then
				batk=math.max(eff:Evaluate(c),0)
				aux.TempBaseAttack=batk
				return false
			elseif code==EFFECT_SET_BASE_DEFENSE then
				bdef=math.max(eff:Evaluate(c),0)
				return false
			end
		end
		return true
	end)
	
	aux.TempAttack=batk
	
	local hasActivatedSetStatFinalEffect=false
	local hasContinuousSetStatEffect=false
	for _,eff in ipairs(eset) do
		local code=eff:GetCode()
		local isSingle=eff:IsHasType(EFFECT_TYPE_SINGLE)
		local HasSingleRange=eff:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE)
		local val=eff:Evaluate(c)
		if code==EFFECT_UPDATE_ATTACK then
			if isSingle and not HasSingleRange then
				up_atk = up_atk+val
			else
				upc_atk = upc_atk+val
			end
			
		elseif code==EFFECT_SET_ATTACK then
			atk=val
			if not isSingle or HasSingleRange then
				if not isSingle then
					up_atk=0
				end
				hasContinuousSetStatEffect=true
			end
		
		elseif code==EFFECT_SET_ATTACK_FINAL then
			if isSingle and not HasSingleRange then
				hasActivatedSetStatFinalEffect=true
				atk=val
				up_atk,upc_atk=0,0
			else
				if not eff:IsHasProperty(EFFECT_FLAG_DELAY) then
					table.insert(effects_atk,eff)
				else
					table.insert(effects_atk_r,eff)
				end
			end
			
		elseif code==EFFECT_SET_BASE_ATTACK then
			batk=math.max(val,0)
			if not hasActivatedSetStatFinalEffect and not hasContinuousSetStatEffect then
				atk=-1
			end
		
		elseif code==EFFECT_SWAP_ATTACK_FINAL then
			atk=val
			up_atk,upc_atk=0,0
			
		elseif code==EFFECT_SET_BASE_DEFENSE then
			bdef=math.max(val,0)
			
		elseif code==EFFECT_SWAP_AD then
			swap_final = not swap_final
			
		elseif code==EFFECT_SWAP_BASE_AD then
			batk,bdef=bdef,batk
		end
		
		aux.TempBaseAttack=batk
		aux.TempAttack = math.max(0,(atk<0 and batk or atk) + (up_atk + upc_atk)*(not rev and 1 or -1))
	end
	
	for _,eff in ipairs(effects_atk) do
		aux.TempAttack=eff:Evaluate(c)
	end
	
	if aux.TempDefense==math.maxinteger then
		if swap_final then
			aux.TempAttack=c:GetDefense()
		end
		for _,eff in ipairs(effects_atk_r) do
			aux.TempAttack=eff:Evaluate(c)
			if eff:IsHasProperty(EFFECT_FLAG_REPEAT) then
				aux.TempAttack=eff:Evaluate(c)
			end
		end
	end
	
	atk = math.max(0,aux.TempAttack)
	
	aux.TempBaseAttack=math.maxinteger
	aux.TempAttack=math.maxinteger
	return atk 
end

function Card.GetDefense(c)
	if not aux.CheckBaseStatsModCondition(c,true) then
		return _GetDefense(c)
	end
	if c:IsOriginalType(TYPE_LINK) then
		return 0
	end
	if not c:IsOriginalType(TYPE_MONSTER) and not c:IsMonster() and not c:IsHasEffect(EFFECT_PRE_MONSTER) then
		return 0
	end
	if not c:IsLocation(LOCATION_MZONE) or c:IsStatus(STATUS_SUMMONING|STATUS_SPSUMMON_STEP) then
		return c:GetTextAttack()
	end
	if aux.TempAttack~=math.maxinteger then
		return aux.TempAttack
	end
	
	local batk,bdef=math.max(c:GetTextAttack(),0),math.max(c:GetTextDefense(),0)
	aux.TempBaseDefense=bdef
	aux.TempDefense=bdef
	
	local def=-1
	local up_def,upc_def=0,0
	local swap_final=false
	
	local eset={}
	local ecodes={EFFECT_UPDATE_DEFENSE,EFFECT_SET_DEFENSE,EFFECT_SET_DEFENSE_FINAL,EFFECT_SWAP_DEFENSE_FINAL,EFFECT_SET_BASE_DEFENSE,EFFECT_SWAP_AD,EFFECT_SWAP_BASE_AD,EFFECT_SET_BASE_ATTACK}
	
	for _,ecode in ipairs(ecodes) do
		local elist={c:IsHasEffect(ecode)}
		for _,e in ipairs(elist) do
			local l1,l2=e:GetLabel()
			if ecode~=EFFECT_SET_DEFENSE_FINAL or (l1~=EFFECT_SET_BASE_ATTACK and l2~=EFFECT_SET_BASE_DEFENSE) then
				table.insert(eset,e)
			end
		end
	end
	table.sort(eset,function(a,b) return a:GetFieldID() < b:GetFieldID() end)
	
	local rev=false
	local revset={c:IsHasEffect(EFFECT_REVERSE_UPDATE)}
	for _,e in ipairs(revset) do
		if not e:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE) or not c:IsImmuneToEffect(e) then
			rev=true
			break
		end
	end
	
	local effects_def,effects_def_r={},{}
	
	aux.TableRemove(eset,function(t,i,j)
		local eff=t[i]
		if eff:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE) then
			local code=eff:GetCode()
			if code==EFFECT_SET_BASE_ATTACK then
				batk=math.max(eff:Evaluate(c),0)
				return false
			elseif code==EFFECT_SET_BASE_DEFENSE then
				bdef=math.max(eff:Evaluate(c),0)
				aux.TempBaseDefense=bdef
				return false
			end
		end
		return true
	end)
	
	aux.TempDefense=bdef
	
	local hasActivatedSetStatFinalEffect=false
	local hasContinuousSetStatEffect=false
	for _,eff in ipairs(eset) do
		local code=eff:GetCode()
		local isSingle=eff:IsHasType(EFFECT_TYPE_SINGLE)
		local HasSingleRange=eff:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE)
		local val=eff:Evaluate(c)
		if code==EFFECT_UPDATE_DEFENSE then
			if isSingle and not HasSingleRange then
				up_def = up_def+val
			else
				upc_def = upc_def+val
			end
			
		elseif code==EFFECT_SET_DEFENSE then
			def=val
			if not isSingle or HasSingleRange then
				if not isSingle then
					up_def=0
				end
				hasContinuousSetStatEffect=true
			end
		
		elseif code==EFFECT_SET_DEFENSE_FINAL then
			if isSingle and not HasSingleRange then
				hasActivatedSetStatFinalEffect=true
				def=val
				up_def,upc_def=0,0
			else
				if not eff:IsHasProperty(EFFECT_FLAG_DELAY) then
					table.insert(effects_def,eff)
				else
					table.insert(effects_def_r,eff)
				end
			end
			
		elseif code==EFFECT_SET_BASE_DEFENSE then
			bdef=math.max(val,0)
			if not hasActivatedSetStatFinalEffect and not hasContinuousSetStatEffect then
				def=-1
			end
		
		elseif code==EFFECT_SWAP_DEFENSE_FINAL then
			def=val
			up_def,upc_def=0,0
			
		elseif code==EFFECT_SET_BASE_ATTACK then
			batk=math.max(val,0)
			
		elseif code==EFFECT_SWAP_AD then
			swap_final = not swap_final
			
		elseif code==EFFECT_SWAP_BASE_AD then
			batk,bdef=bdef,batk
		end
		
		aux.TempBaseDefense=bdef
		aux.TempDefense = math.max(0,(def<0 and bdef or def) + (up_def + upc_def)*(not rev and 1 or -1))
	end
	
	for _,eff in ipairs(effects_def) do
		aux.TempDefense=eff:Evaluate(c)
	end
	
	if aux.TempAttack==math.maxinteger then
		if swap_final then
			aux.TempDefense=c:GetAttack()
		end
		for _,eff in ipairs(effects_def_r) do
			aux.TempDefense=eff:Evaluate(c)
			if eff:IsHasProperty(EFFECT_FLAG_REPEAT) then
				aux.TempDefense=eff:Evaluate(c)
			end
		end
	end
	
	def = math.max(0,aux.TempDefense)
	
	aux.TempBaseDefense=math.maxinteger
	aux.TempDefense=math.maxinteger
	return def 
end