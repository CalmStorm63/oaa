LinkLuaModifier('modifier_is_in_offside', 'modifiers/modifier_offside.lua', LUA_MODIFIER_MOTION_NONE)

if ProtectionAura == nil then
  DebugPrint ( 'Creating new ProtectionAura object.' )
  ProtectionAura = class({})
  Debug.EnabledModules['cave:protection'] = true
end

local MAX_ROOMS = 6

function ProtectionAura:Init ()
  ProtectionAura.zones = {
    [DOTA_TEAM_GOODGUYS] = {},
    [DOTA_TEAM_BADGUYS] = {},
  }

  for roomID = 0,MAX_ROOMS do
    ProtectionAura.zones[DOTA_TEAM_GOODGUYS][roomID] = ZoneControl:CreateZone('boss_good_zone_' .. roomID, {
      mode = ZONE_CONTROL_EXCLUSIVE_OUT,
      margin = 0,
      padding = 0,
      players = {}
    })

    ProtectionAura.zones[DOTA_TEAM_GOODGUYS][roomID].onStartTouch(ProtectionAura.StartTouchGood)
    ProtectionAura.zones[DOTA_TEAM_GOODGUYS][roomID].onEndTouch(ProtectionAura.EndTouchGood)
  end

  for roomID = 0,MAX_ROOMS do
    ProtectionAura.zones[DOTA_TEAM_BADGUYS][roomID] = ZoneControl:CreateZone('boss_bad_zone_' .. roomID, {
      mode = ZONE_CONTROL_EXCLUSIVE_OUT,
      margin = 0,
      padding = 0,
      players = {}
    })

    ProtectionAura.zones[DOTA_TEAM_BADGUYS][roomID].onStartTouch(ProtectionAura.StartTouchBad)
    ProtectionAura.zones[DOTA_TEAM_BADGUYS][roomID].onEndTouch(ProtectionAura.EndTouchBad)
  end

  ProtectionAura.active = true

end

function ProtectionAura:IsInEnemyZone(teamID, entity)
  for roomID = 0,MAX_ROOMS do
    if ProtectionAura:IsInSpecificZone(teamID, roomID, entity) then
      return true
    end
  end
  return false
end

function ProtectionAura:IsInSpecificZone(teamID, roomID, entity)
  local zone = self.zones[teamID][roomID]
  return zone.handle:IsTouching(entity)
end

function ProtectionAura:StartTouchGood(event)
  if event.activator:GetTeam() ~= DOTA_TEAM_GOODGUYS then
    if not event.activator:HasModifier("modifier_is_in_offside") then
      return event.activator:AddNewModifier(event.activator, nil, "modifier_is_in_offside", {})
    end
  end
end

function ProtectionAura:EndTouchGood(event)
  if not ProtectionAura:IsInEnemyZone(DOTA_TEAM_GOODGUYS, event.activator) then
    event.activator:RemoveModifierByName("modifier_is_in_offside")
  end
end

function ProtectionAura:StartTouchBad(event)
  if event.activator:GetTeam() ~= DOTA_TEAM_BADGUYS then
    if not event.activator:HasModifier("modifier_is_in_offside") then
      return event.activator:AddNewModifier(event.activator, nil, "modifier_is_in_offside", {})
    end
  end
end

function ProtectionAura:EndTouchBad(event)
  if not ProtectionAura:IsInEnemyZone(DOTA_TEAM_BADGUYS, event.activator) then
    event.activator:RemoveModifierByName("modifier_is_in_offside")
  end
end
