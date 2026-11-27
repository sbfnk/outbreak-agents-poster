# Real-time outbreak analysis with AI agents

A0 portrait poster: lessons from building and running a live model of the 2026 Ebola (Bundibugyo virus) outbreak in DRC with AI agents.

## Building

The poster is written in [Typst](https://typst.app) 0.15 and uses the Open Sans font.

```sh
typst compile poster.typ                         # draft copy, drafted text underlined
typst compile --input drafts=false poster.typ    # print copy
```

Every push builds both copies on GitHub Actions; download them from the run's `poster` artifact. PDFs are not committed.

## Forecast figure

The cumulative-forecast figure shows the published one-week 90%, 60% and 30% intervals for cumulative confirmed cases by 30 June, from the forecast table in release `results-1002` (26 June 2026) of [epiforecasts/BVDOutbreakSize](https://github.com/epiforecasts/BVDOutbreakSize), set in `poster.typ`. The reported counts to the 23 June cut-off come from `data/cumulative_bug.json`, which `scripts/cumulative_bug.py` writes from that release's posterior draws; the script also recomputes the faulty projection (cumulative total scaled by the growth factor) against the fixed one (total plus projected new cases), which the poster no longer plots:

```sh
gh release download results-1002 -R epiforecasts/BVDOutbreakSize -p posterior_draws.csv
python3 -I scripts/cumulative_bug.py posterior_draws.csv data/cumulative_bug.json
```

## Material from other projects

Two figures reuse material from related work:

- The dashboard is a capture of the live BVDOutbreakSize dashboard, data to 18 November 2026.
- The humans-and-agents schematic is the title figure of Sam Abbott's talk on AI agents in infectious disease modelling at the HPRU Network launch, November 2026 ([seabbs/HPRUNetworkAgentsandIDM](https://github.com/seabbs/HPRUNetworkAgentsandIDM)).
