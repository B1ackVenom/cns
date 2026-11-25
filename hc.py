import math
import numpy as np

# Input 2x2 key matrix (4 space-separated numbers, e.g., 3 3 2 5)
vals = [int(x) for x in input("Enter 4 key matrix numbers (row-wise): ").split()]
assert len(vals) == 4, "Enter exactly 4 integers for a 2x2 matrix"
K = np.array(vals).reshape(2, 2)

# Check invertibility modulo 26
det = int(round(np.linalg.det(K))) % 26
assert math.gcd(det, 26) == 1, "Key matrix is not invertible mod 26"

# Compute modular inverse matrix K_inv = det^-1 * adj(K) mod 26
adj = np.array([[K[1, 1], -K[0, 1]],
                [-K[1, 0], K[0, 0]]])
K_inv = (pow(det, -1, 26) * adj) % 26

def hill(text, mat):
    pt = "".join(c for c in text.upper() if c.isalpha())
    if len(pt) % 2:
        pt += "X"
    nums = [ord(c) - 65 for c in pt]
    res = ""
    for i in range(0, len(nums), 2):
        pair = np.dot(mat, nums[i:i+2]) % 26
        res += "".join(chr(int(x) + 65) for x in pair)
    return res

mode = input("Encrypt (e) or Decrypt (d): ").lower()
text = input("Enter text: ")

if mode == 'e':
    print("Encrypted:", hill(text, K))
else:
    print("Decrypted:", hill(text, K_inv))
