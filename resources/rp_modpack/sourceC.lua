function createObjectOrBuilding(modelID, x, y, z, rx, ry, rz, interior, dimension)
    -- Validate the arguments passed
    assert(type(modelID)=="number", "invalid modelID passed: " .. tostring(modelID))
    assert(type(x)=="number" and type(y)== "number" and type(z)=="number", "invalid position passed: " .. tostring(x) .. ", " .. tostring(y) .. ", " .. tostring(z))
    if not rx then rx = 0 end
    if not ry then ry = 0 end
    if not rz then rz = 0 end
    assert(type(rx)=="number" and type(ry)== "number" and type(rz)=="number", "invalid rotation passed: " .. tostring(rx) .. ", " .. tostring(ry) .. ", " .. tostring(rz))
    if not interior then interior = 0 end
    if not dimension then dimension = 0 end
    assert(type(interior)=="number" and interior >= 0 and interior <= 255, "invalid interior (must be 0-255) passed: " .. tostring(interior))
    assert(type(dimension)=="number" and dimension >= -1 and dimension <= 65535, "invalid dimension passed (must be -1 65535): " .. tostring(dimension))

    -- Dynamic object models will always have a physical properties group different than -1.
    local isNonDynamic = engineGetModelPhysicalPropertiesGroup(modelID) == -1
    -- Buildings can't be affected by dimension
    local isNormalDimension = dimension == 0
    -- Buildings can't be placed outside regular map boundaries
    local isInsideMapLimits = x >= -3000 and x <= 3000 and y >= -3000 and y <= 3000

    local obj, bld
    if isNonDynamic and isNormalDimension and isInsideMapLimits then
        bld = createBuilding(modelID, x, y, z, rx, ry, rz, interior)
        assert(bld, ("Failed to create building with model ID %d at %f, %f, %f in interior %d"):format(modelID, x, y, z, interior))
    else
        obj = createObject(modelID, x, y, z, rx, ry, rz, false)
        assert(obj, ("Failed to create object with model ID %d at %f, %f, %f"):format(modelID, x, y, z))
        setElementInterior(obj, interior)
        setElementDimension(obj, dimension)
    end
    return obj or bld
end

-- txd = engineLoadTXD ("models/twsp.txd", 5418)
-- engineImportTXD(txd, 5418)
-- dff = engineLoadDFF ("models/twsp.dff", 5418)
-- engineReplaceModel(dff, 5418, true)
-- col = engineLoadCOL("models/twsp.col")
-- engineReplaceCOL(col, 5418)

-- removeWorldModel(1522, 2, 2104.4814453125,-1806.40625,13.5546875)
-- removeWorldModel(1676, 99999, 2104.4814453125,-1806.40625,13.5546875)

