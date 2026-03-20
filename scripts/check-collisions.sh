#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

scad_file="$repo_root/case/collision_check.scad"

if [[ ! -f "$scad_file" ]]; then
    echo "Missing collision check file: $scad_file" >&2
    exit 1
fi

if ! command -v openscad >/dev/null 2>&1; then
    echo "openscad not found in PATH" >&2
    exit 1
fi

openscad_cmd=(openscad)
if [[ -z "${DISPLAY:-}" ]] && command -v xvfb-run >/dev/null 2>&1; then
    openscad_cmd=(xvfb-run -a openscad)
fi

cpu_count() {
    if command -v nproc >/dev/null 2>&1; then
        nproc
    elif command -v getconf >/dev/null 2>&1; then
        getconf _NPROCESSORS_ONLN
    else
        echo 1
    fi
}

default_jobs="$(cpu_count)"
if [[ ! "$default_jobs" =~ ^[0-9]+$ ]] || (( default_jobs < 1 )); then
    default_jobs=1
fi
if (( default_jobs > 4 )); then
    default_jobs=4
fi

render_fn="${OPENSCAD_RENDER_FN:-24}"
check_jobs="${CHECK_JOBS:-$default_jobs}"
if [[ ! "$render_fn" =~ ^[0-9]+$ ]] || (( render_fn < 3 )); then
    echo "OPENSCAD_RENDER_FN must be an integer >= 3 (got: $render_fn)" >&2
    exit 1
fi

if [[ ! "$check_jobs" =~ ^[0-9]+$ ]] || (( check_jobs < 1 )); then
    echo "CHECK_JOBS must be an integer >= 1 (got: $check_jobs)" >&2
    exit 1
fi

openscad_defs=(
    -D "render_fn=${render_fn}"
)

checks=(
    "main_lid nonempty"
    "main_loadcell nonempty"
    "main_battery empty"
    "main_pcb nonempty"
    "main_switch empty"
    "main_usb_cable empty"
    "lid_loadcell empty"
    "lid_battery empty"
    "lid_pcb empty"
    "lid_switch empty"
    "loadcell_battery empty"
    "loadcell_pcb empty"
    "loadcell_switch empty"
    "battery_pcb empty"
    "battery_switch empty"
    "pcb_switch empty"
    "main_lid_eps_up empty"
    "main_loadcell_eps_z_plus empty"
    "main_pcb_eps_y_plus nonempty"
    "main_pcb_eps_yz_plus empty"
    "battery_pcb_eps_z_plus empty"
)

current_job_count() {
    jobs -pr | wc -l | tr -d ' '
}

check_mode() {
    local mode="$1"
    local expected="$2"
    local log_file="$tmp_dir/${mode}.log"
    local out_file="$tmp_dir/${mode}.stl"
    local status_file="$tmp_dir/${mode}.status"
    local error_file="$tmp_dir/${mode}.error"
    local result

    if "${openscad_cmd[@]}" "${openscad_defs[@]}" -D "mode=\"${mode}\"" -o "$out_file" "$scad_file" >"$log_file" 2>&1; then
        result="nonempty"
    else
        if grep -q "Current top level object is empty" "$log_file"; then
            result="empty"
        else
            printf '%-28s %s\n' "$mode" "openscad-error" >"$status_file"
            {
                echo "openscad error for mode=$mode"
                tail -n 50 "$log_file" || true
            } >"$error_file"
            return 1
        fi
    fi

    printf '%-28s %s (expected %s)\n' "$mode" "$result" "$expected" >"$status_file"
    if [[ "$result" != "$expected" ]]; then
        {
            echo "Collision check failed for mode=$mode"
            tail -n 50 "$log_file" || true
        } >"$error_file"
        return 1
    fi
}

echo "Running collision matrix with: ${openscad_cmd[*]} ${openscad_defs[*]}"
echo "Running ${#checks[@]} checks with CHECK_JOBS=$check_jobs"

pids=()
for check in "${checks[@]}"; do
    IFS=' ' read -r mode expected <<< "$check"
    check_mode "$mode" "$expected" &
    pids+=("$!")

    while (( $(current_job_count) >= check_jobs )); do
        if ! wait -n; then
            :
        fi
    done
done

failed=0
for pid in "${pids[@]}"; do
    if ! wait "$pid"; then
        failed=1
    fi
done

for check in "${checks[@]}"; do
    IFS=' ' read -r mode _ <<< "$check"
    if [[ -f "$tmp_dir/${mode}.status" ]]; then
        IFS= read -r status_line < "$tmp_dir/${mode}.status"
        printf '%s\n' "$status_line"
    else
        printf '%-28s %s\n' "$mode" "missing-status"
        failed=1
    fi
done

if (( failed )); then
    for check in "${checks[@]}"; do
        IFS=' ' read -r mode _ <<< "$check"
        if [[ -f "$tmp_dir/${mode}.error" ]]; then
            printf '\n--- %s ---\n' "$mode" >&2
            while IFS= read -r line; do
                printf '%s\n' "$line" >&2
            done < "$tmp_dir/${mode}.error"
        fi
    done
    exit 1
fi

echo "Collision checks passed."
