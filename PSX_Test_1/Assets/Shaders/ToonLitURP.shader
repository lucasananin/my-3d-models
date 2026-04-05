Shader "Custom/ToonLitURP"
{
    Properties
    {
        _BaseMap ("Base Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)

        _ShadowStrength ("Shadow Strength", Range(0,1)) = 1
        _ShadowThreshold ("Shadow Threshold", Range(0,1)) = 0.5
        _ShadowSmoothness ("Shadow Smoothness", Range(0.001, 0.5)) = 0.05

        _SpecColor ("Specular Color", Color) = (1,1,1,1)
        _SpecSize ("Specular Size", Range(0,1)) = 0.2
        _SpecSmoothness ("Specular Smoothness", Range(0.001,0.5)) = 0.05

        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0.5, 8)) = 3
        _RimIntensity ("Rim Intensity", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Geometry"
            "RenderPipeline"="UniversalPipeline"
        }

        Pass
        {
            Name "ForwardLit"

            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 viewDirWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
                float4 shadowCoord : TEXCOORD3;
                float3 positionWS : TEXCOORD4;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)

            float4 _BaseColor;

            float _ShadowStrength;
            float _ShadowThreshold;
            float _ShadowSmoothness;

            float4 _SpecColor;
            float _SpecSize;
            float _SpecSmoothness;

            float4 _RimColor;
            float _RimPower;
            float _RimIntensity;

            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;

                VertexPositionInputs posInputs =
                    GetVertexPositionInputs(IN.positionOS.xyz);

                VertexNormalInputs normInputs =
                    GetVertexNormalInputs(IN.normalOS);

                OUT.positionHCS = posInputs.positionCS;
                OUT.positionWS = posInputs.positionWS;
                OUT.normalWS = normInputs.normalWS;

                OUT.viewDirWS =
                    GetCameraPositionWS() - posInputs.positionWS;

                OUT.uv = IN.uv;

                OUT.shadowCoord =
                    GetShadowCoord(posInputs);

                return OUT;
            }

            float ToonStep(float NdotL)
            {
                return smoothstep(
                    _ShadowThreshold - _ShadowSmoothness,
                    _ShadowThreshold + _ShadowSmoothness,
                    NdotL
                );
            }

            float ToonSpec(float spec)
            {
                return smoothstep(
                    _SpecSize - _SpecSmoothness,
                    _SpecSize + _SpecSmoothness,
                    spec
                );
            }

            half4 frag (Varyings IN) : SV_Target
            {
                float3 normal =
                    normalize(IN.normalWS);

                float3 viewDir =
                    normalize(IN.viewDirWS);

                Light light =
                    GetMainLight(IN.shadowCoord);

                float3 lightDir =
                    normalize(light.direction);

                float NdotL =
                    dot(normal, lightDir);

                float shadow =
                    light.shadowAttenuation;

                float lightStep =
                    ToonStep(NdotL) * shadow;

                float4 tex =
                    SAMPLE_TEXTURE2D(
                        _BaseMap,
                        sampler_BaseMap,
                        IN.uv
                    );

                float3 baseColor =
                    tex.rgb * _BaseColor.rgb;

                // float3 diffuse =
                //     baseColor * lightStep;
                float shadowFactor =
                    lerp(1.0, lightStep, _ShadowStrength);

                float3 diffuse =
                    baseColor * shadowFactor;

                float3 halfDir =
                    normalize(lightDir + viewDir);

                float spec =
                    pow(
                        saturate(dot(normal, halfDir)),
                        64
                    );

                float specStep =
                    ToonSpec(spec);

                float3 specular =
                    _SpecColor.rgb * specStep;

                float rim =
                    1.0 -
                    saturate(dot(viewDir, normal));

                rim =
                    pow(rim, _RimPower)
                    * _RimIntensity;

                float3 rimLight =
                    _RimColor.rgb * rim;

                float3 color =
                    diffuse
                    + specular
                    + rimLight;

                return float4(color, 1);
            }

            ENDHLSL
        }
    }
}