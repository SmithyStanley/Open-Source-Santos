--[[
	Name: gov_ents.lua
	For: SantosRP
	By: Ultra
]]--

local MapProp = {}
MapProp.ID = "gov_ents"
MapProp.m_tblSpawn = {}
MapProp.m_tblEnts = {
}

function MapProp:CustomSpawn()
	for _, propData in pairs( self.m_tblEnts ) do
		local ent = ents.Create( propData.class )
		ent:SetPos( propData.pos )
		ent:SetAngles( propData.ang )
		ent:SetCollisionGroup( COLLISION_GROUP_NONE )
		ent:SetMoveType( MOVETYPE_NONE )
		ent.IsMapProp = true
		ent.MapPropID = id
		ent:Spawn()
		ent:Activate()

		local phys = ent:GetPhysicsObject()
		if IsValid( phys ) then
			phys:EnableMotion( false )
		end
	end
end

GAMEMODE.Map:RegisterMapProp( MapProp )