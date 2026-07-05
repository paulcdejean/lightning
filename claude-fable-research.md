# Claude Fable 5 — Comprehensive Research Summary

## 1. What Is Claude Fable?

**Claude Fable 5** is Anthropic's most capable publicly available model, released on **June 9, 2026**. It is the first model in a new **"Mythos-class"** tier — a capability class *above* the Opus line (Opus 4.8 was the prior top-tier model, released May 28, 2026).

### Key Relationship: Fable 5 vs. Mythos 5

- **Fable 5 and Mythos 5 are the same underlying model.** The difference is purely the guardrails around them.
- **Claude Fable 5** = public version with safety classifiers active. Available via API, Claude apps, and Amazon Bedrock.
- **Claude Mythos 5** = same model with safeguards lifted in some areas (cybersecurity, biology). Restricted to vetted partners through **Project Glasswing** (US government collaboration, launched April 2026).
- One outlet described it: "Fable is Mythos on a leash."

The names are intentional Latin/Greek counterparts: *Fable* (from Latin *fabula* = "that which is told") and *Mythos* (Greek). What separates them is the safety system, not the model capability.

### How It Fits in the Claude Family

| Tier | Models (latest) | API ID on OpenRouter | Purpose |
|------|----------------|---------------------|---------|
| **Mythos** | Fable 5 (public), Mythos 5 (restricted) | `anthropic/claude-fable-5` | Frontier — most capable, safety-gated |
| **Opus** | Opus 4.8 | `anthropic/claude-opus-4.8` | Highest prior tier; now the safety fallback for Fable |
| **Sonnet** | Sonnet 4, 4.5, 4.6, 5 | `anthropic/claude-sonnet-5` | Balanced performance/cost |
| **Haiku** | Haiku 4.5 | `anthropic/claude-haiku-4.5` | Fastest, cheapest |

---

## 2. Release Timeline & Significance

- **April 2026** — Claude Mythos Preview launched inside Project Glasswing (restricted, vetted partners only)
- **May 28, 2026** — Claude Opus 4.8 released (prior public best)
- **June 9, 2026** — **Claude Fable 5 and Claude Mythos 5 announced** and made available
- **June 12, 2026** — Access temporarily suspended (brief interruption)
- **July 1, 2026** — Redeployed, fully available again

### Significance

Fable 5 represents a **new capability tier** beyond anything Anthropic had released publicly before. The company explicitly stated that Mythos-class models had reached a threshold where they present "significant risks" — particularly in cybersecurity and bio/chem domains. Fable 5 is significant because:

1. It's the **first time a model of this capability class was judged safe enough for broad public access** — the key enabler was the classifier-based safety architecture, not a weaker model.
2. It established a **new release model** for frontier AI: capability gated by deterministic classifiers + tiered trusted access + mandatory data retention — a template other labs may follow.
3. It shipped just days after Anthropic publicly warned that frontier AI is becoming "dangerously capable."

---

## 3. Key Capabilities

### General Profile
- **Not a pure reasoning model or pure coding model** — it's a **general-purpose frontier model** with exceptional performance across domains
- Architecture: text+image+file input → text output (modality: multimodal)
- Context window: **1,000,000 tokens**
- Max output: **up to 128,000 tokens** per response
- Tokenizer: Claude (OpenRouter lists it as "Router" for the `~anthropic/claude-fable-latest` alias)

### Strengths (per Anthropic + early testers)

**Software Engineering:**
- Stripe: Fable 5 compressed months of engineering into days; migrated a 50-million-line Ruby codebase in one day (would have taken a team 2+ months)
- **#1 on Cognition's FrontierCode** evaluation (highest score among frontier models)
- **#1 on CursorBench** (per Cursor CEO Michael Truell)
- **#1 on GitHub's internal testing** — "a real step forward" (per Mario Rodriguez, GitHub CPO)
- Independent SWE-Bench Pro: **~80.3%** vs Opus 4.8 at ~69.2% vs GPT-5.5 at ~58.6%

**Knowledge Work / Finance:**
- **#1 on Hebbia's Finance Benchmark** (senior-level reasoning)
- IMC: Fable 5 aced trading-analysis evaluations "nearly across the board"

**Vision:**
- Called "new state of the art" by Anthropic
- Can rebuild a web app's source code from screenshots alone
- Beat Pokémon FireRed with a minimal vision-only harness (earlier Claude models needed complex helper tools)

**Scientific Research:**
- Mythos 5: 10× speedup in protein/drug design pipeline
- 9 of 14 protein targets produced strong drug-design candidates
- First model to consistently produce novel scientific hypotheses (~80% preferred over Opus in blinded comparisons)
- Autonomous genomics research: assembled data for 138 animal species, trained custom ML model that outperformed a *Science*-published model at 1/100th the size

**Memory & Long Context:**
- Stays focused across millions of tokens
- Persistent file-based memory in Slay the Spire benchmark: 3× improvement over Opus 4.8, reached final act 3× more often

### The Consistent Pattern
> "The longer and more complex the task, the larger Fable 5's lead over other models."

This makes it purpose-built for **agentic, long-horizon, multi-step tasks** — exactly where weaker models lose the plot.

---

## 4. Pricing

### Anthropic Direct (also OpenRouter)

| | Input (per 1M tokens) | Output (per 1M tokens) |
|---|---|---|
| **Claude Fable 5** | **$10.00** | **$50.00** |
| Claude Opus 4.8 | $5.00 | $25.00 |
| Claude Sonnet 5 | $2.00 | $10.00 |
| Claude Haiku 4.5 | $1.00 | $5.00 |

