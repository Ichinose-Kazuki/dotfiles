{ pkgs, ... }:
{
  # GoPro のファイル転送は gvfs の MTP サポート（`gio mount mtp://...`）を使う。
  environment.systemPackages = with pkgs; [
    libmtp
    # MP4 動画の圧縮
    ffmpeg
  ];
}
