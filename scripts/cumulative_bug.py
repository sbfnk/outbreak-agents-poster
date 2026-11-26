"""Recompute the 26 June 2026 one-week projection of cumulative confirmed cases
with the buggy formula (total scaled by the growth factor) and the fixed one
(total plus projected new cases), from the posterior draws of the growth rate
in BVDOutbreakSize release results-1002.

Usage: python3 -I scripts/cumulative_bug.py posterior_draws.csv data/cumulative_bug.json
"""
import csv, json, math, sys
from datetime import date, timedelta

draws_path, out_path = sys.argv[1], sys.argv[2]
r = [float(row["r"]) for row in csv.DictReader(open(draws_path))]

# Confirmed cases, 29 May to 23 June (no SitRep on 12 June), from the
# release's observations.toml.
values = [263, 282, 321, 344, 363, 381, 452, 488, 515, 550, 598, 635, 676, 689,
          782, 808, 837, 875, 896, 933, 956, 1003, 1048, 1094, 1118]
days = [date(2026, 5, 29) + timedelta(days=i) for i in range(15)]
days = days[:14] + [date(2026, 6, 13) + timedelta(days=i) for i in range(11)]
observed = [{"day": (d - days[-1]).days, "value": v} for d, v in zip(days, values)]

c0 = values[-1]
# New confirmed cases per day at the cut-off: mean over the last six days.
i0 = (values[-1] - values[-7]) / 6
horizon = 7

def quantiles(xs, ps=(0.05, 0.5, 0.95)):
    # Linear interpolation between order statistics, as numpy's default.
    xs = sorted(xs)
    out = []
    for p in ps:
        pos = p * (len(xs) - 1)
        lo = int(pos)
        hi = min(lo + 1, len(xs) - 1)
        out.append(xs[lo] + (pos - lo) * (xs[hi] - xs[lo]))
    return out

bug, fix = [], []
for h in range(horizon + 1):
    b = [c0 * math.exp(ri * h) for ri in r]
    f = [c0 + sum(i0 * math.exp(ri * k) for k in range(1, h + 1)) for ri in r]
    bug.append({"day": h, "q": quantiles(b)})
    fix.append({"day": h, "q": quantiles(f)})

share_below = sum(1 for ri in r if ri < 0) / len(r)
json.dump({"observed": observed, "bug": bug, "fix": fix, "c0": c0, "i0": i0,
           "share_below": share_below, "draws": len(r)}, open(out_path, "w"), indent=1)
print(f"c0={c0} i0={i0:.1f} draws={len(r)} share r<0={share_below:.2f}")
print("bug day7", bug[-1]["q"], "fix day7", fix[-1]["q"])
