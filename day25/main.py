keys = (17115212, 3667832)

def loop(subject, times, key = -1):
    count, value = 0, 1
    while True:
        count, value = count + 1, value * subject % 20201227
        if value == key: return count
        if count == times: return value
        
loops = [loop(7, 0, k) for k in keys]
print(loop(loop(7, loops[1]), loops[0]))
