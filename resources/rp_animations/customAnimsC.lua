local customAnims = {}

customAnims.dir = "files/customAnims/"

customAnims.parkour = engineLoadIFP( customAnims.dir.."parkour.ifp", "test.myNewBlock" )
customAnims.pompki = engineLoadIFP( customAnims.dir.."pompki.ifp", "pompki.Block" )
customAnims.beach = engineLoadIFP(customAnims.dir.."beach.ifp", "beach.Block")
customAnims.beachlying = engineLoadIFP(customAnims.dir.."beach_lying.ifp", "beachlying.Block")
customAnims.facetsiedzenie = engineLoadIFP(customAnims.dir.."facetsiedzenie.ifp", "facetsiedzenie.Block")
customAnims.car = engineLoadIFP(customAnims.dir.."car.ifp", "car.Block")
customAnims.twerknormal = engineLoadIFP(customAnims.dir.."twerknormal.ifp", "twerk.Block")
customAnims.twerknakrzesle = engineLoadIFP(customAnims.dir.."twerknakrzesle.ifp", "twerkkrzeslo.Block")
customAnims.taniecstriptizerka = engineLoadIFP(customAnims.dir.."taniecstriptizerka.ifp", "taniecstriptizerka.Block")
customAnims.tpose = engineLoadIFP(customAnims.dir.."t-pose.ifp", "tpose.Block")
customAnims.sittingonknees = engineLoadIFP(customAnims.dir.."sitting_on_knees_embrassing.ifp", "sittingonknees.Block")
customAnims.sexcar = engineLoadIFP(customAnims.dir.."sex_car.ifp", "sexcar.Block")
customAnims.polup = engineLoadIFP(customAnims.dir.."polup.ifp", "polup.Block")
customAnims.ganganims = engineLoadIFP(customAnims.dir.."gang_anims.ifp", "ganganims.Block")
customAnims.ganganims2 = engineLoadIFP(customAnims.dir.."gang_anims2.ifp", "ganganims2.Block")
customAnims.ganganims3 = engineLoadIFP(customAnims.dir.."gang_anims3.ifp", "ganganims3.Block")
customAnims.ganganims4 = engineLoadIFP(customAnims.dir.."gang_anims4.ifp", "ganganims4.Block")
customAnims.rekawkieszeni = engineLoadIFP(customAnims.dir.."rekawkieszeni.ifp", "rekawkieszeni.Block")
customAnims.lying_down_with_hand_behind_head = engineLoadIFP(customAnims.dir.."lying_down_with_hand_behind_head.ifp", "lying_down_with_hand_behind_head.Block")
customAnims.dancing = engineLoadIFP(customAnims.dir.."dancing.ifp", "dance.Block")
customAnims.womansitting = engineLoadIFP(customAnims.dir.."woman_sitting.ifp", "womansitting.Block")
customAnims.womansitting2 = engineLoadIFP(customAnims.dir.."woman_sitting2.ifp", "womansitting2.Block")
customAnims.womansitting3 = engineLoadIFP(customAnims.dir.."woman_sitting3.ifp", "womansitting3.Block")
customAnims.kolanko = engineLoadIFP(customAnims.dir.."kolanko.ifp", "kolanko.Block")
customAnims.handsbehindback = engineLoadIFP(customAnims.dir.."hands_behind_back.ifp", "handsbehindback.Block")
customAnims.receplecy = engineLoadIFP(customAnims.dir.."hands_entwined_behind.ifp", "receplecy.Block")
customAnims.kucnij = engineLoadIFP(customAnims.dir.."knee_squat.ifp", "kucnij.Block")
customAnims.opieraj = engineLoadIFP(customAnims.dir.."leaning.ifp", "opieraj.Block")
customAnims.poddajsie = engineLoadIFP(customAnims.dir.."poddajsie.ifp", "poddajsie.Block") -- SHP_HandsUp_Scr
customAnims.beach2 = engineLoadIFP(customAnims.dir.."beach_2.ifp", "beach_2.Block") -- bather
customAnims.zaslontwarz = engineLoadIFP(customAnims.dir.."casino.ifp", "zaslontwarz.Block") -- animacja cards_loop
customAnims.beach3 = engineLoadIFP(customAnims.dir.."beach_3.ifp", "beach3.Block") -- ParkSit_M_loop
customAnims.beach4 = engineLoadIFP(customAnims.dir.."beach_4.ifp", "beach4.Block") -- ParkSit_M_loop
customAnims.lapzaglowe = engineLoadIFP(customAnims.dir.."lapzaglowe.ifp", "lapzaglowe.Block") -- Copbrowse_loop
customAnims.camerajakas = engineLoadIFP(customAnims.dir.."camera_2.ifp", "camerajakas.Block") -- camcrch_cmon
customAnims.beachanother = engineLoadIFP(customAnims.dir.."beachanother.ifp", "beachanother.Block") -- ParkSit_M_loop
customAnims.mdchase = engineLoadIFP(customAnims.dir.."md_chase.ifp", "mdchase.Block") -- MD_HANG_Loop
customAnims.rapping = engineLoadIFP(customAnims.dir.."rapping_1.ifp", "rapping1.Block") -- RAP_A_LOOP, RAP_C_Loop
customAnims.miscanother = engineLoadIFP(customAnims.dir.."miscanother.ifp", "miscanother.Block") -- Plyrlean_loop
customAnims.dealer = engineLoadIFP(customAnims.dir.."dealer.ifp", "dealer.Block") -- DEALER_DEAL
customAnims.dead = engineLoadIFP(customAnims.dir.."dead.ifp", "dead.Block") -- DEALER_DEAL
customAnims.sex = engineLoadIFP(customAnims.dir.."sex.ifp", "sex.Block") -- DEALER_DEAL




