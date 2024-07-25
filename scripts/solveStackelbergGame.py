import sys
from math import sqrt

def evaluation(B, C, w, varrho, eta):
    C_set = list(range(C))
    p_c = [0] * C
    B_c = [0] * C

    Solved = False

    while Solved == False:
        alpha = sum(sqrt(w[c] * varrho[c] / eta[c]) for c in C_set) \
                / (B + sum(varrho[c] / eta[c] for c in C_set))

        for c in C_set:
            p_c[c] = alpha * sqrt(eta[c] * w[c] / varrho[c])
            B_c[c] = w[c] / p_c[c] - varrho[c] / eta[c]

        Solved = True
        for b_c in B_c:
            if b_c < 0:
                Solved = False
                break

        if not Solved:
            cp = B_c.index(min([B_c[i] for i in C_set]))
            C_set.remove(cp)

            B_c[cp] = 0
            p_c[cp] = 0
    
    print(p_c)
    print(B_c)


if sys.argv[1] == "evaluation":
    B = int(sys.argv[2])
    C = int(sys.argv[3])
    w = list(map(float, sys.argv[4].strip('[]').split(',')))
    varrho = list(map(float, sys.argv[5].strip('[]').split(',')))
    eta = list(map(float, sys.argv[6].strip('[]').split(',')))
    evaluation(B, C, w, varrho, eta)

sys.stdout.flush()