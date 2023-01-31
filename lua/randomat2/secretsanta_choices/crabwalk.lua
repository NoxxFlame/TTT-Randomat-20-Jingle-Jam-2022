local CHOICE = {}

util.AddNetworkString("RdmtSecretSantaCrabWalkBegin")
util.AddNetworkString("RdmtSecretSantaCrabWalkEnd")

CHOICE.Name = "Crab Walk"
CHOICE.Id = "crabwalk"

function CHOICE:Choose(owner, target)
    net.Start("RdmtSecretSantaCrabWalkBegin")
    net.WriteString(target:SteamID64())
    net.WriteString(owner:SteamID64())
    net.Broadcast()
end

function CHOICE:CleanUp()
    net.Start("RdmtSecretSantaCrabWalkEnd")
    net.Broadcast()
end

function CHOICE:Condition()
    return not Randomat:IsEventActive("crabwalk")
end

SECRETSANTA:RegisterChoice(CHOICE, true)