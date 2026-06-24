"""Print a summary table of benchmark results."""
import json
import os
import glob

results_dir = "results"
json_files = sorted(glob.glob(f"{results_dir}/*.json"))

if not json_files:
    print("  No results found.")
    raise SystemExit(0)

print(f"  {'variant':<20} {'mean':>14} {'median':>14} {'min':>14} {'max':>14}")
print(f"  {'-'*20} {'-'*14} {'-'*14} {'-'*14} {'-'*14}")

for path in json_files:
    name = os.path.basename(path)[:-5]
    try:
        with open(path) as f:
            data = json.load(f)
    except json.JSONDecodeError:
        print(f"  {name:<20} (couldn't parse JSON — file may contain an error)")
        continue

    means = []
    unit = "?"
    for b in data.get("benchmarks", []):
        if not b["name"].endswith(("_mean", "_median", "_stddev", "_cv")):
            means.append(b["real_time"])
            unit = b.get("time_unit", "?")

    if not means:
        print(f"  {name:<20} (no runs in results)")
        continue

    import statistics
    mean_v = statistics.mean(means)
    median_v = statistics.median(means)
    min_v = min(means)
    max_v = max(means)
    print(f"  {name:<20} {mean_v:>10.3f} {unit:>3} {median_v:>10.3f} {unit:>3} {min_v:>10.3f} {unit:>3} {max_v:>10.3f} {unit:>3}")