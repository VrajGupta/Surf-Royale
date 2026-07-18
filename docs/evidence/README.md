# Integrated Slice Evidence

## M4 MacBook Air

- Benchmark: [`m4-2026-07-18-benchmark.json`](m4-2026-07-18-benchmark.json)
- Render capture: [`m4-2026-07-18-tutorial-cove.png`](m4-2026-07-18-tutorial-cove.png)
- Workload: rendered Godot 4.7.1 compatibility renderer, 1600×900 internal resolution, 300 seconds
- Result: 17,876 measured frames, 16.667 ms p95, 2,043,306 bytes memory growth, passed

## macOS artifact

`./scripts/verify.sh all` produced the unsigned local-review artifact at:

```text
build/macos/SurfRoyale.zip
```

Evidence from the final T006 gate:

```text
size:   59,622,880 bytes
sha256: d5eeaefb6349e64f7d46cce3ce42e647fef35ca44c83f014df68c6cba7dea68e
```

The artifact is generated under the ignored `build/` directory and is not committed. Recreate it with the pinned templates through the global verification command or the export command in `docs/runbooks/godot-setup.md`.

## Windows reference run

The x86_64 export preset and cross-export instructions are checked in. The 1920×1080 at 60 FPS RTX 3070 Mobile evidence remains machine-dependent and must be recorded when the Alienware m15 R6 is available; no Windows performance result is claimed from the M4 run.
