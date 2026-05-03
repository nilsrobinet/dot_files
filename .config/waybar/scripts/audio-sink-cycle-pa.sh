#!/usr/bin/env bash
set -euo pipefail

CMD="${1:-print}"

get_default() { pactl get-default-sink; }

sink_desc() {
  local sink="$1"
  pactl list sinks | awk -v s="$sink" '
    $0 == "Name: " s {found=1; next}
    found && $0 ~ /^[[:space:]]*Description: / {
      sub(/^[[:space:]]*Description: /,"")
      print
      exit
    }
    found && $0 ~ /^Name: / {found=0}
  '
}

pretty_from_name() {
  local raw="$1"
  local s="$raw"

  s="${s#alsa_output.}"
  s="${s#bluez_output.}"

  # Special-case common PA HDMI naming to get a clean "HDMI N"
  if [[ "$s" =~ hdmi-stereo-extra([0-9]+) ]]; then
    local n="${BASH_REMATCH[1]}"
    printf 'HDMI %d\n' "$((n + 1))"
    return 0
  fi

  # separators -> spaces (do this early)
  s="$(printf '%s' "$s" | tr '._-' ' ')"

  # Remove "pci <domain> <bus> <slot> <func>" when present after tokenization
  # Example: "pci 0000 08 00 4" (domain bus slot func)
  s="$(printf '%s\n' "$s" | sed -E '
    s/\bpci[[:space:]]+[0-9A-Fa-f]{4}[[:space:]]+[0-9A-Fa-f]{2}[[:space:]]+[0-9A-Fa-f]{2}[[:space:]]+[0-9]\b//gI;
    s/\bpci\b//gI;

    s/\b(stereo|mono)\b//gI;
    s/\bextra[0-9]+\b//gI;

    s/[[:space:]]+/ /g;
    s/^[[:space:]]+|[[:space:]]+$//g;
  ')"

  # Uppercase some common transport tokens
  s="$(printf '%s\n' "$s" | awk '{
    for (i=1;i<=NF;i++) {
      lw=tolower($i)
      if (lw=="hdmi") $i="HDMI"
      else if (lw=="iec958") $i="IEC958"
      else if (lw=="spdif") $i="SPDIF"
    }
    $1=$1
    print
  }')"

  [[ -n "$s" ]] || s="$raw"
  printf '%s\n' "$s"
}

print_current() {
  local def desc label
  def="$(get_default)"
  desc="$(sink_desc "$def" || true)"

  if [[ -n "${desc:-}" ]]; then
    label="$desc"
  else
    label="$(pretty_from_name "$def")"
  fi

  echo "  $label"
}

cycle() {
  local def next
  def="$(get_default)"
  mapfile -t sinks < <(pactl list short sinks | awk '{print $2}')
  ((${#sinks[@]} > 0)) || exit 0

  next="${sinks[0]}"
  for i in "${!sinks[@]}"; do
    if [[ "${sinks[$i]}" == "$def" ]]; then
      next="${sinks[$(( (i+1) % ${#sinks[@]} ))]}"
      break
    fi
  done

  pactl set-default-sink "$next" >/dev/null
}

case "$CMD" in
  print) print_current ;;
  cycle) cycle; print_current ;;
  *) echo "usage: $0 [print|cycle]" >&2; exit 2 ;;
esac
