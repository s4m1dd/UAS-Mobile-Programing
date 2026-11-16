"""Run with python3 -I test/transaction_statistics_sql_test.py.

Exercises the application's actual SQLite queries with a fixed UTC clock.
No Flutter SDK or phone data is needed.
"""
import os
from pathlib import Path
import re
import sqlite3
import time
import unittest


class TransactionStatisticsTest(unittest.TestCase):
    def setUp(self):
        self.previous_tz = os.environ.get('TZ')
        os.environ['TZ'] = 'Asia/Jakarta'
        time.tzset()
        self.db = sqlite3.connect(':memory:')
        self.db.execute('CREATE TABLE transactions (transactionDate TEXT, totalAmount REAL)')
        source = (Path(__file__).resolve().parents[1] / 'lib/database/database_helper.dart').read_text()
        self.queries = dict(re.findall(
            r"final (todayRevenue|monthlyRevenue) = \(await db\.rawQuery\('''(.*?)'''\)",
            source, re.S,
        ))

    def tearDown(self):
        self.db.close()
        if self.previous_tz is None:
            os.environ.pop('TZ', None)
        else:
            os.environ['TZ'] = self.previous_tz
        time.tzset()

    def revenue(self, metric, utc_now, rows):
        self.db.executemany('INSERT INTO transactions VALUES (?, ?)', rows)
        # Replace only SQLite's clock input; execute the production filter unchanged.
        query = self.queries[metric].replace("'now'", ':utc_now')
        return self.db.execute(query, {'utc_now': utc_now}).fetchone()[0] or 0.0

    def test_today_after_local_midnight(self):
        self.assertEqual(self.revenue('todayRevenue', '2026-11-16 18:30:00', [
            ('2026-11-16T23:59:59.000', 5000),
            ('2026-11-17T01:05:59.000', 19000),
            ('2026-11-18T00:00:00.000', 9000),
        ]), 19000)

    def test_month_after_local_month_boundary(self):
        self.assertEqual(self.revenue('monthlyRevenue', '2026-11-30 18:30:00', [
            ('2026-11-30T23:59:59.000', 5000),
            ('2026-12-01T01:05:59.000', 19000),
            ('2027-01-01T00:00:00.000', 9000),
        ]), 19000)

    def test_month_after_local_year_boundary(self):
        self.assertEqual(self.revenue('monthlyRevenue', '2026-12-31 18:30:00', [
            ('2026-12-31T23:59:59.000', 5000),
            ('2027-01-01T01:05:59.000', 19000),
        ]), 19000)

    def test_daytime_total(self):
        self.assertEqual(self.revenue('todayRevenue', '2026-11-17 05:00:00', [
            ('2026-11-17T01:05:59.000', 19000),
            ('2026-11-17T11:00:00.000', 8000),
        ]), 27000)

    def test_empty_period(self):
        self.assertEqual(self.revenue('todayRevenue', '2026-11-16 18:30:00', []), 0)


if __name__ == '__main__':
    unittest.main()
