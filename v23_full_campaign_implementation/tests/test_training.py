from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from v23.domains import SymbolicDomain
from v23.training import TrainConfig, train_one_run


class TrainingSmokeTests(unittest.TestCase):
    def test_one_supervised_update_is_reproducible_and_writes_manifest(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary) / "run"
            config = TrainConfig(
                domain="symbolic",
                system="B13",
                size="small",
                regime="R_supervised",
                training_seed=0,
                output_directory=str(output),
                data_manifest="smoke-only",
                maximum_updates=1,
                batch_size=2,
                warmup_updates=1,
                checkpoint_interval=10,
                dropout_micros=0,
                device="cpu",
                run_kind="smoke",
            )
            report = train_one_run(config, SymbolicDomain())
            self.assertEqual(len(report["metrics"]), 1)
            self.assertEqual(report["forbidden_bypass_violations"], ())
            self.assertTrue((output / "checkpoint_final.pt").is_file())
            self.assertTrue((output / "run_manifest.json").is_file())

    def test_one_causal_update_samples_only_authorized_catalogs(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary) / "causal-run"
            config = TrainConfig(
                domain="symbolic",
                system="B13",
                size="small",
                regime="R_causal",
                training_seed=1,
                output_directory=str(output),
                data_manifest="smoke-only",
                maximum_updates=1,
                batch_size=2,
                warmup_updates=1,
                checkpoint_interval=10,
                dropout_micros=0,
                device="cpu",
                run_kind="smoke",
            )
            report = train_one_run(config, SymbolicDomain())
            self.assertEqual(report["metrics"][0]["batch"], 2)
            self.assertTrue((output / "checkpoint_final.pt").is_file())


if __name__ == "__main__":
    unittest.main()
