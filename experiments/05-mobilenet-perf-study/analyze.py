"""Generate a comparison chart from benchmark results."""
import json
import os
import glob
import statistics
import matplotlib
matplotlib.use("Agg")  # headless backend for WSL
import matplotlib.pyplot as plt

results_dir = "results"
charts_dir = "charts"
os.makedirs(charts_dir, exist_ok=True)

variants = {}
for path in sorted(glob.glob(f"{results_dir}/*.json")):
    name = os.path.basename(path)[:-5]
    try:
        with open(path) as f:
            data = json.load(f)
    except Exception:
        continue

    means = []
    for b in data.get("benchmarks", []):
        if not b["name"].endswith(("_mean", "_median", "_stddev", "_cv")):
            means.append(b["real_time"])

    if means:
        variants[name] = {
            "mean": statistics.mean(means),
            "median": statistics.median(means),
            "min": min(means),
            "max": max(means),
            "stddev": statistics.stdev(means) if len(means) > 1 else 0.0,
        }

# Sort by median for visual clarity
sorted_names = sorted(variants.keys(), key=lambda n: variants[n]["median"])

fig, ax = plt.subplots(figsize=(10, 6))
positions = range(len(sorted_names))
medians = [variants[n]["median"] for n in sorted_names]
errors = [variants[n]["stddev"] for n in sorted_names]

ax.bar(positions, medians, yerr=errors, capsize=5, color="#4a90e2", edgecolor="#2a2a2a")
ax.set_xticks(positions)
ax.set_xticklabels(sorted_names, rotation=20, ha="right")
ax.set_ylabel("Median inference latency (ms)")
ax.set_title("MobileNetV2 latency across compile-flag variants (10 reps each)")
ax.grid(axis="y", linestyle="--", alpha=0.4)

# Annotate bars with median value
for i, n in enumerate(sorted_names):
    ax.text(i, variants[n]["median"] + 2, f"{variants[n]['median']:.1f}",
            ha="center", fontsize=9)

plt.tight_layout()
out = os.path.join(charts_dir, "flag_comparison.png")
plt.savefig(out, dpi=120)
print(f"Saved chart: {out}")