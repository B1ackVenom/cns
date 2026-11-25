from Crypto.Cipher import DES
from Crypto.Util.Padding import pad, unpad

key = input("Key (8 chars): ").encode().ljust(8, b'\x00')[:8]
msg = input("Message: ").encode()

ct = DES.new(key, DES.MODE_ECB).encrypt(pad(msg, 8))
pt = unpad(DES.new(key, DES.MODE_ECB).decrypt(ct), 8)

print("Encrypted:", ct.hex())
print("Decrypted:", pt.decode())
