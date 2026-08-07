# Privacy and compliance: general principles

> This is an operational reminder and a summary of technique, not legal advice. Region-specific legal basis, citations, and notice requirements live in `references/geo/<code>.md` — this file covers only what holds regardless of jurisdiction. Confirm with the client's own legal or compliance counsel before rollout.

## Direct identifier vs. pseudonymous identifier — the line that governs everything else

`SKILL.md` hard limit 1 bans direct identifiers from analytics tools; hard limit 2 allows `user_id`/`client_id`/UUID-style IDs. These aren't in tension — they're two different tiers of rule:

| | Direct identifier (**including its hash**) | Opaque pseudonymous identifier |
|---|---|---|
| Examples | Email, phone, name, national ID, address, credit card number, a reverse-identifiable full order number, **and any hash of the above** (`sha256(email)`, a salted phone hash all count) | `client_id`, a random-UUID `transaction_id`, a backend-random internal `user_id` unrelated to the account |
| Allowed in a general analytics tool field? | **No, no exception** — also Google's own platform policy, violating it can get the resource suspended. "The user consented" doesn't waive it; "we hashed it" doesn't either | **Yes, but treat it as personal data** (four preconditions below) |

last_verified: 2026-07-20
Source: Google Analytics Help, "Prohibited uses" — https://support.google.com/analytics/answer/6366371
| Why | Platform policy, plus it points directly back to a real person the moment it leaks. A hash points back just as directly: these fields have small, fixed value spaces, so anyone with the hash can enumerate a known list through the same hash function and match it, or join it across datasets by the hash value alone | Random by construction — a third party without your backend's mapping table can't reverse it. Still "indirectly identifying" personal data under most privacy law, just not platform-policy-prohibited |

**The dividing line isn't "was it hashed," it's "can a third party who gets this value reverse it to a specific person."** Test: if someone obtained only this one column's values (a leak, an export, agency-level access) plus a common list of emails/phone numbers, could they match values back to individuals? If yes, it's a direct identifier regardless of hashing or salting.

**`account_id`, member number, and `user_id` need a case-by-case call, never a default "opaque"**: if it's the user's own login handle, a public seller code, a phone number, or a sequential/enumerable member number, it's a direct identifier. Only an identifier that's "backend-random, with no relationship to anything publicly visible" qualifies as opaque.

**Enhanced Conversions / Conversions API is a separate channel, not an exception**: sending a hashed email/phone to Google Enhanced Conversions or Meta's Conversions API is legitimate — those are **platform-designated fields and endpoints** with their own format spec (normalize, then SHA-256) and data-use terms. Two things not to conflate: ① it does **not** mean the same hash can go into a general GA4 event parameter or custom dimension — that's still a platform-policy violation ② sending data through this channel hands personal data to a third-party ad platform, often across borders — that's a separate use purpose from on-site analytics and needs its own legal basis (see the GEO module).

**Use of a pseudonymous identifier needs all four preconditions** (skipping any one is "we hashed it" used as an excuse, not a real safeguard):

