--[[
	Name: cop_jail_nobail.lua
	For: TalosLife
	By: TalosLife
]]--

local NPCMeta = {}
NPCMeta.Name = "Jail Warden"
NPCMeta.UID = "cop_jail_nobail"
NPCMeta.SubText = "Turn in criminals here"
NPCMeta.Model = "models/player/santos/cop/male_05.mdl"
NPCMeta.Sounds = {
	StartDialog = {
		"vo/npc/male01/answer30.wav",
		"vo/npc/male01/gordead_ans01.wav",
		"vo/npc/male01/gordead_ques16.wav",
		"vo/npc/male01/hi01.wav",
		"vo/npc/male01/hi02.wav",
	},
	EndDialog = {
		"vo/npc/male01/finally.wav",
		"vo/npc/male01/pardonme01.wav",
		"vo/npc/male01/vanswer01.wav",
		"vo/npc/male01/vanswer13.wav",
	},
}

function NPCMeta:OnPlayerTalk( entNPC, pPlayer )
	if GAMEMODE.Jobs:PlayerIsJob( pPlayer, JOB_POLICE ) then
		GAMEMODE.Net:ShowNPCDialog( pPlayer, "cop_jail_nobail" )
	else
		GAMEMODE.Net:ShowNPCDialog( pPlayer, "cop_jail_warden" )
	end

	if (entNPC.m_intLastSoundTime or 0) < CurTime() then
		local snd, _ = table.Random( self.Sounds.StartDialog )
		entNPC:EmitSound( snd, 60 )
		entNPC.m_intLastSoundTime = CurTime() +2
	end
end

function NPCMeta:OnPlayerEndDialog( pPlayer )
	if not pPlayer:WithinTalkingRange() then return end
	if pPlayer:GetTalkingNPC().UID ~= self.UID then return end

	if (pPlayer.m_entTalkingNPC.m_intLastSoundTime or 0) < CurTime() then
		local snd, _ = table.Random( self.Sounds.EndDialog )
		pPlayer.m_entTalkingNPC:EmitSound( snd, 60 )
		pPlayer.m_entTalkingNPC.m_intLastSoundTime = CurTime() +2
	end

	pPlayer.m_entTalkingNPC = nil
end

if SERVER then
	function NPCMeta:ShowJailTurnInMenu( pPlayer )
		if not GAMEMODE.Jobs:PlayerIsJob( pPlayer, JOB_POLICE ) then return end
		if not pPlayer:WithinTalkingRange() then return end
		if pPlayer:GetTalkingNPC().UID ~= self.UID then return end
		
		GAMEMODE.Net:ShowNWMenu( pPlayer, "cop_jail_turnin" )
	end

	function NPCMeta:ShowJailFreeMenu( pPlayer )
		if not GAMEMODE.Jobs:PlayerIsJob( pPlayer, JOB_POLICE ) then return end
		if not pPlayer:WithinTalkingRange() then return end
		if pPlayer:GetTalkingNPC().UID ~= self.UID then return end

		GAMEMODE.Net:ShowNWMenu( pPlayer, "cop_jail_free" )
	end



	--RegisterDialogEvents is called when the npc is registered! This is before the gamemode loads so GAMEMODE is not valid yet.
	function NPCMeta:RegisterDialogEvents()
		GM.Dialog:RegisterDialogEvent( "cop_open_jail_turnin", self.ShowJailTurnInMenu, self )
		GM.Dialog:RegisterDialogEvent( "cop_open_jail_free", self.ShowJailFreeMenu, self )
	end
elseif CLIENT then
	function NPCMeta:RegisterDialogEvents()
		GM.Dialog:RegisterDialog( "cop_jail_nobail", self.StartDialog, self )
		GM.Dialog:RegisterDialog( "cop_jail_warden_notcop", self.StartDialog_NotACop, self )
	end
	
	function NPCMeta:StartDialog()
		GAMEMODE.Dialog:ShowDialog()
		GAMEMODE.Dialog:SetModel( self.Model )
		GAMEMODE.Dialog:SetTitle( self.Name )
		GAMEMODE.Dialog:SetPrompt( "Yes officer?" )

		GAMEMODE.Dialog:AddOption( "I would like to turn in this criminal with no bail.", function()
			GAMEMODE.Net:SendNPCDialogEvent( "cop_open_jail_turnin" )
			GAMEMODE.Dialog:HideDialog()
		end )
		GAMEMODE.Dialog:AddOption( "I'm here to release someone from jail.", function()
			GAMEMODE.Net:SendNPCDialogEvent( "cop_open_jail_free" )
			GAMEMODE.Dialog:HideDialog()
		end )

		GAMEMODE.Dialog:AddOption( "Never mind, I have to go.", function()
			GAMEMODE.Net:SendNPCDialogEvent( self.UID.. "_end_dialog" )
			GAMEMODE.Dialog:HideDialog()
		end )
	end

	function NPCMeta:StartDialog_NotACop()
		GAMEMODE.Dialog:ShowDialog()
		GAMEMODE.Dialog:SetModel( self.Model )
		GAMEMODE.Dialog:SetTitle( self.Name )
		GAMEMODE.Dialog:SetPrompt( "How can I help you?" )

		GAMEMODE.Dialog:AddOption( "Never mind, I have to go.", function()
			GAMEMODE.Net:SendNPCDialogEvent( self.UID.. "_end_dialog" )
			GAMEMODE.Dialog:HideDialog()
		end )
	end
end

GM.NPC:Register( NPCMeta )