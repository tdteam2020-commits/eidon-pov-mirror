#!/usr/bin/env bash
# mirror.sh <shard> <n_shards> <max_gb> — stream Hugging Face bucket eidon-ai/egocentric-pov → Google Drive, không chạm ổ runner.
# Bỏ qua file đã có đúng cỡ trên Drive ⇒ chạy lại bao nhiêu lần cũng được; dừng sau max_gb để né trần 750 GB/ngày của Drive.
set -u
SHARD=$1; N=$2; MAX_GB=$3
DEST="gdrive:MMO-thu-vien/eidon-pov"
BASE="https://huggingface.co/buckets/eidon-ai/egocentric-pov/resolve"
rclone lsf --recursive --files-only --format "ps" "$DEST/" > have.txt 2>/dev/null || true
declare -A HAVE; while IFS=';' read -r p s; do HAVE["$p"]=$s; done < have.txt
max=$((MAX_GB*1000000000)); moved=0; i=0; skip=0; ok=0; fail=0; left=0; t_start=$(date +%s)
while IFS=$'\t' read -r path size; do
  i=$((i+1)); [ $(( (i-1) % N )) -eq "$SHARD" ] || continue
  if [ "${HAVE[$path]:-}" = "$size" ]; then skip=$((skip+1)); continue; fi
  if [ "$moved" -ge "$max" ]; then left=$((left+1)); continue; fi
  t0=$(date +%s)
  rclone copyurl --no-clobber --retries 3 "$BASE/$path" "$DEST/$path" >> err.log 2>&1
  got=$(rclone lsf --files-only --format "s" "$DEST/$path" 2>/dev/null | head -1)
  if [ "$got" = "$size" ]; then
    ok=$((ok+1)); moved=$((moved+size)); echo "✓ $path $((size/1000000)) MB $(( $(date +%s)-t0 )) s"
  else
    fail=$((fail+1)); echo "✗ $path (có $got, cần $size)"; [ -n "$got" ] && rclone deletefile "$DEST/$path" 2>/dev/null
  fi
done < manifest.tsv
echo "── shard $SHARD/$N: ok $ok · bỏ qua (đã có) $skip · lỗi $fail · còn lại chưa tới lượt $left · $((moved/1000000000)) GB trong $(( ($(date +%s)-t_start)/60 )) phút"
[ "$fail" -gt 0 ] && { echo "── lỗi cuối:"; tail -20 err.log; exit 1; }
exit 0
