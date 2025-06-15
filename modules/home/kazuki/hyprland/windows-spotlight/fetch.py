import os
import requests
import sys

image_info_response = requests.get(
    "https://arc.msn.com/v4/api/selection?placement=88000821&fmt=json&locale=ja-JP&country=JP"
).json()
image_url = image_info_response["ad"]["landscapeImage"]["asset"]
image = requests.get(image_url).content

image_filepath = sys.argv[1]
os.makedirs(os.path.dirname(image_filepath), exist_ok=True)

with open(image_filepath, "wb") as f:
    f.write(image)
