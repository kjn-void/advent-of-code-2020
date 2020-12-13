f = open('input.txt', 'r')
start = int(f.readline())
line = f.readline()
times = list(map(lambda x: (int(x[1]), x[0]),
                 filter(lambda x: x[1] != 'x',
                        enumerate(line.split(',')))))

m = min([(((start + t - 1) // t) * t, t) for t,_ in times])

def task2(t, l, step):
    if not l:
        return t
    factor, offset = l[0]
    while True:
        t += step
        if (t + offset) % factor == 0:
            return task2(t, l[1:], step * factor)

print((m[0] - start) * m[1], task2(0, times, 1))
