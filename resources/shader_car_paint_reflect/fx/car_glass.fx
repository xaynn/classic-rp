//
// car_glass.fx
// author: Ren712/AngerMAN
//

//------------------------------------------------------------------------------------------
// Settings
//------------------------------------------------------------------------------------------
float2 uvMul = float2(1,1);
float2 uvMov = float2(0,0);
float sNorFac = 1;
float bumpSize = 1;
float envIntensity = 1;
float specularValue = 1;
float refTexValue = 0.2;

float sAdd = 0.1;  
float sMul = 1.1; 
float sPower = 2; 

texture sReflectionTexture;

//------------------------------------------------------------------------------------------
// Include some common stuff
//------------------------------------------------------------------------------------------
int gFogEnable  < string renderState="FOGENABLE"; >;
float4 gFogColor < string renderState="FOGCOLOR"; >;
float gFogStart  < string renderState="FOGSTART"; >;
float gFogEnd < string renderState="FOGEND"; >;
#define GENERATE_NORMALS // Uncomment for normals to be generated
#include "mta-helper.fx"

//------------------------------------------------------------------------------------------
// Sampler for the main texture
//------------------------------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};

sampler2D ReflectionSampler = sampler_state
{
    Texture = (sReflectionTexture);	
    AddressU = Mirror;
    AddressV = Mirror;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
};

//------------------------------------------------------------------------------------------
// Structure of data sent to the vertex shader
//------------------------------------------------------------------------------------------
struct VSInput
{
  float3 Position : POSITION0;
  float3 Normal : NORMAL0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
  float2 TexCoord1 : TEXCOORD1;
};

//------------------------------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//------------------------------------------------------------------------------------------
struct PSInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float4 Specular : COLOR1;
  float2 TexCoord : TEXCOORD0;
  float3 Normal : TEXCOORD1;
  float4 WorldPos : TEXCOORD2;
};


//------------------------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    // Make sure normal is valid
    MTAFixUpNormal( VS.Normal );

    // Pass through tex coords
    PS.TexCoord = VS.TexCoord;
	
    // Calculate screen pos of vertex	
    float4 worldPos = mul(float4(VS.Position.xyz,1) , gWorld);
    PS.WorldPos.xyz = worldPos.xyz;
    float4 viewPos = mul( worldPos , gView );
    PS.WorldPos.w = viewPos.z / viewPos.w;
    PS.Position = mul( viewPos, gProjection);
	
    // Set information to do specular calculation in pixel shader
    PS.Normal = normalize(mul(VS.Normal, (float3x3)gWorld));
	
    // Calculate GTA vehicle lighting
    PS.Diffuse = MTACalcGTACompleteDiffuse( PS.Normal, VS.Diffuse );
    PS.Specular.rgb = gMaterialSpecular.rgb * MTACalculateSpecular( gCameraDirection, gLight1Direction, PS.Normal, gMaterialSpecPower ) * specularValue;
 
    // Calc Specular 
    PS.Specular.a = pow( mul( VS.Normal, (float3x3)gWorld ).z ,2 ); 
    float3 h = normalize(normalize(gCameraPosition - worldPos.xyz) - normalize(gCameraDirection));
    PS.Specular.a *=  1 - saturate(pow(saturate(dot(PS.Normal,h)), 2));
    PS.Specular.a *= saturate(1 + gCameraDirection.z);
	
    return PS;
}

//------------------------------------------------------------------------------------------
// GetUV from WorldPos
//------------------------------------------------------------------------------------------
float3 GetUV(float3 position, float4x4 ViewProjection)
{
    float4 pVP = mul(float4(position, 1.0f), ViewProjection);
    pVP.xy = float2(0.5f, 0.5f) + float2(0.5f, -0.5f) * ((pVP.xy / pVP.w) * uvMul) + uvMov;
    return float3(pVP.xy, pVP.z / pVP.w);
}

//------------------------------------------------------------------------------------------
// MTAApplyFog
//------------------------------------------------------------------------------------------ 
float3 MTAApplyFog( float3 texel, float3 worldPos )
{
    if ( !gFogEnable )
        return texel;
 
    float DistanceFromCamera = distance( gCameraPosition, worldPos );
    float FogAmount = ( DistanceFromCamera - gFogStart )/( gFogEnd - gFogStart );
    texel.rgb = lerp(texel.rgb, gFogColor.rgb, saturate( FogAmount ) );
    return texel;
}

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float microflakePerturbation = 1.00;
	
    // Get texture pixel
    float4 texel = tex2D(Sampler0, PS.TexCoord);
	
    // lerp between scene and material world normal
    float3 worldNormal = normalize(PS.Normal);
	
    // reflection direction
    float3 view = normalize(PS.WorldPos.xyz - gCameraPosition);
    float3 reflectDir = normalize(reflect(view, worldNormal));
    // cast rays
    float3 currentRay = PS.WorldPos.xyz + reflectDir * sNorFac;
    float farClip = gProjection[3][2] / (1 - gProjection[2][2]);
	
    currentRay += 2 * gWorld[2].xyz * (1.0 + (PS.WorldPos.w / farClip));
    float3 nuv = GetUV(currentRay , gViewProjection);

    // Sample environment map using this reflection vector:
    float4 envMap = tex2D(ReflectionSampler, nuv.xy);
	
    // basic filter for vehicle effect reflection
    envMap += sAdd; 
    envMap = pow(envMap, sPower); 
    envMap *= sMul;
    envMap = saturate( envMap * envIntensity );
	
    // Apply diffuse lighting
    float4 finalColor = texel * PS.Diffuse;

    // Apply specular
    finalColor.rgb += PS.Specular.rgb;
	
    if (PS.Diffuse.a <= 0.85) finalColor.rgb += envMap.rgb * PS.Specular.a;
    finalColor.rgb += saturate(0.5 * gMaterialSpecular.rgb * refTexValue);
    finalColor.rgb = saturate(finalColor.rgb);
	
    finalColor.rgb = MTAApplyFog(finalColor.rgb, PS.WorldPos.xyz);

    return finalColor;
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique car_paint_reflect_glass
{
    pass P0
    {
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader = compile ps_3_0 PixelShaderFunction();
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
