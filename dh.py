from Crypto.Util.number import getPrime

p, g = getPrime(512), 2
a, b = int(input("Alice private (a): ")), int(input("Bob private (b): "))

A, B = pow(g, a, p), pow(g, b, p)
print("Alice Public (A):", A)
print("Bob Public (B)  :", B)
print("Shared Secret   :", pow(B, a, p) == pow(A, b, p), pow(B, a, p))
