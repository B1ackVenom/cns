from Crypto.Util.number import getPrime

p, q = getPrime(512), getPrime(512)
n, phi = p * q, (p - 1) * (q - 1)
e = 65537
d = pow(e, -1, phi)

msg = input("Message: ")
ct = [pow(ord(c), e, n) for c in msg]
pt = "".join(chr(pow(c, d, n)) for c in ct)

print("Encrypted:", ct)
print("Decrypted:", pt)