1. **Legal basis and defined purpose** — can name which legal basis applies and what purpose was disclosed at collection; using it for something beyond that purpose needs a separate basis
2. **Minimization** — use the coarsest grain that still answers the decision (`user_type` over `user_id` when it's enough); before sending an identifier, ask "what decision becomes impossible without it"
3. **Retention limit** — set GA4's data-retention setting to the actual need and review it periodically; the backend's "ID ↔ real customer" mapping table needs its own deletion schedule too
4. **Access control** — who can view GA4, who can export to BigQuery, who can reach the mapping table, each separately controlled and logged. **Whoever can reach the mapping table is seeing the equivalent of a direct identifier**

## Hashing is not anonymization

The most commonly misused pair of terms. Keep event properties free of PII (email, phone, name, full order number), linking instead through an internal **pseudonymized** ID. Say "pseudonymized," never "anonymized": if your own backend holds an "analytics ID ↔ real customer" mapping and can reverse it, that ID is pseudonymized, and under most privacy law still counts as "indirectly identifiable" personal data.

**"We hashed it, so it's anonymized" is wrong.** Whether a hash is reversible and whether the record can identify a specific person are two different questions. Fields like email, phone, and national ID have a **small, fixed-format value space** — anyone with the hash can hash a known list themselves and match it (dictionary/rainbow-table attack), or join the same hash value across other datasets. A salt only raises the attack cost; as long as you (or anyone) still hold the salt and the enumerable source values, reversal back to a specific person is still possible.

**What actually determines anonymization is a re-identification risk assessment, not which technique was used** — the question is: can anyone (including you, a data recipient, or a third party with access to other public datasets), using reasonably available methods and cost, link this record back to a specific person? Genuine anonymization comes from reducing the data's own identifiability:

- **Aggregation** — output only group-level statistics, never a person-level row
- **Generalization** — coarsen precise values (birthdate → birth year; full address → city; exact timestamp → date)
- **Suppression** — drop small-cell combinations outright, so no group-of-one gets exposed
- **Joint evaluation of quasi-identifiers** — region + age + gender + occupation can each look harmless alone and still point to one person combined

Anything not put through this treatment — reversible, or not reversible but still enumerable/linkable back to a person — stays classified as **pseudonymized personal data**, still governed by privacy law. Don't tell a client "we hashed it, so it's not personal data."

## Special-category data

Health records, medical/genetic data, sexual orientation, criminal history and similar categories carry stricter rules in most jurisdictions than ordinary personal data — "we're only sending a pseudonymous ID" doesn't route around this. An event name alone can disclose special-category data (`booked_hiv_test`), even with a pseudonymous identifier. A tracking plan for a regulated industry needs its own separate pass through this — see the GEO module for jurisdiction-specific categories and rules.

## Data inventory: the process (jurisdiction-agnostic; legal citations live in the GEO module)

Every jurisdiction's definition of personal data is broad enough that a fixed list of field names can't exhaust it — inventory the data first, then judge.

### Step 1: data inventory (don't skip this)

Go through every property/identifier in the tracking plan and ask: "does this field, alone or combined with others, identify a specific person?"

- **Direct identifier (never enters an analytics tool — see the table above)**: email, phone, name, national ID, address, credit card, a reverse-identifiable order number, plus any hash of these; also anything functionally equivalent to an account (an `account_id`, member number, or enumerable sequential ID)
- **Opaque pseudonymous identifier (personal data, usable under the four preconditions above)**: GA4 `client_id`, a random-UUID `transaction_id`, a backend-random internal `user_id`, a mobile ad ID, cross-site identifiers like `gclid`/`fbclid`
- **Needs context to judge**: a source URL (if it carries an identifying parameter), whether an event name itself discloses special-category data, a combination of custom properties (e.g. "region + birth year + gender + occupation" — no single field is personal data, but the combination might pin down a very small group)
- **Record the outcome**: which field, personal-data or not, and why — this record is itself part of most jurisdictions' "keep a record of processing basis" requirement

### Step 2: collection legal basis and use legal basis are two separate gates

Most privacy regimes split "was collecting this data ever lawful" from "is this particular use of it lawful" into two independent questions — clearing the first doesn't clear the second. Different uses of the same tracking data (internal analytics only; feeding conversions back to an ad platform; audience-building and remarketing) typically need to be checked separately, since a use that goes beyond the originally-disclosed purpose needs its own separate basis. See the GEO module for which specific legal bases and articles apply.

**A practical test that travels across jurisdictions**: "does what I'm about to do fall inside the collection purpose stated in the privacy policy? Would an ordinary user reading that text expect me to be doing this?" A "no" means it's a new purpose needing its own basis, regardless of which specific law governs it.

### Step 3: notice obligation

The site needs a privacy policy stating who's collecting, what for, what categories of data, how long and where it's used, the user's rights, and the consequence of refusing — and it needs to disclose the use of analytics tools (GA4/GTM) and that data may transfer to a foreign server (GA4 data is processed on Google's US infrastructure). See the GEO module for the specific statutory notice requirements that apply.

**A GA4 privacy-policy disclosure obligation isn't only a function of local-law inventory results.** Even when local law doesn't mandate notice for a given field, **Google Analytics' own terms of service independently require disclosing GA4/cookie use and obtaining consent where the law requires it** — a contractual obligation to Google, separate from whatever the local privacy-law inventory concludes, and it has to be checked on its own.

### Consent-to-refuse mechanism: has to be a real technical control, not a mailbox

Wherever a jurisdiction requires an opt-out from marketing use, it has to be implemented as an actual mechanism, not left to a support inbox: ① a findable, clickable opt-out entry point ② pressing it **actually stops use** — stops sending that user's events to ad platforms, removes them from any existing audience/customer-match list (a suppression list applied before every upload) ③ this state persists — clearing cookies doesn't undo it. **An opt-out button that fails ② is worse than no button** — it's a false representation to the user.

## Multi-jurisdiction: obligations can stack, they don't switch based on visitor location

A single site can be subject to more than one jurisdiction's privacy regime simultaneously — each is triggered independently, not selected by "where most visitors are." A regime with extraterritorial reach (monitoring a foreign jurisdiction's residents' behavior, not just selling to them) can apply even to a site that never targeted that market. **Don't tell a user "no consent mechanism needed" before the data inventory and market-scope review are actually done** — that conclusion depends on having confirmed no out-of-necessity personal-data collection and no other jurisdiction's extraterritorial reach triggered; if the review isn't finished, say so plainly rather than promising a conclusion you haven't earned.

This pack ships legal specifics only for the GEO modules it currently has (`profile.md`'s `geo` field names which ones — see `references/geo/<code>.md`). A market listed in `geo` with no shipped module isn't silently skipped: say so, and look up that jurisdiction's current official regime rather than guessing or reusing another market's rules.

## Other

- Never populate a property field with name, national ID, or full phone number.
- A client in a specially sensitive industry (finance, healthcare) needs their own legal counsel's sign-off on tracking scope and ongoing regulatory changes.
- Set retention periods to actual need — never retain user-level personal data indefinitely.
