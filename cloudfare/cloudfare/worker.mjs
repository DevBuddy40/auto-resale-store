// auto-resale-bot Worker  – Temu sync + Stripe/Shippo webhooks
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

export default {
  async fetch(request, env) {
    /* 1️⃣  Read your Supabase keys FROM env right here  */
    const SUPABASE_URL = env.SUPABASE_URL; // set in Worker → Settings → Variables
    const SERVICE_KEY = env.SUPABASE_SERVICE_ROLE_KEY; // set as a Secret

    /* 2️⃣  Create a Supabase client you can reuse in this request */
    const supabase = createClient(SUPABASE_URL, SERVICE_KEY);

    const { pathname } = new URL(request.url);

    /* ----------  Temu hourly sync  ---------- */
    if (pathname === "/temu-sync") {
      // demo upsert (replace later with real scraper)
      await supabase.from("products").upsert([
        {
          name: "Hoodie",
          price: 49,
          vendor: "temu",
          image_url: "/placeholder",
        },
        { name: "Cap", price: 19, vendor: "temu", image_url: "/placeholder" },
      ]);
      return new Response("Temu sync OK");
    }

    /* ----------  Stripe webhook  ---------- */
    if (pathname === "/stripe") {
      const payload = await request.json();
      await supabase.rpc("handle_stripe_event", { payload });
      return new Response("Stripe webhook received");
    }

    /* ----------  Shippo webhook  ---------- */
    if (pathname === "/shippo") {
      const payload = await request.json();
      await supabase.rpc("handle_shippo_event", { payload });
      return new Response("Shippo webhook received");
    }

    return new Response("Not found", { status: 404 });
  },
};
