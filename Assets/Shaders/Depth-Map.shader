Shader "Custom/DepthMapShader" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		
		_HeightTex ("Heightmap (R)", 2D) = "gray" {}
		_Scale ("Scale", Vector) = (0,0,0,0)

		[Toggle(VISUALISE_DEPTH)]_VisualiseDepth("Visualise Depth", Float) = 0
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#pragma shader_feature VISUALISE_DEPTH
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _VisualiseDepth;
			sampler2D _HeightTex;
			fixed2 _Scale;
			
			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 color : COLOR;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 color : COLOR;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.color = v.color;

				return o;
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
			    fixed4 color = tex2D (_MainTex, uv);
			    return color;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed3 diffuse = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				// Displacement
				fixed height = tex2D(_HeightTex, i.uv).r;
				fixed2 displacement = _Scale * ((height - 0.5) * 2);
				fixed4 c = SampleSpriteTexture (i.uv - displacement) * i.color;
				
				#ifdef VISUALISE_DEPTH
					return fixed4(diffuse, 1.0);
				#else
					return fixed4(diffuse, 1.0);
				#endif

			}
			
			ENDCG
		}
	} 
	FallBack "Specular"
}