**OpenRouter pricing** (from API query, confirmed matching Anthropic direct):
- `anthropic/claude-fable-5`: prompt=$0.00001/token ($10/1M), completion=$0.00005/token ($50/1M)
- `~anthropic/claude-fable-latest`: same pricing (alias pointing to latest Fable 5 version)
- Prompt caching: ~90% discount on cached input reads ($0.000001/token)
- Web search: $0.01 per search query
- Fable 5 costs **exactly 2× Opus 4.8** and **less than half of the prior Mythos Preview**

### Free Access Window
- Free for Claude Pro/Max/Team/Enterprise subscribers **June 9–June 22, 2026**
- After June 23: requires usage credits / consumption-based billing
- Eventually to be restored as a standard plan feature

---

## 5. Benchmarks & Reviews

### Official (Anthropic-reported)

| Benchmark | Fable 5 | Opus 4.8 | GPT-5.5 | Gemini 3.1 Pro |
|-----------|---------|----------|---------|-----------------|
| SWE-Bench Pro | **80.3%** | 69.2% | 58.6% | 54.2% |
| FrontierCode Diamond | **29.3%** | ~14% | — | — |
| Humanity's Last Exam (no tools) | **59.0%** | — | 52.2% | — |
| Humanity's Last Exam (with tools) | **64.5%** | — | — | — |
| Hex core analytics | **>90%** | — | — | — |
| Spatial reasoning | **38.6%** | 14.5% | — | — |
| Terminal-Bench 2.1 | **88.0%** | — | 83.4% | — |

### Notable Customer Quotes

- **Stripe**: "Compressed months of engineering into days"
- **GitHub CPO**: "A real step forward... took on complex, long-horizon coding tasks with a level of autonomy and reliability that exceeded previous benchmarks"
- **Cognition CEO Scott Wu**: "Highest-scoring model on FrontierBench... excels at long-horizon reasoning and generalizes to unfamiliar tools"
- **Cursor CEO Michael Truell**: "State of the art model on CursorBench... opened up a class of long-horizon problems that were out of reach"
- **Replit CPO**: "The strongest results of any Claude model we've had the opportunity to test"

---

## 6. Safety Architecture (Key Distinction)

Fable 5's safety system is **what made public release possible** and is the core differentiator from Mythos 5:

**Classifier System:**
- Separate AI systems detect potential misuse in **3 domains**:
  1. **Cybersecurity** — exploit development, offensive cyber tasks, agentic hacking
  2. **Biology & Chemistry** — dual-use bio/chem capabilities
  3. **Distillation** — attempts to extract model capabilities for training competitors

**Fallback Design:**
- When a classifier triggers → the request is handled by **Claude Opus 4.8** (not refused)
- User is informed when a handoff occurs
- **>95% of sessions run fully on Fable 5** — no fallback
- **<5% trigger the Opus 4.8 handoff**

**Robustness:**
- 1,000+ hours of external bug-bounty testing with **no universal jailbreaks found**
- Rated strongest protection against harmful cyber queries of any model tested (by external partner)
- UK AISI made some progress within a brief testing window but no full break

**Data Retention:**
- Mandatory **30-day retention** for all Mythos-class model traffic
- Not used for training; logged human access; deleted after 30 days
- Designed to defend against complex multi-request attacks and reduce false positives

---

## 7. How It Relates to the Claude Family

The Claude model family has evolved through these tiers:

```
Claude 1 (Mar 2023) → Claude 2 → Claude 3 (Haiku/Sonnet/Opus) → 
Claude 3.5 → Claude 4 (Opus/Sonnet/Haiku 4.x) → 
Claude 4.8 (May 2026, prior top public) →
Claude 5 / Mythos-class: Fable 5 + Mythos 5 (Jun 2026)
```

**Opus** was the flagship tier through Claude 4.x. **Mythos** is a new tier *above* Opus, reflecting models that exceed Opus capability benchmarks by significant margins — large enough that Anthropic deems them qualitatively different in risk profile.

Fable 5 is the first **Claude 5** model, and the first time the public can access a Mythos-class model. It doesn't replace Sonnet/Haiku — those remain for faster/cheaper workloads. Instead, Fable 5 sits at the top as the "use it for the hardest problems" tier.

---

## Source URLs

1. **Anthropic Official Announcement**: https://www.anthropic.com/news/claude-fable-5-mythos-5
2. **Anthropic Platform Docs (Introducing Fable 5 & Mythos 5)**: https://platform.claude.com/docs/en/about-claude/models/introducing-claude-fable-5-and-claude-mythos-5
3. **Anthropic Claude Fable 5 Product Page**: https://www.anthropic.com/claude/fable
4. **Codersera Launch Guide (Pricing, Benchmarks, FAQ)**: https://codersera.com/blog/claude-fable-5-launch-guide-2026/
5. **TechTimes Coverage**: https://www.techtimes.com/articles/318082/20260609/anthropic-launches-claude-fable-5-most-powerful-public-model-gated-safeguards.htm
6. **Gera Rodríguez Field Note (Plain-English Briefing)**: https://gerardordz96.github.io/claude-fable-5/
7. **Cyrus "When Is Fable Coming Back?"**: https://www.atcyrus.com/stories/when-is-fable-coming-back
8. **Claude5.ai Launch Coverage**: https://claude5.ai/en/news/anthropic-launches-claude-fable-5-mythos-class-june-2026
9. **Claude Timeline / Release Dates**: https://www.scriptbyai.com/anthropic-claude-timeline/
10. **OpenRouter Model API** (pricing data pulled directly): https://openrouter.ai/api/v1/models
