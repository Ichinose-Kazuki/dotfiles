import secrets


def gen_loto6():
    trials = 0
    while True:
        trials += 1
        nums = sorted(secrets.SystemRandom().sample(range(1, 44), 6))
        diffs = [nums[i + 1] - nums[i] for i in range(5)]
        # Filter 1 & 2: 12以下は1個まで、32以上は2個以上
        if sum(1 for x in nums if x <= 12) >= 2:
            continue
        if sum(1 for x in nums if x >= 32) <= 1:
            continue
        # Filter 3: 均等分散の排除（最小間隔が4以上はNG）＆3連番以上の排除
        if min(diffs) >= 4:
            continue
        if any(diffs[i] == 1 and diffs[i + 1] == 1 for i in range(4)):
            continue
        # Filter 4 & 5: 規則性・マークシート縦列集中の排除
        if len(set(diffs)) <= 2:
            continue
        if max(sum(1 for x in nums if x % 5 == r) for r in range(5)) >= 4:
            continue
        if max(sum(1 for x in nums if x % 7 == r) for r in range(7)) >= 4:
            continue
        return nums, trials


def gen_loto7():
    trials = 0
    while True:
        trials += 1
        nums = sorted(secrets.SystemRandom().sample(range(1, 38), 7))
        diffs = [nums[i + 1] - nums[i] for i in range(6)]
        if sum(1 for x in nums if x <= 12) >= 2:
            continue
        if sum(1 for x in nums if x >= 32) <= 1:
            continue
        if min(diffs) >= 3:
            continue
        if any(
            diffs[i] == 1 and diffs[i + 1] == 1 and diffs[i + 2] == 1 for i in range(4)
        ):
            continue
        if len(set(diffs)) <= 2:
            continue
        if max(sum(1 for x in nums if x % 5 == r) for r in range(5)) >= 4:
            continue
        if max(sum(1 for x in nums if x % 7 == r) for r in range(7)) >= 4:
            continue
        return nums, trials


def gen_miniloto():
    trials = 0
    while True:
        trials += 1
        nums = sorted(secrets.SystemRandom().sample(range(1, 32), 5))
        diffs = [nums[i + 1] - nums[i] for i in range(4)]
        if sum(1 for x in nums if x <= 12) >= 2:
            continue
        if not any(x >= 29 for x in nums):
            continue
        if min(diffs) >= 4:
            continue
        if len(set(diffs)) == 1:
            continue
        if max(sum(1 for x in nums if x % 5 == r) for r in range(5)) >= 3:
            continue
        return nums, trials


def gen_bingo5():
    trials = 0
    while True:
        trials += 1
        offsets = [secrets.randbelow(5) + 1 for _ in range(8)]
        nums = [5 * i + offsets[i] for i in range(8)]
        # Filter 1 & 2: 同じ位置4個以上NG、対称配置NG
        if max(offsets.count(o) for o in range(1, 6)) >= 4:
            continue
        if sum(1 for i in range(4) if offsets[i] == offsets[7 - i]) >= 3:
            continue
        if sum(1 for i in range(4) if offsets[i] + offsets[7 - i] == 6) >= 3:
            continue
        # Filter 3: 第2枠が7,8かつ中央過多を排除
        if nums[1] in (7, 8) and offsets.count(3) >= 3:
            continue
        # Filter 4: 枠またぎ連番が最低1つ必要
        if not any(nums[i + 1] - nums[i] == 1 for i in range(7)):
            continue
        return nums, trials


def gen_numbers4():
    trials = 0
    while True:
        trials += 1
        n = secrets.randbelow(10000)
        s = f"{n:04d}"
        d = [int(c) for c in s]
        u, l = n // 100, n % 100
        if 1900 <= n <= 2035:
            continue
        if (1 <= u <= 12 and 1 <= l <= 31) or (u == 0 and 1 <= l <= 31):
            continue
        if len(set(d)) <= 2:
            continue
        if len({d[i + 1] - d[i] for i in range(3)}) == 1:
            continue
        if s == s[::-1] or l == 0:
            continue
        if set(d).issubset({3, 5, 8}) or sum(1 for x in d if x in {7, 8}) >= 3:
            continue
        return s, trials


def gen_numbers3():
    trials = 0
    while True:
        trials += 1
        n = secrets.randbelow(1000)
        s = f"{n:03d}"
        d = [int(c) for c in s]
        u, l = n // 100, n % 100
        if (1 <= u <= 9 and 1 <= l <= 31) or (u == 0 and 1 <= l <= 12):
            continue
        if len(set(d)) == 1 or d[0] == d[2]:
            continue
        if d[1] - d[0] == d[2] - d[1]:
            continue
        if d[2] == 0:
            continue
        if sum(1 for x in d if x in {3, 5, 8}) >= 2 or set(d) == {1, 6, 8}:
            continue
        return s, trials


if __name__ == "__main__":
    for name, fn in [
        ("ロト6", gen_loto6),
        ("ロト7", gen_loto7),
        ("ミニロト", gen_miniloto),
        ("ビンゴ5", gen_bingo5),
        ("ナンバーズ4", gen_numbers4),
        ("ナンバーズ3", gen_numbers3),
    ]:
        res, t = fn()
        print(f"{name:8s}: {res} (試行回数: {t}回目に通過)")
