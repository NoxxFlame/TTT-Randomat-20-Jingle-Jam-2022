local CHOICE = {}

util.AddNetworkString("RdmtSecretSantaCrouchInvisBegin")
util.AddNetworkString("RdmtSecretSantaCrouchInvisEnd")

CHOICE.Name = "Invisible Crouching"
CHOICE.Id = "crouchinvis"

local crouchinvis_reveal_timer = CreateConVar("randomat_secretsanta_crouchinvis_reveal_timer", "3", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How long to reveal after shooting.", 0, 30)

local hookIds = {}

local function SetPlayerVisibility(ply, visible)
    if visible then
        Randomat:SetPlayerVisible(ply)
    else
        Randomat:SetPlayerInvisible(ply)
    end
    ply:DrawWorldModel(visible)
end

function CHOICE:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local hookId = "RdmtSecretSantaCrouchInvis_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(hookIds, hookId)

    hook.Add("FinishMove", hookId .. "_FinishMove", function(ply, mv)
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or target ~= ply then return end
        SetPlayerVisibility(ply, not ply:Crouching() or ply:GetNWBool("RdmtSecretSantaCrouchInvisRevealed", false))
    end)

    hook.Add("PlayerDeath", hookId .. "_PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) or target ~= victim then return end
        SetPlayerVisibility(ply, true)
    end)

    hook.Add("EntityFireBullets", hookId .. "_EntityFireBullets", function(entity, data)
        if not IsPlayer(entity) or target ~= entity then return end
        local reveal_time = crouchinvis_reveal_timer:GetInt()
        if reveal_time > 0 then
            entity:SetNWBool("RdmtSecretSantaCrouchInvisRevealed", true)
            timer.Create("RdmtTSecretSantaCrouchInvisRevealTimer_" .. entity:SteamID64(), reveal_time, 1, function()
                entity:SetNWBool("RdmtSecretSantaCrouchInvisRevealed", false)
            end)
        end
    end)

    net.Start("RdmtSecretSantaCrouchInvisBegin")
    net.WriteString(target:SteamID64())
    net.WriteString(owner:SteamID64())
    net.Broadcast()
end

function CHOICE:CleanUp()
    for _, hookId in ipairs(hookIds) do
        hook.Remove("FinishMove", hookId .. "_FinishMove")
        hook.Remove("PlayerDeath", hookId .. "_PlayerDeath")
        hook.Remove("EntityFireBullets", hookId .. "_EntityFireBullets")
    end
    table.Empty(hookIds)

    for _, p in ipairs(player.GetAll()) do
        SetPlayerVisibility(p, true)
        timer.Remove("RdmtTSecretSantaCrouchInvisRevealTimer_" .. p:SteamID64())
    end

    net.Start("RdmtSecretSantaCrouchInvisEnd")
    net.Broadcast()
end

function CHOICE:AddConVars(sliders, checks, textboxes)
    for _, v in ipairs({"reveal_timer"}) do
        local name = "randomat_secretsanta_" .. self.Id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = self.Id .. "_" .. v,
                dsc = self.Name .. " - " .. convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end
end

function CHOICE:Condition()
    return not Randomat:IsEventActive("trexvision") and not Randomat:IsEventActive("gaseous")
end

SECRETSANTA:RegisterChoice(CHOICE)