local buildings = {
-- [5393] = {"SouthCentral/eastshops1_lae", "SouthCentral/laeshop1"}, -- txd, dff, col
-- [5392] = {"SouthCentral/eastshops1_lae", "SouthCentral/laestripmall1"},
-- [5638] = {"SouthCentral/laealpha", "SouthCentral/laealpha7", {2184.5, -1179.33, 36.4062, 0, 0, 0}, 0},
-- [17563] = {"SouthCentral/lae2tempshit", "SouthCentral/wattspark1_lae2"},
-- [4559] = {"SouthCentral/lanlacma_lan2", "SouthCentral/lacmabase1_lan"},
-- [1308] = {"SouthCentral/telegraph", "SouthCentral/telgrphpole02"},
[5423] = {"jefferson2/jeffers4_lae", "jefferson2/laejeffers03"},
[5414] = {"jefferson2/jeffers5a_lae", "jefferson2/laejeffers02", {2112.73, -1178.47, 27.3359, 0, 0, -90}, 5468},
-- [5437] = {"SouthCentral/laeroads2s", "SouthCentral/laeroad08"},
-- [5492] = {"SouthCentral/laeroads2s", "SouthCentral/laeroad27"},
[5426] = {"jefferson2/jeffers4_lae", "jefferson2/laejeffers06"},
[5406] = {"jefferson2/jeffers5a_lae", "jefferson2/laecrackmotel4"},
[5459] = {"jefferson2/glenpark1_lae", "jefferson2/laejeffers01", {2123.94, -1159, 24.1641, 0, 0, 0}, 0, "jefferson2/laejeffers01"}, -- 5610

-- [5650] = {"SouthCentral/laeroads2s", "SouthCentral/laeroad03b"},
-- [5490] = {"SouthCentral/laeroads2s", "SouthCentral/laeroad25"},
-- [5432] = {"SouthCentral/laeroads2s", "SouthCentral/laeroad03"},
-- [5483] = {"SouthCentral/laeroads2s", "SouthCentral/laeroad17"},
-- [5435] = {"SouthCentral/laeroads2s", "SouthCentral/laeroad06"},
-- [5493] = {"SouthCentral/laeroads2s", "SouthCentral/laeroad28"},
-- [5482] = {"SouthCentral/laeroads2s", "SouthCentral/laeroad16"},
-- [5491] = {"SouthCentral/laeroads2s", "SouthCentral/laeroad26"},
-- [5458] = {"SouthCentral/macpark1tr_lae", "SouthCentral/laemacpark01", {1995.02, -1198.35, 21.1094, 0, 0, 0}, 0}, --5460
[5413] = {"jefferson2/motel_lae", "jefferson2/laecrackmotel1", {2222.99, -1162.6, 30.0391, 0, 0, 0}, 5612},
-- [2296] = {"SouthCentral/cj_furniture", "SouthCentral/tv_unit_1"},
-- [1828] = {"SouthCentral/kbtgr_rug", "SouthCentral/man_sdr_rug"},
-- [17508] = {"18mapp/barrio1_lae2", "18mapp/blockk_lae2"},
-- [17503] = {"18mapp/furniture_lae2", "18mapp/furniture_lae", {2386.64, -1454.34, 27.2266, 0, 0, 0}, 17735},
-- [5723] = {"ap13/Grafitis/sunrise01_lawn", "ap13/Grafitis/manns04_LAwN"},
-- [5721] = {"ap13/Grafitis/sunrise10_lawn", "ap13/Grafitis/holbuild04_law"},
-- [5727] = {"ap13/Grafitis/sunrise04_lawn", "ap13/Grafitis/holbuild10_law"},
-- [5769] = {"ap13/sunrise09_lawn", "ap13/Hollywood_Land_Cleaners/VineBlock1_LAwN"}, -- moze byc blad z tekstura
-- [5887] = {"ap13/sunrise09_lawn", "ap13/W._Hollywood_Park/FredBlock_LAwN"},
-- [4892] = {"sereno/kbgarage_las", "sereno/kbsgarage2_las"},
-- [4156] = {"littletokyo/lanroad", "littletokyo/roads17_lan"},
-- [4233] = {"littletokyo/lanroad", "littletokyo/roads05_lan"},
-- [4176] = {"littletokyo/civic03_lan", "littletokyo/bailbonds2_lan"},
-- [4178] = {"littletokyo/civic03_lan", "littletokyo/bailbonds3_lan"},
-- [4152] = {"littletokyo/lanroad", "littletokyo/roads15_lan"},
-- [4059] = {"littletokyo/fighot", "littletokyo/fighotblok3_lan"},
-- [4088] = {"littletokyo/lanroad", "littletokyo/supports04_lan"},
-- [4060] = {"littletokyo/fighot", "littletokyo/fighotblok4_lan"},
-- [4647] = {"skidrow/roadlan2", "skidrow/road11_lan2"},
-- [4555] = {"skidrow/sunset1_lan2", "skidrow/figfree4_lan"},
-- [6040] = {"Venice/law_cnrtplaz", "Venice/wilshire7_law"},
-- [6187] = {"Venice/law_beach2", "Venice/gaz26_law"},
-- [6231] = {"Venice/roads_law", "Venice/canalroad01_law"},
-- [6229] = {"Venice/canalsg_law", "Venice/canaleast01_law"},
-- [6227] = {"Venice/canalsg_law", "Venice/canalwest01_law"},
-- [6065] = {"Venice/law_beach2", "Venice/labeach_04bx"},
-- [3642] = {"Venice/glenphouse_lax", "Venice/glenphouse03_lax"},
-- [6225] = {"Venice/roads_law", "Venice/lawroads_law04"},
-- [6124] = {"Venice/roads_law", "Venice/lawroads_law18"},
-- [6120] = {"Venice/roads_law", "Venice/lawroads_law14"},
-- [6119] = {"Venice/roads_law", "Venice/lawroads_law13"},
-- [6111] = {"Venice/roads_law", "Venice/lawroads_law05"},
-- [6145] = {"Venice/venice_law", "Venice/gaz16_law"},
-- [17538] = {"boyleheights/losflor4_lae2", "boyleheights/powerstat1_lae2"},
-- [3715] = {"boyleheights/archlax", "boyleheights/arch_sign"},
-- [17645] = {"boyleheights/landlae2b", "boyleheights/lae2_ground12"},
-- [17542] = {"boyleheights/eastls1b_lae2", "boyleheights/gangshops6_lae2", {2347.92, -1364.29, 27.1562, 0, 0, 0}, 17966},
-- [5627] = {"boyleheights/railtracklae", "boyleheights/lasbrid1sjm_lae"},
-- [17529] = {"boyleheights/eastls1_lae2", "boyleheights/gangshops2_lae2"},
[3698] = {"industrial/comedbarrio1_la", "industrial/barrio3b_lae"},
-- [17634] = {"boyleheights/landlae2b", "boyleheights/lae2_ground09"},
-- [17543] = {"boyleheights/eastls1b_lae2", "boyleheights/gangshops5_lae2", {2322.28, -1355.2, 25.4062, 0, 0, 0}, 17965},
-- [3651] = {"boyleheights/ganghouse1_lax", "boyleheights/ganghous04_lax"},
-- [17526] = {"boyleheights/eastls1_lae2", "boyleheights/gangshops1_lae"},
-- [17641] = {"boyleheights/lae2roads", "boyleheights/lae2_roads33"},
-- [3646] = {"boyleheights/ganghouse1_lax", "boyleheights/ganghous05_lax"},
-- [3648] = {"boyleheights/ganghouse1_lax", "boyleheights/ganghous02_lax"},
-- [3655] = {"boyleheights/ganghouse1_lax", "boyleheights/ganghous03_lax"},
-- [17544] = {"boyleheights/eastls1b_lae2", "boyleheights/gangshops4_lae2"},
-- [17635] = {"boyleheights/landlae2b", "boyleheights/lae2_ground10"},
-- [17640] = {"boyleheights/lae2roads", "boyleheights/lae2_roads32"},
-- [17633] = {"boyleheights/burnsground", "boyleheights/lae2_ground08", {2337.22, -1228.52, 24.7422, 0, 0, 0}, 0}, -- 17723
-- [17628] = {"boyleheights/lae2roads", "boyleheights/lae2_roads24"},
-- [17527] = {"boyleheights/eastlstr_lae2", "boyleheights/gangblock1tr_lae"},
-- [17552] = {"boyleheights/eastls3_lae2", "boyleheights/burnhous1_lae2"},
-- [3697] = {"boyleheights/comedprj1_la", "boyleheights/project2lae2"},
-- [17643] = {"boyleheights/lae2roads", "boyleheights/lae2_roads34"},
-- [17647] = {"boyleheights/lae2roads", "boyleheights/lae2_roads37"},
-- [17646] = {"boyleheights/lae2roads", "boyleheights/lae2_roads36"},
-- [17644] = {"boyleheights/lae2roads", "boyleheights/lae2_roads35"},
-- [17625] = {"boyleheights/lae2roads", "boyleheights/lae2_roads21"},
-- [17627] = {"boyleheights/lae2roads", "boyleheights/lae2_roads23"},
-- [17637] = {"boyleheights/lae2roads", "boyleheights/lae2_roads29"},
-- [17631] = {"boyleheights/lae2roads", "boyleheights/lae2_roads27"},
-- [17632] = {"boyleheights/lae2roads", "boyleheights/lae2_roads28"},
-- [17626] = {"boyleheights/lae2roads", "boyleheights/lae2_roads22"},
-- [17629] = {"boyleheights/lae2roads", "boyleheights/lae2_roads25"},
-- [17630] = {"boyleheights/lae2roads", "boyleheights/lae2_roads26"},
-- [17642] = {"boyleheights/lae2roads", "boyleheights/lae2_roads90"},
-- [17636] = {"boyleheights/landlae2b", "boyleheights/lae2_ground11"},
-- [3649] = {"boyleheights/ganghouse1_lax", "boyleheights/ganghous01_lax"},
-- [17520] = {"crystal/lae2newtempbx", "crystal/market1_lae"},
-- [17548] = {"crystal/landlae2", "crystal/lae2_ground05"},
-- [17875] = {"comptonrancho/hub_alpha", "comptonrancho/hubst2_alpha"},
-- [17620] = {"comptonrancho/landhub", "comptonrancho/Lae2_landHUB01", {2281.21, -1695.65, 13.4453, 0, 0, 0}, 17842},
-- [17515] = {"crystal/ganton01_lae2", "crystal/scumgym1_LAe", {2260, -1707.73, 17.1719, 0, 0, 0}, 17758},
-- [3590] = {"comptonrancho/comedhos1_la", "comptonrancho/compfukhouse2"},
-- [17574] = {"comptonrancho/landhub", "comptonrancho/rydbkyar1_lae2"},
-- [762] = {"comptonrancho/gta_proc_bush", "comptonrancho/new_bushtest"}, -- test
-- [17881] = {"comptonrancho/landhub", "comptonrancho/hub5_grass"},
-- [17938] = {"comptonrancho/stormd_fill", "comptonrancho/stormd_fillc"},
-- [17615] = {"comptonrancho/landhub", "comptonrancho/lae2_landhub03"},
-- [17879] = {"comptonrancho/hub_alpha", "comptonrancho/hubst4alpha"},
-- [5173] = {"comptonrancho/lasground_las2", "comptonrancho/las2jmscum12", {2768.45, -2012.09, 14.7969, 0, 0, 0}, 5256},
-- [5144] = {"comptonrancho/lasground_las2", "comptonrancho/las2jmscum11", {2768.56, -1942.7, 11.3047, 0, 0, 0}, 5258},
-- [5407] = {"inglewood/glenpark1x_lae", "inglewood/laelasruff201", {2041.65, -1682.19, 12.5703, 0, 0, 0}, 5547}, -- 5547
[5016] = {"pueblo/ground3_las", "pueblo/snpdpess1_las"},
-- [4857] = {"sereno/oldshops_las", "sereno/snpedmtsp1_las"},
[3588] = {"pueblo/sanpedhse_1x", "pueblo/sanped_hse1_LAs"},
-- [4861] = {"sereno/ground4_las", "sereno/snpedhuair2_las"},
[4850] = {"pueblo/oldshops_las", "pueblo/snpedshpblk07"},
-- [4808] = {"sereno/lasroads_las", "sereno/laroadss_30_las"},
[3557] = {"jefferson2/comedhos1_la", "jefferson2/compmedhos4_lae"},
[4873] = {"ariaspark/railway_las", "ariaspark/unionstwarc2_las"},
[17841] = {"ramonagardens/gymblok2_lae2", "ramonagardens/gymblok2_lae2", {}, 0, "ramonagardens/gymblok2_lae2"},
[5121] = {"washington/lasroads_las2", "washington/btoland6_las2"},
[5052] = {"washington/lasroads_las", "washington/btoroad1vb_las"},
[4895] = {"washington/lasroads_las", "washington/lstrud_las"},
[5026] = {"washington/lasroads_las", "washington/lstrudct1_las"},
[3587] = {"washington/snpedhusxref", "washington/nwsnpedhus1_las"},
[5139] = {"washington/wasteland_las2", "washington/sanpedro4_las2"},
[4858] = {"washington/ground5_las", "washington/snpedland1_las"},
[5040] = {"washington/shopliquor_las", "washington/unionliq_las", {}, 0, "washington/unionliq_las"}, --[17841] = {"ramonagardens/gymblok2_lae2", "ramonagardens/gymblok2_lae2", {}, 0, "ramonagardens/gymblok2_lae2"},

[4859] = {"pueblo/ground5_las", "pueblo/snpedland2_LAS"},
-- [3582] = {"inglewood/comedhos1_la", "inglewood/compmedhos1_lae"},
-- [3555] = {"inglewood/comedhos1_la", "inglewood/compmedhos2_lae"},
-- [3556] = {"inglewood/comedhos1_la", "inglewood/compmedhos3_lae"},
-- [3558] = {"inglewood/comedhos1_la", "inglewood/compmedhos5_lae"},
-- [5633] = {"inglewood/laealpha", "inglewood/laealpha1"},
-- [5442] = {"inglewood/laeroads2s", "inglewood/laeroad13"},
-- [5504] = {"inglewood/laeroads2s", "inglewood/laeroad39"},
-- [5505] = {"inglewood/laeroads2s", "inglewood/laeroad40"},
-- [5506] = {"inglewood/laeroads2s", "inglewood/laeroad41"},
-- [5507] = {"inglewood/laeroads2s", "inglewood/laeroad42"},
-- [5421] = {"inglewood/laesmokecnthus", "inglewood/laesmokeshse"},
-- [673] = {"", "inglewood/sm_bevhiltree"},
[5476] = {"panopticon/idlewood46_lae", "panopticon/laeidleproj01"},
[5475] = {"panopticon/idlewood46_lae", "panopticon/laeidleproj02"},
[5474] = {"panopticon/idlewood46_lae", "panopticon/laeidlewood02"},
[5441] = {"panopticon/laeroads2s", "panopticon/laeroad12"},
[5501] = {"panopticon/laeroads2s", "panopticon/laeroad36"},
[5504] = {"panopticon/laeroads2s", "panopticon/laeroad39"},
[5504] = {"panopticon/laeroads2s", "panopticon/laeroad39"},
[5329] = {"fremontpark/lasroads_las2", "fremontpark/btoroadsp3_las2"},
[5141] = {"fremontpark/lasroads_las2", "fremontpark/BTOROADxtra_las2"},
[5330] = {"fremontpark/lasroads_las2", "fremontpark/BTOROAsp2_las2"},
[5168] = {"fremontpark/lashops6_las2", "fremontpark/cluckinbell1_las2"},
[5178] = {"fremontpark/lasroads_las2", "fremontpark/cutrdn1_las2"},
[5111] = {"fremontpark/ground2_las2", "fremontpark/indusland2_las2"},
[5309] = {"fremontpark/warehus_las2", "fremontpark/las2lnew3_las2"},
[5116] = {"fremontpark/ground2_las2", "fremontpark/las2stripbar1"},
[3783] = {"fremontpark/sanpedh22_1x", "fremontpark/las2xref01_lax"},
[5106] = {"fremontpark/lasraodnshops", "fremontpark/Roadsbx_las2"},
[3628] = {"fremontpark/sanpedhse_1x", "fremontpark/smallprosjmt_las"},
[285] = {"skins/swat", "skins/swat"},
[267] = {"skins/hern", "skins/hern"},
[266] = {"skins/pulaski", "skins/pulaski"},
[265] = {"skins/tenpen", "skins/tenpen"},
[490] = {"vehicles/fbiranch", "vehicles/fbiranch"},
[427] = {"vehicles/enforcer","vehicles/enforcer"},
[596] = {"vehicles/copcarla", "vehicles/copcarla"},
[599] = {"vehicles/copcarru","vehicles/copcarru"},
[597] = {"vehicles/copcarsf","vehicles/copcarsf"},
[598] = {"vehicles/copcarvg","vehicles/copcarvg"},
-- [5518] = {"crystal/glenpark1x_lae","crystal/idlewood05_lae"},
-- [17594] = {"crystal/landlae2","crystal/lae2_ground06"},
-- [17877] = {"crystal/landhub","crystal/lae2_hubgrass"},
-- [17620] = {"crystal/landhub", "crystal/lae2_landhub01"},
-- [17614] = {"crystal/landhub", "crystal/lae2_landhub02"},
-- [17596] = {"crystal/lae2roads","crystal/lae2_roads02"},
-- [17611] = {"crystal/lae2roads","crystal/lae2_roads16"},
-- [17621] = {"crystal/lae2roads","crystal/lae2_roads17"},
-- [17621] = {"crystal/lae2roads","crystal/lae2_roads88"},
-- [17612] = {"crystal/lae2roads","crystal/lae2_roads89"},
-- [5510] = {"crystal/laeroads2s", "crystal/laeroad45"},
-- [17519] = {"crystal/lae2newtempbx", "crystal/market2_lae"},
-- [3661] = {"crystal/projects_la", "crystal/projects01_lax"},
-- [17887] = {"crystal/hub_alpha", "crystal/stdrain_alpha2"},
[17528] = {"industrial/eastlstr_lae2", "industrial/barriotrans01_lae01"},
[17892] = {"industrial/landlae2b", "industrial/grnd02_lae2"},
[17645] = {"industrial/landlae2b", "industrial/lae2_ground12"},

}



