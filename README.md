# eidon-pov-mirror

Tự tải kho video POV việc nhà **eidon-ai/egocentric-pov** (Hugging Face, CC-BY-4.0, 1.373 file · 1,55 TB) về Google Drive
`MMO-thu-vien/eidon-pov/` bằng GitHub Actions — stream thẳng HF → Drive, không qua máy nhà, không chạm ổ runner.

- `manifest.tsv` — danh sách file + cỡ (nguồn: `hf buckets list -R`, 22/09/2026).
- 8 shard song song, mỗi shard tối đa 85 GB/lần ⇒ ~680 GB/ngày, dưới trần 750 GB/ngày của Drive.
  Lịch 03:00 VN mỗi ngày; job `tally` tự tắt lịch khi đủ. Ước 3 ngày, ~700 phút Actions (gói Pro 3.000/tháng).
- Chạy lại an toàn: bỏ qua file đã có đúng cỡ; file lệch cỡ thì xoá và tải lại lần sau.
- Secret `RCLONE_CONF` = base64 của `~/.config/rclone/rclone.conf` (remote `gdrive`).

Theo dõi: `gh run watch` hoặc tab Actions. Tiến độ Drive: `rclone size gdrive:MMO-thu-vien/eidon-pov/`.

Ghi công khi dùng video: *Eidon Egocentric POV — Solidic Labs Inc (Eidon AI), CC BY 4.0.*
