import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { url, headers } = req
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: headers.get('Authorization')! } } }
  )

  try {
    const { user } = await supabase.auth.getUser()
    const { eventId, errorMessage, operationType, eventData } = await req.json()

    const { error } = await supabase.from('error_logs').insert({
      user_id: user?.id,
      event_id: eventId,
      error_message: errorMessage,
      operation_type: operationType,
      event_data_snapshot: eventData,
    })

    if (error) {
      console.error('Error inserting log:', error.message)
      return new Response(JSON.stringify({ error: error.message }), {
        headers: { 'Content-Type': 'application/json' },
        status: 500,
      })
    }

    return new Response(JSON.stringify({ message: 'Log created successfully' }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    console.error('Error in log-error function:', error.message)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})