local function replaceBuildings()
    for modelID, v in pairs(buildings) do
        local folder = v[1]
        local name = v[2]
		local foundedCol = false
        local txdPath = "models/" .. v[1] .. ".txd"
        local dffPath = "models/" .. v[2] .. ".dff"
		if v[5] then
        colPath = "models/" .. v[5] .. ".col"
		foundedCol = true
		-- print(colPath)
		end


        local txd = engineLoadTXD(txdPath)
        if txd then
            engineImportTXD(txd, modelID)
        else
            outputDebugString("[MODELS] Nie udało się załadować TXD: " .. txdPath, 2)
        end

        local dff = engineLoadDFF(dffPath)
        if dff then
            engineReplaceModel(dff, modelID)
        else
            outputDebugString("[MODELS] Nie udało się załadować DFF: " .. dffPath, 2)
        end
		if foundedCol and fileExists(colPath) then
			-- print("founded col!")
			local col = engineLoadCOL(colPath)
			if col then engineReplaceCOL(col, modelID) end --print("replaced col for ID: "..modelID) end
		end

        if v[3] and v[3][1] then
            local x, y, z = v[3][1], v[3][2], v[3][3]
            local rx, ry, rz = v[3][4], v[3][5], v[3][6]

            -- removeWorldModel(modelID, 5, x, y, z)
            if v[4] ~= 0 then
                removeWorldModel(v[4], 5, x, y, z)
            end

            local lod = createBuilding(modelID, x, y, z, rx, ry, rz, 0)
            local building = createBuilding(modelID, x, y, z, rx, ry, rz, 0)

            setLowLODElement(building, lod)
            setElementParent(lod, building)
        end

        engineSetModelLODDistance(modelID, 325, true)
    end
