# Run the SQL on SQL Server (macOS, Docker, VS Code)

The following guideline is applicable for macOS. But, on Windows, the steps are the same without Rosetta.

## 1. Install the tools

1. **Docker Desktop.** On an Apple Silicon Mac (M1 or later), open *Settings → General* and tick **Use Rosetta for x86_64/amd64 emulation on Apple Silicon**. The SQL Server image is built for Intel chips, and Rosetta runs it.
2. **VS Code** with the **MSSQL** extension from Microsoft (Extensions view → search `mssql` → Install).

## 2. Start SQL Server

Open the repository folder in VS Code and open a terminal (*Terminal → New Terminal*).

If there is already a container called `mssql_server` (check with `docker ps -a`), start it with `docker start mssql_server`. Otherwise create one. Keep the single quotes, and use your own password: at least 8 characters with upper case, lower case, a digit and a symbol.

```bash
docker run --platform linux/amd64 \
  -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=<YourStrong!Password>' \
  -p 1433:1433 --name mssql_server \
  -d mcr.microsoft.com/mssql/server:2022-latest
```

After thaat this should print a line:

```bash
docker logs mssql_server 2>&1 | grep "ready for client"
```

## 3. Copy the CSVs into the container

SQL Server runs inside the container and cannot see your Mac's files.

```bash
docker cp data/CUSTOMER.csv  mssql_server:/var/opt/mssql/CUSTOMER.csv
docker cp data/EMPLOYEES.csv mssql_server:/var/opt/mssql/EMPLOYEES.csv
docker cp data/ORDERS.csv    mssql_server:/var/opt/mssql/ORDERS.csv
docker cp data/PRODUCT.csv   mssql_server:/var/opt/mssql/PRODUCT.csv
```

## 4. Connect from VS Code

SQL Server icon in the sidebar → **Add Connection**:

| Field | Value |
|---|---|
| Server | `localhost` |
| Authentication | SQL Login |
| User / password | `sa` / your password |
| Trust server certificate | ticked (the container uses a self-signed certificate) |

Open a **New Query** on that connection and run:

```sql
CREATE DATABASE DiscountGuardrails;
```

Then add a second connection, the same as above but with **Database = `DiscountGuardrails`**, and use it from here on. The scripts have no `USE` statement, so this decides where the tables are created. `SELECT DB_NAME();` should return `DiscountGuardrails`.

## 5. Run the scripts

Open each file, choose the DiscountGuardrails connection, and click **Run**. Always run the whole file, never a selection.

| Order | Script | Expected |
|---|---|---|
| 1 | `sql/1_setup/00_load.sql` | CUSTOMER 793, EMPLOYEES 9, PRODUCT 1,862, ORDERS 9,994 |
| 2 | `sql/1_setup/01_fact_view.sql` | "Commands completed successfully" |
| 3–7 | `sql/2_analysis/10_…` to `14_…` | Result sets that match the CSVs in `results/` (e.g. total profit \$286,397.02) |
| 8–9 | `sql/3_procedures/20_…`, `30_…` | The procedure is created, then run as an example |
| 10 | `sql/4_tests/90_tests.sql` | **PASS on every row** |

## Troubleshooting

| Message | Fix |
|---|---|
| *Cannot bulk load … could not be opened (error code 2)* | A CSV is missing from the container. Repeat step 3. |
| *Invalid object name 'dbo.ORDERS'* | The query is connected to `master`. Switch to the DiscountGuardrails connection. |
| Certificate error or *Login failed* | Tick *Trust server certificate*; check the password. |
| Container stops straight away | Run `docker logs mssql_server`. Usually the password is too weak. |
| Port 1433 already in use | Use `-p 1434:1433` and connect to `localhost,1434`. |

## Using SQLTools instead of the MSSQL extension

Two things behave differently in SQLTools:

- **Long scripts drop the connection** ("Connection lost – socket hang up"). Raise the packet size so each script goes to the server in one piece. In the workspace `settings.json`, add this inside the connection's `"mssqlOptions"`, then disconnect and reconnect:

  ```json
  "options": { "packetSize": 32767 }
  ```

- **SQLTools removes `GO` and sends the file as one batch.** In `20_scenario_procedure.sql` and `30_monitoring_procedure.sql`, run the `CREATE OR ALTER PROCEDURE … END;` part first, then select the `EXEC` lines and run them separately. Otherwise the example `EXEC` ends up inside the procedure.

`sqlcmd` inside the container handles both without any changes:

```bash
docker exec -i mssql_server /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "\$SA_PW" -C -d DiscountGuardrails < sql/2_analysis/11_q2_discount_or_product.sql
```

A few product and customer names contain accented characters that may look garbled after `BULK INSERT` on Linux. No number or check depends on them.

When finished: `docker stop mssql_server`. `docker start mssql_server` brings it back with the data still loaded.
