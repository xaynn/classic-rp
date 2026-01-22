// wave.fx
texture screenSource;

sampler ScreenSampler = sampler_state
{
    Texture = <screenSource>;
};

float time;
float amplitude = 0.02; // siła falowania
float frequency = 5.0;  // częstotliwość falowania

float4 main(float2 uv : TEXCOORD0) : COLOR0
{
    uv.y += sin(uv.x * frequency + time) * amplitude;
    return tex2D(ScreenSampler, uv);
}

technique Tech1
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
    }
}
