def build_grid(key):
    return "".join(dict.fromkeys(key.upper().replace("J","I") + "ABCDEFGHIKLMNOPQRSTUVWXYZ"))

def encrypt(plaintext, key):
    grid = build_grid(key)

    pt = "".join(c for c in plaintext.upper().replace("J","I") if c.isalpha())

    # Split into digraphs, inserting 'X'
    pairs, i = [], 0
    while i < len(pt):
        if i == len(pt)-1 or pt[i] == pt[i+1]:
            pairs.append(pt[i] + "X"); i += 1
        else:
            pairs.append(pt[i] + pt[i+1]); i += 2

    # Encrypt each pair using the three rules
    cipher = ""
    for a, b in pairs:
        r1, c1 = divmod(grid.index(a), 5)
        r2, c2 = divmod(grid.index(b), 5)

        # Use Formula (I = R * 5 + C)
        if r1 == r2:              # same row -> shift right
            cipher += grid[r1*5+(c1+1)%5] + grid[r2*5+(c2+1)%5]
        elif c1 == c2:            # same column -> shift down
            cipher += grid[((r1+1)%5)*5+c1] + grid[((r2+1)%5)*5+c2]
        else:                     # rectangle -> swap columns
            cipher += grid[r1*5+c2] + grid[r2*5+c1]
    return cipher

def decrypt(ciphertext, key):
    grid = build_grid(key)

    ct = "".join(c for c in ciphertext.upper().replace("J","I") if c.isalpha())

    # Decrypt each pair using the three rules
    plain = ""
    for i in range(0, len(ct), 2):
        a, b = ct[i], ct[i+1]
        r1, c1 = divmod(grid.index(a), 5)
        r2, c2 = divmod(grid.index(b), 5)

        # Use Formula (I = R * 5 + C)
        if r1 == r2:              # same row -> shift LEFT (reverse)
            plain += grid[r1*5+(c1-1)%5] + grid[r2*5+(c2-1)%5]
        elif c1 == c2:            # same column -> shift UP (reverse)
            plain += grid[((r1-1)%5)*5+c1] + grid[((r2-1)%5)*5+c2]
        else:                     # rectangle -> swap columns (same)
            plain += grid[r1*5+c2] + grid[r2*5+c1]
    return plain

text = input("Enter text: ")
key = input("Enter key: ")

cipher = encrypt(text, key)
plain = decrypt(cipher, key)

print("Original: ", text.upper())
print("Encrypted:", cipher)
print("Decrypted:", plain)
