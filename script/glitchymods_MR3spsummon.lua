Glitchy.MR3SpSummonEffectOperation = {}

local _GetLocationCountFromEx, _SpecialSummonStep, _SpecialSummon, _SpecialSummonComplete, PendFilter = Duel.GetLocationCountFromEx, Duel.SpecialSummonStep, Duel.SpecialSummon, Duel.SpecialSummonComplete, Pendulum.Filter

if not Duel.GetOriginalLocationCountFromEx then
	Duel.GetOriginalLocationCountFromEx = function(p,up,mg,c,...)
		return _GetLocationCountFromEx(p,up,mg,c,...)
	end
end

function Duel.GetLocationCountFromEx(p,up,mg,c,...)
	if not up then up=p end
	local resetTable={}
	local eset={Duel.GetPlayerEffect(p,EFFECT_ALLOW_MR3_SPSUMMON_FROM_ED)}
	if type(c)=="Card" then
		for _,e in ipairs(eset) do
			local tg=e:GetTarget()
			if not tg or tg(e,c) then
				local ep=e:GetOwnerPlayer()
				local zones=e:GetValue()
				if up==1-ep then
					zones=zones>>16
				end
				zones=zones&0x7f
				local e1=Effect.GlobalEffect()
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
				e1:SetValue(zones)
				Duel.RegisterEffect(e1,ep)
				table.insert(resetTable,e1)
			end
		end
	elseif #eset>0 then
		return _GetLocationCountFromEx(p,up,mg,c,...)+Duel.GetMZoneCount(p,mg,up)
	end
	local res,zones=_GetLocationCountFromEx(p,up,mg,c,...)
	for _,e in ipairs(resetTable) do
		e:Reset()
	end
	return res,zones
end
function Duel.SpecialSummonStep(c,sumtype,up,p,ign1,ign2,pos,zn,...)
	zn = zn or 0xff
	local e1
	local eset={Duel.GetPlayerEffect(p,EFFECT_ALLOW_MR3_SPSUMMON_FROM_ED)}
	local descs,validEffs={},{}
	for _,e in ipairs(eset) do
		local tg=e:GetTarget()
		if not tg or tg(e,c) then
			table.insert(descs,e:GetDescription())
			table.insert(validEffs,e)
		end
	end
	local mr3_eff
	local ct=#validEffs
	if ct>0 then
		local opt=Duel.SelectOption(up,STRING_DO_NOT_APPLY,table.unpack(descs))
		if opt>0 then
			mr3_eff=validEffs[opt]
		end
	end
	
	if mr3_eff then
		local ep=mr3_eff:GetOwnerPlayer()
		local zones=mr3_eff:GetValue()
		if up==1-ep then
			zones=zones>>16
		end
		zones=zones&0x7f
		zn=zn&zones
		e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
		e1:SetValue(zones)
		Duel.RegisterEffect(e1,ep)
		
		local op=mr3_eff:GetOperation()
		if op then
			if not xgl.MR3SpSummonEffectOperation[mr3_eff] then
				xgl.MR3SpSummonEffectOperation[mr3_eff]={op,ep,up,c}
			end
		end
	end
	
	local res=_SpecialSummonStep(c,sumtype,up,p,ign1,ign2,pos,zn,...)
	if e1 then e1:Reset() end
	return res
