# Real-time outbreak analysis with AI agents

A0 portrait poster: lessons from building and running a live model of the 2026 Ebola (Bundibugyo virus) outbreak in DRC with AI agents.

## Building

The poster is written in [Typst](https://typst.app) 0.15 and uses the Open Sans font.

```sh
typst compile poster.typ                         # draft copy, drafted text underlined
typst compile --input drafts=false poster.typ    # print copy
```

Every push builds both copies on GitHub Actions; download them from the run's `poster` artifact. PDFs are not committed.

## Forecast reconstruction

The cumulative-forecast figure is recomputed from the posterior draws in release `results-1002` (26 June 2026) of [epiforecasts/BVDOutbreakSize](https://github.com/epiforecasts/BVDOutbreakSize), applying the faulty projection (cumulative total scaled by the growth factor) and the fixed one (total plus projected new cases):

```sh
gh release download results-1002 -R epiforecasts/BVDOutbreakSize -p posterior_draws.csv
python3 -I scripts/cumulative_bug.py posterior_draws.csv data/cumulative_bug.json
```

## Material from other projects

Three figures reuse material from related work:

- The health-zone map is a capture of the live BVDOutbreakSize dashboard, data to 18 November 2026.
- The model diagram is redrawn from the methods page of BVDOutbreakSize.
- The six-step figure shows our modelling workflow; see Abbott et al. ([doi:10.5281/zenodo.19097427](https://doi.org/10.5281/zenodo.19097427)).
