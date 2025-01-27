{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # GoPro からのファイル転送 (Media Transfer Protocol)
    simple-mtpfs
    libmtp
    # MP4 動画の圧縮
    ffmpeg
  ];
}
