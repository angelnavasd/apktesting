// @ts-ignore
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

// @ts-ignore
import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";

// Interfaces para tipar
interface GymImageRecord {
  id: string;
  image_url: string;
  file_name: string;
  device_info?: string;
  created_at?: string;
  analysis_result?: any;
  analyzed_at?: string;
}

interface AnalysisResult {
  machine_name?: string;
  primary_muscles?: string[];
  secondary_muscles?: string[];
  instructions?: string;
  error?: string;
  raw_response?: any;
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Función para obtener una URL pública temporal para la imagen
async function getPublicUrl(
  supabase: SupabaseClient, 
  bucketName: string, 
  fileName: string
): Promise<string | null> {
  const { data } = await supabase.storage.from(bucketName).createSignedUrl(fileName, 60);
  return data?.signedUrl || null;
}

// Función para descargar la imagen y convertirla a Base64
async function downloadAndConvertToBase64(
  supabase: SupabaseClient, 
  bucketName: string, 
  fileName: string
): Promise<string> {
  // Descargar el archivo como array buffer
  const { data, error } = await supabase.storage
    .from(bucketName)
    .download(fileName);
    
  if (error || !data) {
    throw new Error(`Error descargando la imagen: ${error?.message || "Unknown error"}`);
  }
  
  // Convertir el array buffer a base64
  const buffer = await data.arrayBuffer();
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  const base64 = btoa(binary);
  
  // Determinar el tipo MIME basado en la extensión del archivo
  let mimeType = "image/jpeg"; // Predeterminado
  if (fileName.toLowerCase().endsWith(".png")) {
    mimeType = "image/png";
  } else if (fileName.toLowerCase().endsWith(".gif")) {
    mimeType = "image/gif";
  }
  
  // Devolver la URL de datos en formato base64
  return `data:${mimeType};base64,${base64}`;
}

// Función para consultar Gemini Pro API
async function analyzeImageWithGemini(imageBase64: string): Promise<AnalysisResult> {
  // @ts-ignore
  const geminiApiKey = Deno.env.get("GEMINI_API_KEY");
  if (!geminiApiKey) {
    throw new Error("GEMINI_API_KEY no está configurado");
  }

  const apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${geminiApiKey}`;

  const response = await fetch(apiUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      contents: [
        {
          parts: [
            {
              text: "Identifica esta máquina de gimnasio. Proporciona la siguiente información en formato JSON: 1) nombre_de_la_máquina, 2) músculos_principales como array, 3) músculos_secundarios como array, 4) instrucciones_básicas_de_uso como array. Responde SOLO con el JSON, sin texto adicional."
            },
            {
              inline_data: {
                mime_type: imageBase64.split(";")[0].split(":")[1],
                data: imageBase64.split(",")[1]
              }
            }
          ]
        }
      ],
      generationConfig: {
        temperature: 0.4,
        maxOutputTokens: 1000
      }
    }),
  });

  const result = await response.json();
  
  try {
    // Extraer el JSON de la respuesta de texto
    const textContent = result.candidates[0].content.parts[0].text;
    
    // Limpiar el texto para manejar diferentes formatos de respuesta
    let jsonText = textContent;
    
    // Si el texto contiene comillas de código (```json), extraer solo el contenido JSON
    if (jsonText.includes('```json')) {
      jsonText = jsonText.split('```json')[1].split('```')[0].trim();
    } else if (jsonText.includes('```')) {
      // Si solo contiene comillas de código sin especificar el lenguaje
      jsonText = jsonText.split('```')[1].split('```')[0].trim();
    }
    
    // Intentar analizar el JSON
    return JSON.parse(jsonText);
  } catch (error) {
    console.error("Error parsing Gemini response:", error);
    return {
      error: "No se pudo analizar la respuesta del modelo",
      raw_response: result
    };
  }
}

// Función principal que maneja las solicitudes HTTP
serve(async (req: Request) => {
  // Manejar solicitudes OPTIONS para CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Configurar cliente de Supabase con claves de servicio para acceso completo
    // @ts-ignore
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    // @ts-ignore
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    
    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error("Faltan variables de entorno de Supabase");
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);
    
    // Obtener datos de la solicitud
    const { image_id, file_name } = await req.json();
    
    if (!image_id && !file_name) {
      throw new Error("Se requiere image_id o file_name");
    }

    // Si se proporciona image_id, obtener detalles de la imagen desde la base de datos
    let imageFileName: string;
    let imageRecord: GymImageRecord | null = null;
    
    if (image_id) {
      const { data, error } = await supabase
        .from("gym_images")
        .select("*")
        .eq("id", image_id)
        .single();
        
      if (error || !data) {
        throw new Error(`No se encontró la imagen con ID: ${image_id}`);
      }
      
      imageRecord = data as GymImageRecord;
      imageFileName = data.file_name;
    } else {
      imageFileName = file_name;
    }

    // Descargar la imagen y convertirla a base64
    const imageBase64 = await downloadAndConvertToBase64(supabase, "gym-images", imageFileName);
    
    if (!imageBase64) {
      throw new Error(`No se pudo procesar la imagen: ${imageFileName}`);
    }

    // Analizar la imagen con Gemini Pro
    const analysisResult = await analyzeImageWithGemini(imageBase64);
    
    // Si tenemos el ID de la imagen, actualizar el registro con los resultados
    if (image_id) {
      await supabase
        .from("gym_images")
        .update({
          analysis_result: analysisResult,
          analyzed_at: new Date().toISOString(),
        })
        .eq("id", image_id);
    }

    // Devolver los resultados
    return new Response(
      JSON.stringify({
        success: true,
        image_id: image_id || null,
        file_name: imageFileName,
        analysis: analysisResult,
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error: any) {
    console.error("Error:", error.message);
    
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        status: 400,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  }
});
