def get_order(key):
    # Return column indices sorted alphabetically by key characters
    return [i for _, i in sorted((ch, i) for i, ch in enumerate(key))]

def encrypt(plain, key):
    plain = plain.replace(' ', 'x')
    n = len(key)
    if len(plain) % n:
        plain += 'x' * (n - len(plain) % n)
    rows = [plain[i:i+n] for i in range(0, len(plain), n)]
    return "".join(row[c] for c in get_order(key) for row in rows)

def decrypt(cipher, key):
    n = len(key)
    r = len(cipher) // n
    segs = [cipher[i*r:(i+1)*r] for i in range(n)]
    cols = [''] * n
    for idx, seg in zip(get_order(key), segs):
        cols[idx] = seg
    plain = "".join(cols[c][row] for row in range(r) for c in range(n))
    return plain.replace('x', ' ').rstrip()

mode = input("Encrypt (e) or Decrypt (d): ").lower()
text = input("Enter text: ")
key = input("Enter key: ")

if mode == 'e':
    print("Encrypted:", encrypt(text, key))
else:
    print("Decrypted:", decrypt(text, key))
