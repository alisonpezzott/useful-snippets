#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Call Center Log Generator (partitioned by Year -> Quarter -> Month)
- One CSV per day.
- Minimal schema (default) or Wide schema (--wide).
- Output path: <outdir>/<year>/<year>-<quarter>/<year>-<quarter>-<month>/<date>.csv

Usage:
```bash
python generate_data.py --start 2025-08-01 --end 2025-08-07 --outdir ./data --wide
```

"""

import argparse
import csv
import os
import random
import uuid
import hashlib
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

# -----------------------------
# Utilities
# -----------------------------

def iso_ts(dt: datetime) -> str:
    """Return ISO 8601 string with timezone."""
    return dt.isoformat()

def make_hash(prefix: str, value: int, salt: str) -> str:
    """Deterministic anonymized hash for stable IDs (non-PII)."""
    h = hashlib.sha256()
    h.update(f"{prefix}:{value}:{salt}".encode("utf-8"))
    return h.hexdigest()

def random_duration_seconds() -> int:
    """Generate call duration (seconds) using log-normal-like distribution."""
    minutes = max(1, int(random.lognormvariate(mu=2.7, sigma=0.6)))  # median ~15 min
    return minutes * 60

def bounded_int(n: int) -> int:
    """Ensure non-negative integer."""
    return max(0, int(n))

# -----------------------------
# Partitioning
# -----------------------------

def partition_dir_for_day(day_local: datetime, out_dir: str) -> str:
    """
    Build hierarchical folder path: Year -> Quarter -> Quarter-Month.
    Example: <outdir>/2025/2025-Q3/2025-Q3-08
    """
    y = f"{day_local.year}"
    q = f"Q{((day_local.month - 1) // 3) + 1}"  # Q1=Jan–Mar, Q2=Apr–Jun, etc.
    qm = f"{y}-{q}-{day_local.month:02d}"
    return os.path.join(out_dir, y, f"{y}-{q}", qm)

# -----------------------------
# Row factories
# -----------------------------

def build_minimal_row(open_dt: datetime, duration_s: int, requester_id: int, salt: str):
    closed_dt = open_dt + timedelta(seconds=duration_s)
    return {
        "ticket_hash": uuid.uuid4().hex,
        "opened_at": iso_ts(open_dt),
        "requester_hash": make_hash("requester", requester_id, salt),
        "closed_at": iso_ts(closed_dt),
    }

def build_wide_fields(open_dt: datetime, duration_s: int, agent_id: int, salt: str):
    channels = ["phone", "email", "chat", "whatsapp", "portal"]
    queues = ["billing", "technical", "sales", "retention", "general"]
    priorities = ["low", "medium", "high", "urgent"]
    categories = ["incident", "request", "question", "complaint", "cancelation"]

    handle_time = max(30, int(duration_s * random.uniform(0.4, 0.9)))
    sla_target_sec = 30 * 60
    sla_breached = int(duration_s > sla_target_sec)
    reopen_count = 0 if random.random() < 0.9 else random.randint(1, 3)

    return {
        "channel": random.choice(channels),
        "queue": random.choice(queues),
        "agent_hash": make_hash("agent", agent_id, salt),
        "priority": random.choice(priorities),
        "category": random.choice(categories),
        "sla_breached": sla_breached,
        "reopen_count": reopen_count,
        "handle_time_sec": handle_time,
    }

# -----------------------------
# Generation core
# -----------------------------

def generate_day_csv(
    day: datetime,
    out_dir: str,
    tz: ZoneInfo,
    n_rows: int,
    sep: str,
    wide: bool,
    requester_pool: int,
    agent_pool: int,
    salt: str,
):
    """
    Generate one CSV for a given day (partitioned folder structure).
    """
    day_local = day.replace(hour=0, minute=0, second=0, microsecond=0, tzinfo=tz)
    next_day_local = day_local + timedelta(days=1)

    # Build partitioned folder path
    part_dir = partition_dir_for_day(day_local, out_dir)
    os.makedirs(part_dir, exist_ok=True)

    fname = f"{day_local.date()}.csv"
    fpath = os.path.join(part_dir, fname)

    # Header
    base_headers = ["ticket_hash", "opened_at", "requester_hash", "closed_at"]
    wide_headers = ["channel", "queue", "agent_hash", "priority", "category",
                    "sla_breached", "reopen_count", "handle_time_sec"]
    headers = base_headers + (wide_headers if wide else [])

    with open(fpath, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=headers, delimiter=sep)
        writer.writeheader()

        for _ in range(n_rows):
            span_seconds = int((next_day_local - day_local).total_seconds()) - 1
            open_offset = random.randint(0, span_seconds)
            opened_at = day_local + timedelta(seconds=open_offset)

            duration = random_duration_seconds()
            requester_id = random.randint(1, requester_pool)
            row = build_minimal_row(opened_at, duration, requester_id, salt)

            if wide:
                agent_id = random.randint(1, agent_pool)
                row.update(build_wide_fields(opened_at, duration, agent_id, salt))

            writer.writerow(row)

    return fpath

# -----------------------------
# Main
# -----------------------------

def main():
    parser = argparse.ArgumentParser(description="Generate per-day call center CSV logs.")
    parser.add_argument("--start", required=True, help="Start date (YYYY-MM-DD).")
    parser.add_argument("--end", required=True, help="End date inclusive (YYYY-MM-DD).")
    parser.add_argument("--outdir", default="./output_logs", help="Output directory.")
    parser.add_argument("--avg_per_day", type=int, default=50000, help="Average rows per day.")
    parser.add_argument("--std_per_day", type=int, default=10000, help="Std dev rows per day.")
    parser.add_argument("--tz", default="America/Sao_Paulo", help="IANA timezone name.")
    parser.add_argument("--sep", default=";", help="CSV delimiter.")
    parser.add_argument("--seed", type=int, default=42, help="Random seed.")
    parser.add_argument("--wide", action="store_true", help="Generate wide schema.")
    parser.add_argument("--requester_pool", type=int, default=200_000, help="Requester pool size.")
    parser.add_argument("--agent_pool", type=int, default=3_000, help="Agent pool size.")
    parser.add_argument("--salt", default="fluente-bi-salt", help="Salt for hashes.")
    args = parser.parse_args()

    random.seed(args.seed)

    start = datetime.strptime(args.start, "%Y-%m-%d").date()
    end = datetime.strptime(args.end, "%Y-%m-%d").date()
    if start > end:
        raise ValueError("Start date must be <= End date.")

    tz = ZoneInfo(args.tz)
    total_rows = 0
    cur = start
    while cur <= end:
        n_today = bounded_int(random.gauss(mu=args.avg_per_day, sigma=args.std_per_day))
        path = generate_day_csv(
            day=datetime(cur.year, cur.month, cur.day),
            out_dir=args.outdir,
            tz=tz,
            n_rows=n_today,
            sep=args.sep,
            wide=args.wide,
            requester_pool=args.requester_pool,
            agent_pool=args.agent_pool,
            salt=args.salt,
        )
        print(f"Wrote {n_today:,} rows -> {path}")
        total_rows += n_today
        cur += timedelta(days=1)

    print(f"Done. Total rows: {total_rows:,}")

if __name__ == "__main__":
    main()
