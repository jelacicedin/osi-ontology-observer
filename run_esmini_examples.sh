#!/usr/bin/env bash


# ------------------------------------------
# Resolve project root relative to this file
# ------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR" && pwd)"

# Correct demo structure inside your repo
DEMO_DIR="$ROOT_DIR/vendor/esmini/esmini-demo"
ESMINI_BIN="$DEMO_DIR/bin/esmini"
XOSC_DIR="$DEMO_DIR/resources/xosc"
OUT_BASE="$ROOT_DIR/examples"

echo "ROOT_DIR=$ROOT_DIR"
echo "DEMO_DIR=$DEMO_DIR"
echo "ESMINI_BIN=$ESMINI_BIN"
echo "XOSC_DIR=$XOSC_DIR"
echo "OUT_BASE=$OUT_BASE"

# Simulation settings
STEP="${STEP:-0.05}"      # integration step (s)
ABORT_T="${ABORT_T:-30}"  # max sim time (s)
HEADLESS="${HEADLESS:-1}" # 1 = run headless

# Sanity checks
if [[ ! -x "$ESMINI_BIN" ]]; then
    echo "❌ Can't find esmini binary at: $ESMINI_BIN"
    echo "Run fetch_esmini.sh first or adjust paths."
    exit 1
fi
if [[ ! -d "$XOSC_DIR" ]]; then
    echo "❌ Can't find XOSC directory at: $XOSC_DIR"
    exit 1
fi

mkdir -p "$OUT_BASE"

# ------------------------------------------
# Function to run one scenario
# ------------------------------------------
run_one() {
    local xosc="$1"
    local base="$(basename "$xosc" .xosc)"
    local out_dir="$OUT_BASE/$base"
    
    mkdir -p "$out_dir"
    cp -f "$xosc" "$out_dir/$base.xosc"
    
    echo "▶️  Running $base (max ${ABORT_T}s)..."
    
    local args=()
    [[ "$HEADLESS" == "1" ]] && args+=(--headless)
    args+=(--fixed_timestep "$STEP" --osc "$xosc")
    args+=(--record "$out_dir/data.sim" --osi_file "$out_dir/ground_truth.osi")
    
    # Run in background and record PID
    "$ESMINI_BIN" "${args[@]}" >"$out_dir/run.log" 2>&1 &
    local pid=$!
    
    # Wait up to ABORT_T seconds
    local elapsed=0
    while kill -0 "$pid" 2>/dev/null; do
        sleep 1
        ((elapsed++))
        if (( elapsed >= ABORT_T )); then
            echo "⏰ Timeout reached (${ABORT_T}s). Sending Ctrl+C (SIGINT) to $pid."
            kill -INT "$pid" 2>/dev/null || true
            sleep 2
            if kill -0 "$pid" 2>/dev/null; then
                echo "⚠️  Process still alive, forcing termination."
                kill -TERM "$pid" 2>/dev/null || true
            fi
            break
        fi
    done
    
    wait "$pid" 2>/dev/null || true
    
    if [[ -s "$out_dir/data.sim" ]] || [[ -s "$out_dir/ground_truth.osi" ]]; then
        echo "✅ Outputs saved in $out_dir"
    else
        echo "⚠️  No outputs for $base (check run.log)"
    fi
}

# ------------------------------------------
# Loop through all .xosc files
# ------------------------------------------
mapfile -t XOSCS < <(find "$XOSC_DIR" -type f -name "*.xosc" | sort)
if [[ ${#XOSCS[@]} -eq 0 ]]; then
    echo "No .xosc files found under $XOSC_DIR"
    exit 0
fi

for xosc in "${XOSCS[@]}"; do
    run_one "$xosc"
done

echo "🎉  Done! All results are in $OUT_BASE/"
