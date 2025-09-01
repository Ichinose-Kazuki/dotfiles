import os
import sys

import requests

image_info_response = requests.get("https://arc.msn.com/v4/api/selection?placement=88000821&fmt=json&locale=ja-JP&country=JP").json()
image_url = image_info_response["ad"]["landscapeImage"]["asset"]
image = requests.get(image_url).content

image_filepath = sys.argv[1]
os.makedirs(os.path.dirname(image_filepath), exist_ok=True)

try:
    with open(os.path.join(os.path.dirname(image_filepath), "log.txt"), "r") as f:
        old = f.readlines()
except FileNotFoundError:
    old = []
with open(os.path.join(os.path.dirname(image_filepath), "log.txt"), "w") as f:
    old.append(image_url + "\n")
    # three image urls at most
    f.writelines(old[1:4] if len(old) > 3 else old)

with open(image_filepath, "wb") as f:
    f.write(image)
