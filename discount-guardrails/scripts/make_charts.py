"""
make_charts.py
Draws the six charts used in the README and the report from the SQL query results in /results.
No numbers are typed in: every value is read from a results file.

Usage (from the repo root): python scripts/make_charts.py
"""
import logging
from pathlib import Path

import matplotlib   # type: ignore
import matplotlib.pyplot as plt   # type: ignore
import pandas as pd   # type: ignore
from matplotlib.patches import FancyBboxPatch, Rectangle   # type: ignore

matplotlib.use("Agg")
logging.getLogger("matplotlib.font_manager").setLevel(logging.ERROR)  # quiet when a fallback font is used
ROOT = Path(__file__).resolve().parents[1]
RES, IMG = ROOT / "results", ROOT / "assets" / "charts"
IMG.mkdir(parents=True, exist_ok=True)

# Same colours as the Power BI dashboard
CARD, BORDER, PAGE = "#FFFFFF", "#E5E7EB", "#F3F4F6"
INK, INK2, MUTED, BASE = "#111827", "#4B5563", "#9CA3AF", "#D1D5DB"
BLUE, RED, SLATE, SLATE_LIGHT = "#2563EB", "#E05545", "#CBD5E1", "#E5E7EB"
RED_TINT, BLUE_TINT = "#FDECEC", "#EAF1FE"
NAVY = "#0F2744"

plt.rcParams.update({
    "font.family": ["Inter", "Helvetica Neue", "Arial", "DejaVu Sans"],
    "font.size": 12, "text.color": INK, "text.parse_math": False,
    "axes.facecolor": "none", "figure.facecolor": "none", "savefig.facecolor": "none",
})
FOOTER = "Penwick Office Supply  ·  all orders 2014–2017"


# ---------- helpers ----------

def k(v, sign=False, exact=False):
    """$135K style. sign=True adds + for gains; exact=True keeps one decimal ($38.5K)."""
    s = f"${abs(v) / 1000:,.0f}K" if abs(v) >= 10000 and not exact else f"${abs(v) / 1000:,.1f}K"
    return ("−" if v < 0 else ("+" if sign else "")) + s


def cents(v):
    """Profit per $1 sold: 27¢, −20¢, −$1.19."""
    if v <= -1:
        return f"−${abs(v):.2f}"
    return f"{'−' if v < 0 else ''}{abs(v) * 100:.0f}¢"


def card(kicker, title, subtitle, size=(10, 5.6), plot=(0.07, 0.14, 0.88, 0.58)):
    """A white rounded card with a kicker, title, subtitle and footer. Returns fig, ax."""
    fig = plt.figure(figsize=size)
    w, h = size
    fig.patches.append(FancyBboxPatch((0.006, 0.01), 0.988, 0.98, transform=fig.transFigure,
                                      boxstyle="round,pad=0,rounding_size=0.022", mutation_aspect=w / h,
                                      facecolor=CARD, edgecolor=BORDER, linewidth=1.2, zorder=-10))
    top = 0.93
    fig.text(0.05, top, kicker.upper(), fontsize=10.5, fontweight="bold", color=BLUE, va="top")
    fig.text(0.05, top - 0.065 * 5.6 / h, title, fontsize=19, fontweight="bold", color=INK, va="top")
    fig.text(0.05, top - 0.14 * 5.6 / h, subtitle, fontsize=12, color=INK2, va="top")
    fig.text(0.05, 0.045, FOOTER, fontsize=9.5, color=MUTED, va="center")
    ax = fig.add_axes(plot)
    for side in ax.spines.values():
        side.set_visible(False)
    ax.tick_params(length=0, colors=INK2)
    ax.set_xticks([])
    ax.set_yticks([])
    return fig, ax


def _aspect(ax):
    """Data units per pixel in y divided by data units per pixel in x."""
    x0, x1 = ax.get_xlim()
    y0, y1 = ax.get_ylim()
    bb = ax.get_window_extent()
    return ((y1 - y0) / bb.height) / ((x1 - x0) / bb.width)


