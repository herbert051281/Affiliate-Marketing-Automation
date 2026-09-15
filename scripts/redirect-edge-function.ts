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
 *
 * Requires `@vercel/functions` for waitUntil. Off Vercel, drop the import and
 * `await recordClick(...)` directly — see the note at the call site.
 */

import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import { waitUntil } from '@vercel/functions';

export const runtime = 'edge';

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!, // server-only; never expose to the client
);

// Cheap bot filter. Bot clicks pollute EPC and make every downstream decision wrong.
const BOT_RE = /bot|crawl|spider|slurp|preview|fetch|curl|wget|headless|monitor/i;

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// Channel codes land in a grouped column on every report. Anything can be typed
// into ?c=, so constrain it rather than letting a typo or a crawler fork the
// rollup into a long tail of junk dimensions.
const CHANNEL_RE = /^[a-z0-9_-]{1,32}$/;

type Offer = {
  id: string;
  destination_url: string;
  subid_param: string | null;
  active: boolean;
  health_status: 'ok' | 'degraded' | 'broken' | 'paused';
};

type OfferWithBackup = Offer & { backup: Offer | null };

// Deliberately a plain boolean, not an `o is Offer` type predicate: a predicate
// would narrow the primary offer to `never` on the false branch and make the
// backup fallback below unreachable to the type checker.
const usable = (o: Offer | null | undefined): boolean =>
  !!o && o.active && o.health_status !== 'broken' && o.health_status !== 'paused';

export async function GET(
  req: NextRequest,
  // Next.js 15 made route params a Promise. On Next 14 drop the Promise<> and
  // the await below.
  { params }: { params: Promise<{ slug: string }> },
) {
  const { slug } = await params;
  const url = new URL(req.url);

  const rawChannel = url.searchParams.get('c') ?? '';
  const channel = CHANNEL_RE.test(rawChannel) ? rawChannel : 'unknown';

  // ?s= is written into a uuid column. A malformed value fails the whole insert,
  // so validate it here instead of silently losing the click.
  const rawContentId = url.searchParams.get('s');
  const contentId = rawContentId && UUID_RE.test(rawContentId) ? rawContentId : null;

  const { data: link, error } = await supabase
    .from('links')
    .select(
      'id, content_item_id, ' +
        'offer:offer_id(id, destination_url, subid_param, active, health_status, ' +
        'backup:backup_offer_id(id, destination_url, subid_param, active, health_status))',
    )
    .eq('slug', slug)
    .eq('active', true)
    .maybeSingle();

  if (error) console.error('[go] link lookup failed', slug, error.message);

  // Unknown or retired slug: send to the site, never to a 404. Old links live forever
  // in videos and emails you can no longer edit.
  const primary = (link?.offer ?? null) as OfferWithBackup | null;
  if (!primary) {
    return NextResponse.redirect(new URL('/', req.url), 302);
  }

  // Prefer the live offer; fall back to the pre-approved backup (doc 02's
  // portfolio rule) when the primary is paused or known broken. W11 normally
  // swaps these within 6 hours — this covers the gap in between, when the
  // alternative is sending a buyer to a dead page.
  const offer: Offer | null = usable(primary)
    ? primary
    : usable(primary.backup)
      ? primary.backup
      : null;
  if (!offer) {
    console.error('[go] no usable offer for slug', slug);
    return NextResponse.redirect(new URL('/', req.url), 302);
  }

  const ua = req.headers.get('user-agent') ?? '';
  const isBot = BOT_RE.test(ua);
  const clickId = crypto.randomUUID();

  // Bot hits are RECORDED but flagged, not discarded. daily_metrics filters them
  // out of aff_clicks; keeping the rows is what lets you tell "traffic died" from
  // "a crawler was inflating this all along".
  const write = recordClick({
    clickId,
    linkId: link!.id,
    contentId: contentId ?? link!.content_item_id,
    channel,
    referrer: req.headers.get('referer')?.slice(0, 500) ?? null,
    country: req.headers.get('x-vercel-ip-country'),
    ua,
    isBot,
  });

  // supabase-js query builders are LAZY thenables: the request is only sent when
  // something awaits them. `void supabase.from(...).insert(...)` sends nothing at
  // all and loses every click silently. Hand the promise to waitUntil so it is
  // flushed after the response without delaying the redirect.
  // Off Vercel: replace with `await write;`.
  waitUntil(write);

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

async function recordClick(c: {
  clickId: string;
  linkId: string;
  contentId: string | null;
  channel: string;
  referrer: string | null;
  country: string | null;
  ua: string;
  isBot: boolean;
}): Promise<void> {
  try {
    const { error } = await supabase.from('click_events').insert({
      click_id: c.clickId,
      link_id: c.linkId,
      content_item_id: c.contentId,
      channel_code: c.channel,
      referrer: c.referrer,
      country: c.country,
      device: /mobile|android|iphone/i.test(c.ua) ? 'mobile' : 'desktop',
      ua_hash: await sha256(c.ua), // hashed, never stored raw
      is_bot: c.isBot,
    });
    // A dropped click is an unattributable sale later. Make it loud in the logs
    // so W00 Watchdog has something to catch.
    if (error) console.error('[go] click insert failed', c.clickId, error.message);
  } catch (e) {
    console.error('[go] click insert threw', c.clickId, e);
  }
}

async function sha256(input: string): Promise<string> {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(input));
  return Array.from(new Uint8Array(buf))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
    .slice(0, 32);
}
