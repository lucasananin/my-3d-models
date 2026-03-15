Shader "Custom/URP_PS1_Jitter_Lit"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)

        _JitterStrength ("Jitter Strength", Float) = 0.01
        _JitterSpeed ("Jitter Speed", Float) = 1.0
        _SnapResolution ("Snap Resolution", Float) = 240
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS    : TEXCOORD1;
                float2 uv          : TEXCOORD0;
                float3 positionWS  : TEXCOORD2;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _BaseMap_ST;
                float _JitterStrength;
                float _JitterSpeed;
                float _SnapResolution;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output;

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

                // --- PS1 STYLE JITTER ---
                float time = _Time.y * _JitterSpeed;

                float jitter = sin(positionWS.x * 10 + time) *
                               cos(positionWS.y * 10 + time);

                positionWS += input.normalOS * jitter * _JitterStrength;

                // Convert to clip space
                float4 positionCS = TransformWorldToHClip(positionWS);

                // --- SCREEN SPACE VERTEX SNAP ---
                float2 screenPos = positionCS.xy / positionCS.w;
                screenPos *= _SnapResolution;
                screenPos = floor(screenPos);
                screenPos /= _SnapResolution;

                positionCS.xy = screenPos * positionCS.w;

                output.positionHCS = positionCS;
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.positionWS = positionWS;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float3 normalWS = normalize(input.normalWS);

                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);

                float NdotL = saturate(dot(normalWS, lightDir));

                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                float3 color = baseMap.rgb * _BaseColor.rgb;

                float3 lighting = color * (0.2 + NdotL);

                return float4(lighting, 1.0);
            }

            ENDHLSL
        }
    }
}