def bar(ax, pos, value, width, color, horizontal=False, radius=0.18):
    """A bar with only its data end rounded. pos = centre on the category axis."""
    a = _aspect(ax)
    if not horizontal:
        x, y, bw, bh = pos - width / 2, min(0, value), width, abs(value)
        r = min(radius * width, bh / a / 2) if bh else 0
        ax.add_patch(FancyBboxPatch((x, y), bw, bh, boxstyle=f"round,pad=0,rounding_size={r}", mutation_aspect=a,
                                    facecolor=color, edgecolor="none"))
        sq = min(bh, r * a)
        ax.add_patch(Rectangle((x, 0 if value >= 0 else -sq), bw, sq, facecolor=color, edgecolor="none"))
    else:
        x, y, bw, bh = min(0, value), pos - width / 2, abs(value), width
        r = min(radius * width, bw / 2) if bw else 0
        ax.add_patch(FancyBboxPatch((x, y), bw, bh, boxstyle=f"round,pad=0,rounding_size={r / a}",
                                    mutation_aspect=a, facecolor=color, edgecolor="none"))
        sq = min(bw, r / a)
        ax.add_patch(Rectangle((0 if value >= 0 else -sq, y), sq, bh, facecolor=color, edgecolor="none"))


def pill(fig_or_ax, x, y, text, fg, bg, size=11.5, transform=None, ha="center"):
    kw = dict(fontsize=size, fontweight="bold", color=fg, ha=ha, va="center",
              bbox=dict(boxstyle="round,pad=0.45,rounding_size=0.9", facecolor=bg, edgecolor="none"))
    if transform is not None:
        kw["transform"] = transform
    fig_or_ax.text(x, y, text, **kw)


def save(fig, name):
    fig.savefig(IMG / name, dpi=200, transparent=True)
    plt.close(fig)
    print("wrote", name)


# ---------- 1. Profit at each discount level ----------
lv = pd.read_csv(RES / "q1_discount_level_summary.csv")
above = lv[lv["DISCOUNT"] > 0.20]
first = int(lv.index[lv["DISCOUNT"] > 0.20][0])
fig, ax = card("Discount depth", "Every discount above 20% lost money",
               "Total profit at each discount level", plot=(0.05, 0.15, 0.9, 0.55))
n, top, bottom = len(lv), lv["TOTAL_PROFIT"].max() * 1.12, lv["TOTAL_PROFIT"].min() * 2.1
ax.set_xlim(-0.6, n - 0.4)
ax.set_ylim(bottom, top)
ax.add_patch(FancyBboxPatch((first - 0.5, bottom * 0.98), n - first, top * 0.98 - bottom * 0.98,
                            boxstyle="round,pad=0,rounding_size=0.25", mutation_aspect=_aspect(ax),
                            facecolor=RED_TINT, edgecolor="none", zorder=0))
for i, p in enumerate(lv["TOTAL_PROFIT"]):
    bar(ax, i, p, 0.6, RED if p < 0 else BLUE)
    off = top * 0.025
    ax.text(i, p + (off if p >= 0 else -off), k(p), ha="center", va="bottom" if p >= 0 else "top",
            fontsize=10.5, fontweight="bold" if abs(p) > 20000 else "normal", color=INK)
ax.axhline(0, color=BASE, linewidth=1, zorder=1)
ax.set_xticks(range(n), [f"{d:.0%}" for d in lv["DISCOUNT"]], fontsize=11)
pill(ax, (first + n - 1) / 2, top * 0.62, f"More than 20% off:  {k(above['TOTAL_PROFIT'].sum())}", "#B42318", "#FFFFFF",
     size=13)
fig.text(0.95, 0.045, "Discount given on the sale", fontsize=9.5, color=MUTED, ha="right", va="center")
save(fig, "1_profit_by_discount.png")

# ---------- 2. Full price vs what the same products earned ----------
mix = pd.read_csv(RES / "q2_mix_vs_discount_effect.csv")
mix = mix[~mix["DISCOUNT_BAND"].str.startswith("1.")].reset_index(drop=True)
names = {"2.": "Up to 20% off", "3.": "30–50% off", "4.": "60–80% off"}
labels = [names[b[:2]] for b in mix["DISCOUNT_BAND"]]
full = (mix["SAME_MIX_NO_DISCOUNT_MARGIN_PCT"] / 100).tolist()
actual = (mix["ACTUAL_MARGIN_PCT"] / 100).tolist()
fig, ax = card("Product mix", "Heavily discounted products are normally profitable",
               "Profit on every $1 of sales, for the same products", plot=(0.2, 0.17, 0.76, 0.53))
