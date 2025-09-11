import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { Resend } from "https://esm.sh/resend@1.1.0";

const resend = new Resend(Deno.env.get("RESEND_API_KEY"));

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  try {
    const { userEmail, eventName, eventDate, eventLocation } = await req.json();

    if (!userEmail || !eventName || !eventDate || !eventLocation) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    const { data, error } = await resend.emails.send({
      from: "TeamMates <onboarding@resend.dev>", // Replace with your verified Resend domain
      to: [userEmail],
      subject: `Potwierdzenie zapisu na wydarzenie: ${eventName}`,
      html: `
        <p>Cześć!</p>
        <p>Potwierdzamy Twój zapis na wydarzenie:</p>
        <h3>${eventName}</h3>
        <ul>
          <li><strong>Kiedy:</strong> ${eventDate}</li>
          <li><strong>Gdzie:</strong> ${eventLocation}</li>
        </ul>
        <p>Do zobaczenia!</p>
        <p>Zespół TeamMates</p>
      `,
    });

    if (error) {
      console.error("Resend error:", error);
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ message: "Email sent successfully", data }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Function error:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});