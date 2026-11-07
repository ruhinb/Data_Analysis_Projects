# Power BI dashboard

A four-page dashboard on the same data as the SQL analysis, written for people who don't work with data every day. Profit is shown as cents per $1 sold, the discount groups have plain names, and each page title states its answer.

| Page | What it answers |
|---|---|
| Overview | How much heavy discounts cost, how the loss grows with discount size, how common heavy discounts are, and what to do next |
| Product groups | Which product groups need a 20% cap, which need a price review and which are fine, plus the five products to check first |
| What if we cap? | Profit with a 20% cap, depending on how many customers still buy. This page is a model, not a measured result |
| Quarterly check-up | The latest quarter against the one before, and a report card of heavy discounting by product group |

Page images: [overview](../assets/dashboard/overview.png) · [product groups](../assets/dashboard/groups.png) · [what if](../assets/dashboard/whatif.png) · [check-up](../assets/dashboard/monitor.png)

## How it's built

The semantic model (`DiscountGuardrails.SemanticModel/model.bim`) uses Power Query to read three CSVs from `data/`. The tables are Orders, Product, Customer and Discount Band, plus two small what-if tables, Volume Kept and Max Discount. There are 37 DAX measures, sorted into display folders (Core, Heavy discount, Scenario, Monitor). The band rule, the PRODUCT column fix and the what-if formula are the same as in the SQL.

Eight [Deneb](https://deneb.guide) visuals draw the text, numbers and charts from Vega specs. To read or edit a spec, select the visual in Power BI Desktop and choose *… → Edit*. Year, Region and "how many customers still buy" are normal Power BI slicers, and transparent buttons over the page tabs handle navigation.

Each page background is an image with only the shapes on it (cards, tints, icons). All the text is live and drawn in Segoe UI, so it changes with the filters.

I checked the figures against the SQL results. For example, a 20% cap with half the volume kept gives +$177,284 in both, and the whole-orders-lost case gives +$111,277.

## Opening it

Power BI Desktop only runs on Windows. On a Mac, use a Windows virtual machine (Parallels, for example) or a Windows PC.

1. Install the latest Power BI Desktop from the Microsoft Store. The report uses the PBIR format and a base theme from the October 2026 release. On an older version, either update or turn on *File → Options → Preview features → Power BI Project (.pbip) save option* and *Store reports using enhanced metadata format (PBIR)*.
2. Put the data where the model looks for it. The `DataFolder` parameter defaults to `C:\DiscountGuardrails\data\`. Copy the repo's `data` folder there, or open the project and change the path under *Transform data → Edit parameters → DataFolder*. The path has to end with a backslash.
3. Open `DiscountGuardrails.pbip` and click **Refresh**. A project file has no data in it until the first refresh.
4. Deneb loads from AppSource. If a visual asks for it, go to *Visualizations → … → Get more visuals*, search for Deneb, add it, then save and reopen.
5. While editing, Ctrl + click the page tabs to move between pages. In reading view or the Power BI service, a normal click works.

## Editing it

- To change a chart, select the visual and choose *… → Edit*. That opens the Deneb editor with the Vega spec. The specs refer to fields by their measure or column name, for example `datum['Heavy Sales']`.
- All the measures are in the `Orders` table, grouped by display folder.
- The background images are in `DiscountGuardrails.Report/StaticResources/RegisteredResources/`. To restyle a card, edit the image.

## Notes

- The report passes Microsoft's PBIR validator (`powerbi-report-author validate`) with no errors or warnings.
- The "What if we cap?" page models past orders. It isn't a forecast. The main report explains the assumptions.
- The data is a public sample and the Head of Sales is simulated.
