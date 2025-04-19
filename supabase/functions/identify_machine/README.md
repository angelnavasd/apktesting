# Edge Function: Identificador de Máquinas de Gimnasio

Esta Edge Function recibe información de una imagen almacenada en Supabase Storage, la analiza usando OpenAI Vision, y devuelve información sobre la máquina de gimnasio y los músculos que trabaja.

## Requisitos

- Supabase CLI instalada
- Cuenta de Supabase con Storage y Database configurados
- Cuenta de OpenAI con acceso a GPT-4 Vision

## Variables de Entorno

Copia el archivo `.env.example` a `.env` y configura las siguientes variables:

```
SUPABASE_URL=https://clmrkqhvpyqcpghqhlbg.supabase.co
SUPABASE_SERVICE_ROLE_KEY=tu_service_role_key
OPENAI_API_KEY=tu_openai_api_key
```

## Despliegue

```bash
# Desde la raíz del proyecto
cd supabase/functions
supabase functions deploy identify_machine --no-verify-jwt
supabase secrets set --env-file ./.env
```

## Uso

### Llamada desde Flutter

```dart
// Ejemplo de cómo llamar a la función desde Flutter
final response = await Supabase.instance.client
    .functions
    .invoke('identify_machine', 
      body: {
        'image_id': imageId,  // O puedes usar 'file_name' en su lugar
      }
    );

if (response.status == 200) {
  final result = response.data;
  // Procesar result.analysis que contiene información de la máquina
}
```

### Respuesta de Ejemplo

```json
{
  "success": true,
  "image_id": "123e4567-e89b-12d3-a456-426614174000",
  "file_name": "imagen_maquina.jpg",
  "analysis": {
    "machine_name": "Prensa de Piernas",
    "primary_muscles": ["Cuádriceps", "Glúteos"],
    "secondary_muscles": ["Isquiotibiales", "Pantorrillas"],
    "instructions": "Siéntate en la máquina con la espalda apoyada. Empuja la plataforma alejándola de ti extendiendo las piernas. Regresa lentamente a la posición inicial."
  }
}
```

## Permisos Necesarios

Esta función requiere:
- `service_role` para acceder a Storage y Database
- Bucket "gym-images" configurado en Storage
- Tabla "gym_images" configurada en Database

## Modificación de la Tabla gym_images

Para almacenar los resultados del análisis, añade estas columnas a tu tabla:

```sql
ALTER TABLE public.gym_images 
ADD COLUMN analysis_result JSONB,
ADD COLUMN analyzed_at TIMESTAMP WITH TIME ZONE;
```