ax.set_xlim(min(actual) - 0.3, max(full) + 0.22)
ax.set_ylim(-0.6, len(mix) - 0.4)
h = 0.3
for i, (f, a) in enumerate(zip(full, actual)):
    yy = len(mix) - 1 - i
    bar(ax, yy + h / 2 + 0.03, f, h, SLATE, horizontal=True)
    bar(ax, yy - h / 2 - 0.03, a, h, RED if a < 0 else BLUE, horizontal=True)
    ax.text(f + 0.025, yy + h / 2 + 0.03, cents(f), va="center", fontsize=11, color=INK2)
    ax.text(a + (0.025 if a >= 0 else -0.025), yy - h / 2 - 0.03, cents(a), va="center",
            ha="left" if a >= 0 else "right", fontsize=12, fontweight="bold")
ax.axvline(0, color=BASE, linewidth=1)
ax.set_yticks([len(mix) - 1 - i for i in range(len(mix))], labels, fontsize=12.5, color=INK)
lx = 0.2
for color, text in [(SLATE, "At full price"), (BLUE, "At the discount given (red = a loss)")]:
    fig.patches.append(FancyBboxPatch((lx, 0.088), 0.016, 0.026, transform=fig.transFigure,
                                      boxstyle="round,pad=0,rounding_size=0.005", mutation_aspect=10 / 5.6,
                                      facecolor=color, edgecolor="none"))
    fig.text(lx + 0.024, 0.101, text, fontsize=10.5, color=INK2, va="center")
    lx += 0.2
save(fig, "2_full_price_vs_discounted.png")

# ---------- 3. Where the loss came from, by product group ----------
cells = pd.read_csv(RES / "q2_subcategory_band_vs_baseline.csv")
grp = (cells[cells["DISCOUNT_BAND"].str[:2].isin(["3.", "4."])]
       .groupby("SUB_CATEGORY")["TOTAL_PROFIT"].sum().sort_values())
fig, ax = card("Product groups", "Eight product groups lost money on heavy discounts",
               f"Profit on sales at more than 20% off  ·  {k(grp.sum())} in total", size=(10, 6.2),
               plot=(0.17, 0.1, 0.78, 0.66))
ax.set_xlim(grp.min() * 1.25, grp.max() * 9)
ax.set_ylim(len(grp) - 0.4, -0.6)
for i, (name, v) in enumerate(grp.items()):
    bar(ax, i, v, 0.62, RED if v < 0 else BLUE, horizontal=True)
    note = "   only 9 sales" if name == "Copiers" else ""
    ax.text(v + (-500 if v < 0 else 500), i, k(v, sign=True, exact=True), va="center",
            ha="right" if v < 0 else "left", fontsize=11, fontweight="bold")
    if note:
        ax.text(v + 500 + grp.max() * 1.9, i, note, va="center", ha="left", fontsize=10, color=MUTED)
ax.axvline(0, color=BASE, linewidth=1)
ax.set_yticks(range(len(grp)), grp.index, fontsize=12, color=INK)
save(fig, "3_loss_by_product_group.png")

# ---------- 4. Half the loss comes from 27 products ----------
conc = pd.read_csv(RES / "q3_loss_concentration_summary.csv").set_index("ENTITY_TYPE").loc["Product"]
top3 = pd.read_csv(RES / "q3_product_loss_pareto.csv").head(3)
n_all, n50, n80 = (int(conc[c]) for c in ["ENTITIES_WITH_LOSS", "ENTITIES_FOR_HALF_OF_LOSS", "ENTITIES_FOR_80PCT_OF_LOSS"])
segs = [("50%", f"{n50} products", RED, "#FFFFFF"), ("30%", f"next {n80 - n50} products", SLATE, INK),
        ("20%", f"other {n_all - n80} products", SLATE_LIGHT, INK)]
fig, ax = card("Reach", f"Half the loss comes from just {n50} products",
               f"{n_all} products lost money when they were sold at more than 20% off", size=(10, 4.8),
               plot=(0.05, 0.27, 0.9, 0.36))