end



replaceBuildings()
-- local success, element = pcall(createObjectOrBuilding, 5418, x, y, z, rx, ry, rz, interior, dimension)
    -- if not success then
        -- outputDebugString(("Failed to create object or building: %s"):format(tostring(element)), 4, 255, 25, 25)
        -- return
    -- end
setFarClipDistance( 3000 )

removeWorldModel(1676, 999999999999, -300, 1556, 75) -- model
removeWorldModel(1370, 999999999999, -300, 1556, 75) -- model

local enabled = false

function toggleDebugRay()
    enabled = not enabled
    outputChatBox("Debug Ray: " .. (enabled and "ON" or "OFF"))
end
bindKey("F5", "down", toggleDebugRay)

addEventHandler("onClientRender", root, function()
    if not enabled then return end

    local px, py, pz = getElementPosition(localPlayer)
    local cx, cy, cz, lx, ly, lz = getCameraMatrix()

    -- Kierunek patrzenia (zwiększony zasięg)
    local tx = cx + (lx - cx) * 100
    local ty = cy + (ly - cy) * 100
    local tz = cz + (lz - cz) * 100

    -- processLineOfSight — zwraca trafienie i dane
    local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(
        cx, cy, cz, tx, ty, tz,
        true,  -- checkBuildings
        true,  -- checkVehicles
        true,  -- checkPeds
        true,  -- checkObjects
        true,  -- checkDummies
        true,  -- seeThroughStuff
        false, -- ignoreSomeObjectsForCamera
        true   -- shootThroughStuff
    )

    -- Rysowanie czerwonej linii do punktu trafienia lub końca zasięgu
    dxDrawLine3D(cx, cy, cz, hit and hitX or tx, hit and hitY or ty, hit and hitZ or tz, tocolor(255, 0, 0), 2)

    -- Jeśli trafiono w element
    if hit and isElement(hitElement) and getElementType(hitElement) ~= "player" then
        dxDrawLine3D(hitX, hitY, hitZ + 0.2, hitX, hitY, hitZ - 0.2, tocolor(0, 255, 0), 2)

        local elementType = getElementType(hitElement) or "brak"
        local elementModel = getElementModel(hitElement) or "-"
        local text = string.format("Trafiono w: %s [model: %s]", elementType, elementModel)

        dxDrawText3D(text, hitX, hitY, hitZ + 0.5, tocolor(255, 255, 255), 1)
    end
end)

-- Funkcja do rysowania tekstu w 3D
function dxDrawText3D(text, x, y, z, color, size)
    local sx, sy = getScreenFromWorldPosition(x, y, z)
    if sx and sy then
        dxDrawText(text, sx, sy, sx, sy, color, size, "default-bold", "center", "bottom", false, false, false)
    end
end