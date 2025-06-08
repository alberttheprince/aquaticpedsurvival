![image](https://github.com/user-attachments/assets/637b94e9-4083-4bed-b8d5-8bcb6c8315fd)


# Aquatic Ped Survival

A simple drag and drop resource for ensuring aquatic peds in FiveM can survive on land - used with Popcorn RP's snake peds - or so you can swim around on land as a shark, I guess?

This resource was made so that peds that use fish, shark, and other aquatic animal skeletons/metas could survive out of land when used by a player. 

# This resource was made to allow you to use our Burmese Python ped on land, [buy it here](https://popcornrp-store.tebex.io/package/6846326)!

[Preview Video Here](https://www.youtube.com/watch?v=FbyFHM10A2Q)

# Features
- Keeps any aquatic ped added to the config alive, if it leaves water, is switched to while on land, or when logged in
- Allow teleportation and state changes to the ped (i.e. teleporting or noclipping via txadmin) without killing the ped
- Low resmon usage on idle


# Additional Tips (Pets and ped Spawning)

You do not need this resource if you're just using it as a pet through a pet script, instead,  you can use this much simpler method when spawning the ped:

2. For use in a pet script

If you want to use this Python in a ped script, you will need to make use of the following native:

 SetPedSurvivesBeingOutOfWater(ped, true) - https://docs.fivem.net/natives/?_0x100CD221F572F6E1

Look for the CreatePed native in your pet resource and place the above to enable survival out of water, or contact the developer of your resource, and replace 'ped' with the name of the spawned ped as referred to within the function.

We cannot help you if your pet resource is escrowed or paid. Do not contact us regarding paid and/or escrowed pet resource, contact the developer and request they add this to their script to allow snakes and other aquatic peds to survive out of the water.

To do so,  place it where conditions are placed on the pet ped when spawned. For example, below is how it's handled in keep-companion:

```
local function createAPed(hash, pos)
    local ped = nil
    lib.requestModel(hash)

    ped = CreatePed(5, hash, pos.x, pos.y, pos.z, 0.0, true, false)

    while not DoesEntityExist(ped) do
        Wait(10)
    end
    -- This allows aquatic pets to survive out of water, and land peds to survive underwater
    SetPedSurvivesBeingOutOfWater(ped, true)
    --
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, 0)
    SetModelAsNoLongerNeeded(ped)
    return ped
end
```