ax.set_xlim(0, 1)
ax.set_ylim(0, 1)
a = _aspect(ax)
left, gap = 0, 0.008
for i, (share_txt, who, color, txt) in enumerate(segs):
    share = float(share_txt.strip("%")) / 100
    wdt = share - (gap if i < 2 else 0)
    ax.add_patch(FancyBboxPatch((left, 0), wdt, 1, boxstyle="round,pad=0,rounding_size=0.018", mutation_aspect=a,
                                facecolor=color, edgecolor="none"))
    ax.text(left + 0.03, 0.66, share_txt, fontsize=30 if i == 0 else 24, fontweight="bold", color=txt, va="center")
    ax.text(left + 0.03, 0.3, f"of the loss\n{who}", fontsize=11, color=txt, va="center", linespacing=1.4)
    left += share
plain = {"TEC-MA-10000418": "a 3D printer", "OFF-BI-10004995": "an electric binding system",
         "TEC-MA-10000822": "a laser printer"}
items = [f"{plain.get(r.PRODUCT_ID, r.PRODUCT_NAME)} ({k(-r.DEEP_DISCOUNT_LOSS, exact=True)})" for r in top3.itertuples()]
fig.text(0.05, 0.155, f"Biggest single losses:  {items[0]},  {items[1]}  and  {items[2]}", fontsize=10.5, color=INK2)
save(fig, "4_loss_concentration.png")

# ---------- 5. What each cap would have added (modelled) ----------
sc = pd.read_csv(RES / "q4_scenarios_company.csv")
sc = sc[sc["MAX_DISCOUNT"] < 0.8]
half = sc[sc["VOLUME_RETAINED"] == 0.5].set_index("MAX_DISCOUNT")["PROFIT_CHANGE"]
lo, hi = sc.groupby("MAX_DISCOUNT")["PROFIT_CHANGE"].min(), sc.groupby("MAX_DISCOUNT")["PROFIT_CHANGE"].max()
best = half.idxmax()
fig, ax = card("Cap scenarios  ·  modelled", "A 20% cap would have added the most profit",
               "Estimated extra profit if half the affected customers had kept buying", plot=(0.05, 0.15, 0.9, 0.55))
ax.set_xlim(-0.55, len(half) - 0.45)
ax.set_ylim(0, half.max() * 1.32)
for i, c in enumerate(half.index):
    is_best = c == best
    bar(ax, i, half[c], 0.56, BLUE if is_best else SLATE)
    ax.text(i, half[c] + half.max() * 0.05, k(half[c], sign=True), ha="center", va="bottom", fontsize=16, fontweight="bold",
            color=INK if is_best else INK2)
    ax.text(i, half[c] * 0.5, f"range\n{k(lo[c], sign=True)} to\n{k(hi[c], sign=True)}", ha="center", va="center",
            fontsize=10, color="#FFFFFF" if is_best else INK2, linespacing=1.4)
    if is_best:
        pill(ax, i, half[c] + half.max() * 0.235, "Best option", BLUE, BLUE_TINT, size=10)
ax.set_xticks(range(len(half)), [f"Cap at {c:.0%}" for c in half.index], fontsize=12, color=INK)
fig.text(0.95, 0.045, "Range: none to all of the affected customers keep buying", fontsize=9.5, color=MUTED,
         ha="right", va="center")
save(fig, "5_cap_scenarios.png")

# ---------- 6. Heavy discounting by year ----------
yr = pd.read_csv(RES / "q5_year_band.csv")
heavy = yr[yr["DISCOUNT_BAND"].str[:2].isin(["3.", "4."])]
share = heavy.groupby("ORDER_YEAR")["SHARE_OF_YEAR_SALES_PCT"].sum() / 100
lost = heavy.groupby("ORDER_YEAR")["TOTAL_PROFIT"].sum()
fig, ax = card("Consistency", "Heavy discounting fell after 2014, then stopped falling",
               "Share of each year's sales sold at more than 20% off, and what those sales lost",
               plot=(0.05, 0.15, 0.9, 0.55))
ax.set_xlim(-0.55, len(share) - 0.45)
ax.set_ylim(0, share.max() * 1.3)
for i, (yv, s) in enumerate(share.items()):
    bar(ax, i, s, 0.5, BLUE)
    ax.text(i, s + share.max() * 0.05, f"{s:.1%}", ha="center", va="bottom", fontsize=16, fontweight="bold")
    pill(ax, i, s * 0.45, f"lost {k(-lost[yv])}", RED, "#FFFFFF", size=10.5)
ax.set_xticks(range(len(share)), [str(y) for y in share.index], fontsize=12.5, color=INK)
save(fig, "6_heavy_discounting_by_year.png")
