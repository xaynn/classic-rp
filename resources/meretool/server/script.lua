local drawDistance = 1000;
local priority = 0;

outputDebugString("Meretool : Loading shaders!!!!!!!!!!!")
shaders = {
    [[
        float red;
        float green;
        float blue;
        float alpha;
        sampler TextureSampler;

        float4 main(float2 tex : TEXCOORD0) : COLOR
        {
            float4 color = tex2D(TextureSampler, tex);
            color.rgb *= float3(red, green, blue);
            color.a *= (alpha);
            return color;
        }

        technique simple
        {
            pass P0
            {
                AlphaBlendEnable = TRUE;
                SrcBlend = SrcAlpha;
                DestBlend = InvSrcAlpha;

                PixelShader = compile ps_2_0 main();
            }
        }

    ]],
    [[
        texture tex;

        technique replace {
            pass P0 {
                Texture[0] = tex;
            }
        }
    ]],

}



addEventHandler("onClientResourceStart", resourceRoot,
    function()
        local file = fileExists("meremap.json") and fileOpen("meremap.json")
        if file then
            local json_content = fileRead(file, fileGetSize(file))
            local data = fromJSON(json_content)
            if data then
                local drawDistanceEnabled = data.drawDistance
                local elementsTable = data.elements
                local shadersElements = {}
                -- Create shaders for each texture
                local texturesTable = data.texturesTable
                for index, texture in ipairs(texturesTable) do
                    local p = texture.e and (priority) + 1 or priority
                    if (texture.t == 1 or texture.t == 2) then
                        local shader = dxCreateShader(shaders[2], p, 0, false,
                            'all')
                        local texture = dxCreateTexture("merefiles/" .. index .. ".png")
                        dxSetShaderValue(shader, "tex", texture)
                        shadersElements[index] = shader
                    elseif (texture.t == 0) then
                        local shader = dxCreateShader(shaders[1], p, 0, false, 'all')
                        dxSetShaderValue(shader, 'red', texture.d.RED / 255)
                        dxSetShaderValue(shader, 'green', texture.d.GREEN / 255)
                        dxSetShaderValue(shader, 'blue', texture.d.BLUE / 255)
                        dxSetShaderValue(shader, 'alpha', texture.d.ALPHA / 255)
                        shadersElements[index] = shader
                    end
                    if (texture.e) then
                        engineApplyShaderToWorldTexture(shadersElements[index], texture.n)
                    end
                end


                -- Apply shaders to elements
                for elementid, elementdata in pairs(elementsTable) do
                    local element = getElementByID(elementid)
                    if element then
                        if drawDistanceEnabled == 2 then
                            local model = getElementModel(element)
                            engineSetModelLODDistance(model, drawDistance, true)
                        end
                        for _, texture in ipairs(elementdata.textures) do
                            if shadersElements[texture.index] then
                                engineApplyShaderToWorldTexture(shadersElements[texture.index], texture.name, element,
                                    true)
                            end
                        end
                    end
                end

                if drawDistanceEnabled == 1 then
                    for _, element in ipairs(mergeTables(getElementsByType("object"), getElementsByType("vehicle"))) do
                        local model = getElementModel(element)
                        engineSetModelLODDistance(model, drawDistance, true)
                    end
                end
            end
        end
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        for _, element in ipairs(mergeTables(getElementsByType("object"), getElementsByType("vehicle"))) do
            local model = getElementModel(element)
            engineResetModelLODDistance(model)
        end
    end
)



function mergeTables(t1, t2)
    local merged = {}
    for _, v in ipairs(t1) do
        table.insert(merged, v)
    end
    for _, v in ipairs(t2) do
        table.insert(merged, v)
    end
    return merged
end