end
function Duel.SpecialSummon(g,sumtype,up,p,ign1,ign2,pos,zn,...)
	zn = zn or 0xff
	local eset={Duel.GetPlayerEffect(p,EFFECT_ALLOW_MR3_SPSUMMON_FROM_ED)}
	
	if #eset>0 then
		local e1
		if type(g)=="Card" and g:IsLocation(LOCATION_EXTRA) then
			local descs,validEffs={},{}
			for _,e in ipairs(eset) do
				local tg=e:GetTarget()
				if not tg or tg(e,g) then
					table.insert(descs,e:GetDescription())
					table.insert(validEffs,e)
				end
			end
			local mr3_eff
			local ct=#validEffs
			if ct>0 then
				local opt=Duel.SelectOption(up,STRING_DO_NOT_APPLY,table.unpack(descs))
				if opt>0 then
					mr3_eff=validEffs[opt]
				end
			end
			
			if mr3_eff then
				local ep=mr3_eff:GetOwnerPlayer()
				local zones=mr3_eff:GetValue()
				if up==1-ep then
					zones=zones>>16
				end
				zones=zones&0x7f
				zn=zn&zones
				e1=Effect.GlobalEffect()
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
				e1:SetValue(zones)
				Duel.RegisterEffect(e1,ep)
				
				local op=mr3_eff:GetOperation()
				if op then
					op(mr3_eff,ep,c)
				end
			end
			
			local res=_SpecialSummon(g,sumtype,up,p,ign1,ign2,pos,zn,...)
			if e1 then e1:Reset() end
			return res
			
		elseif type(g)=="Group" and g:IsExists(Card.IsLocation,1,nil,LOCATION_EXTRA) then
			
			local validAssignments = xgl.GetZoneAssignmentsForGroup(g,p,up)
			
			if #validAssignments==0 then
				Debug.Message("Glitchy warns: impossible to apply ALLOW_MR3_SPSUMMON_FROM_ED. Using regular Special Summon procedure")
				return _SpecialSummon(g,sumtype,up,p,ign1,ign2,pos,zn,...)
			else
				local tempDisableEffs,alreadyChosen,ogct={},{},0
						
				for tc in g:Iter() do	
					if not tc:IsLocation(LOCATION_EXTRA) then
						local z = 0x7f & ~(select(2, Duel.GetLocationCount(p, LOCATION_MZONE, up)))
						alreadyChosen[tc]=z
					else
						local validZones = 0
						for _,tab in ipairs(validAssignments) do
							local z=tab[tc]
							local ct,goal=0,0
							for c,cz in pairs(tab) do
								if alreadyChosen[c] then
									goal=goal+1
									if alreadyChosen[c]&cz>0 then
										ct=ct+1
									end
								end
							end
							if ct==goal then
								validZones = validZones|z
							end
						end
						
						
						local e1,e2
						local descs,validEffs={},{}
						for _,e in ipairs(eset) do
							local tg=e:GetTarget()
							local zones=e:Evaluate(tc)
							if (not tg or tg(e,tc)) and validZones&zones>0 then
								table.insert(descs,e:GetDescription())
								table.insert(validEffs,e)
							end
						end
						local mr3_eff
						local ct=#validEffs
						
						if ct>0 then
							Duel.ConfirmCards(up,tc)
							if Duel.GetOriginalLocationCountFromEx(p,up,nil,tc)-ogct<=0 then
								local opt=Duel.SelectOption(up,table.unpack(descs))
								mr3_eff=validEffs[opt+1]
							else
								local opt=Duel.SelectOption(up,STRING_DO_NOT_APPLY,table.unpack(descs))
								if opt>0 then
									mr3_eff=validEffs[opt]
								end
							end
						end
						
						if mr3_eff then
							local ep=mr3_eff:GetOwnerPlayer()
							local zones=mr3_eff:Evaluate(tc)
							if tp==1-ep then
								zones=zones>>16
							end
							zones=zones&validZones
							alreadyChosen[tc]=zones
							e1=Effect.GlobalEffect()
							e1:SetType(EFFECT_TYPE_FIELD)
							e1:SetProperty(EFFECT_FLAG_OATH)
							e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
							e1:SetValue(zones)
							Duel.RegisterEffect(e1,ep)
							table.insert(tempDisableEffs,e1)
							
							e2=Effect.CreateEffect(tc)
							e2:SetType(EFFECT_TYPE_SINGLE)
							e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_OATH)
							e2:SetCode(EFFECT_FORCE_MZONE)
							e2:SetValue(zones)
							e2:SetReset(RESET_EVENT|RESETS_STANDARD)
							tc:RegisterEffect(e2)
							
							local op=mr3_eff:GetOperation()
							if op then
								if not xgl.MR3SpSummonEffectOperation[mr3_eff] then
									xgl.MR3SpSummonEffectOperation[mr3_eff]={op,p,up,tc}
								end
							end
							
						elseif ct>0 then
							ogct = ogct+1
							for _,tde in ipairs(tempDisableEffs) do
								tde:SetCondition(aux.FALSE)
							end
							local _,zones=Duel.GetOriginalLocationCountFromEx(p,up,nil,tc)
							for _,tde in ipairs(tempDisableEffs) do
								tde:SetCondition(aux.TRUE)
							end
							
							local z=(~zones)&0x7f
							alreadyChosen[tc]=z
							
							e2=Effect.CreateEffect(tc)
							e2:SetType(EFFECT_TYPE_SINGLE)
							e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_OATH)
							e2:SetCode(EFFECT_FORCE_MZONE)
							e2:SetValue(z)
							e2:SetReset(RESET_EVENT|RESETS_STANDARD)
							tc:RegisterEffect(e2)
						end
						
						local res=_SpecialSummonStep(tc,sumtype,up,p,ign1,ign2,pos,zn,...)
						if e1 then
							e1:Reset()
							e1=nil
						end
						if e2 then
							e2:Reset()
							e2=nil
						end
					end
				end
				
				return Duel.SpecialSummonComplete()
			end
		end
	end
	
	return _SpecialSummon(g,sumtype,up,p,ign1,ign2,pos,zn,...)
end
function Duel.SpecialSummonComplete()
	for e,tab in pairs(xgl.MR3SpSummonEffectOperation) do
		local op,ep,up,c=table.unpack(tab)
		op(e,ep,up,c)
	end
	xgl.ClearTableRecursive(xgl.MR3SpSummonEffectOperation)
	return _SpecialSummonComplete()
end
function Pendulum.Filter(c,e,tp,lscale,rscale,lvchk,...)
	return PendFilter(c,e,tp,lscale,rscale,lvchk,...) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end