function customAnims.handlerAnimations(element, data, nowData)
    if not isElement(element) or getElementType(element) ~= "player" then
        return
    end

    if data == "animation->custom" then
        customAnims.setProperlyAnimation(element)
    end
end
addEventHandler("onLocalDataPlayerChange", root, customAnims.handlerAnimations)


function customAnims.handlerStreamIn()
    local player = source
    setTimer(
        function()
            local animCustomData = exports.rp_login:getPlayerData(player, "animation->custom")
            local animDefaultData = exports.rp_login:getPlayerData(player, "animation->default")
            if animCustomData then
                customAnims.setProperlyAnimation(player)
            elseif animDefaultData then
                customAnims.setDefaultAnimation(player)
            end
        end,
        500,
        1
    )
end
addEventHandler("onClientElementStreamIn", root, customAnims.handlerStreamIn)


function customAnims.setProperlyAnimation(player)
    if getElementType(player) ~= "player" then return end

    local data = exports.rp_login:getPlayerData(player, "animation->custom")
    if not data then return end

    local animName, rz, collision = data[1], data[2], data[3]

    local anim, block, isLooped, updatedPosition
    if animName then
        for _, v in ipairs(tableAnims) do
            if v.commandName == animName then
                anim, block, isLooped, updatedPosition = v.anim, v.block, v.loop, v.updatePosition
                break
            end
        end
    end

    setPedAnimation(player, block, anim, -1, isLooped, updatedPosition, false)
    setElementRotation(player, 0, 0, rz)
    setElementCollisionsEnabled(player, collision)
end


function customAnims.setDefaultAnimation(player)
    if getElementType(player) ~= "player" then return end

    local data = exports.rp_login:getPlayerData(player, "animation->default")
    if not data then return end

    local animName, rz, collision = data[1], data[2], data[3]

    local anim, block, isLooped, updatedPosition
    if animName then
        for _, v in ipairs(tableAnims) do
            if v.commandName == animName then
                anim, block, isLooped, updatedPosition = v.anim, v.block, v.loop, v.updatePosition
                break
            end
        end
    end

    setPedAnimation(player, block, anim, -1, isLooped, updatedPosition, false)
    setElementRotation(player, 0, 0, rz)
    setElementCollisionsEnabled(player, collision)
end
