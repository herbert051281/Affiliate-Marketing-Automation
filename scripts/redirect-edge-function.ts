/**
 * Tracked affiliate redirector — Next.js App Router edge route.
 * File location in the site repo: app/go/[slug]/route.ts
 *
 * Every affiliate link in every channel points here:
 *   https://yoursite.com/go/{slug}?c={channel}&s={content_item_id}
 *
 * Why this exists (see docs/03-architecture.md):
 *   - attribution: the click_id we mint is passed to the merchant as subid and
 *     comes back on the conversion report
 *   - swap-ability: change one DB row, every link on the internet updates
 *   - survivability: a dead program never leaves broken links behind
 */

import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

export const runtime = 'edge';

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!, // server-only; never expose to the client
);

// Cheap bot filter. Bot clicks pollute EPC and make every downstream decision wrong.
const BOT_RE = /bot|crawl|spider|slurp|preview|fetch|curl|wget|headless|monitor/i;

export async function GET(
  req: NextRequest,
  { params }: { params: { slug: string } },
) {
  const { slug } = params;
  const url = new URL(req.url);
  const channel = url.searchParams.get('c') ?? 'unknown';
  const contentId = url.searchParams.get('s');

  const { data: link } = await supabase
    .from('links')
    .select('id, content_item_id, offers(id, destination_url, subid_param, active, health_status)')
    .eq('slug', slug)
    .eq('active', true)
    .single();

  // Unknown or retired slug: send to the site, never to a 404. Old links live forever
  // in videos and emails you can no longer edit.
  if (!link || !link.offers) {
    return NextResponse.redirect(new URL('/', req.url), 302);
  }

  const offer = link.offers as unknown as {
    id: string;
    destination_url: string;
    subid_param: string;
    active: boolean;
    health_status: string;
  };

  const ua = req.headers.get('user-agent') ?? '';
  const isBot = BOT_RE.test(ua);
  const clickId = crypto.randomUUID();

  // Fire-and-forget: never make the user wait on the write.
  if (!isBot) {
    void supabase.from('click_events').insert({
      click_id: clickId,
      link_id: link.id,
      content_item_id: contentId ?? link.content_item_id,
      channel_code: channel,
      referrer: req.headers.get('referer'),
      country: req.headers.get('x-vercel-ip-country'),
      device: /mobile|android|iphone/i.test(ua) ? 'mobile' : 'desktop',
      ua_hash: await sha256(ua), // hashed, never stored raw
      is_bot: false,
    });
  }

  // Append our click_id as the merchant's subid so the conversion report can be
  // joined back to this exact click. The param name varies by network, which is
  // why it lives on the offer record.
  const dest = new URL(offer.destination_url);
  dest.searchParams.set(offer.subid_param || 'subid', clickId);

  const res = NextResponse.redirect(dest.toString(), 302);
  res.headers.set('X-Robots-Tag', 'noindex, nofollow');
  res.headers.set('Cache-Control', 'no-store');
  return res;
}

async function sha256(input: string): Promise<string> {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(input));
  return Array.from(new Uint8Array(buf))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
    .slice(0, 32);
}
