from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad

key = input("Key (16 chars): ").encode().ljust(16, b'\x00')[:16]
msg = input("Message: ").encode()

ct = AES.new(key, AES.MODE_ECB).encrypt(pad(msg, 16))
pt = unpad(AES.new(key, AES.MODE_ECB).decrypt(ct), 16)

print("Encrypted:", ct.hex())
print("Decrypted:", pt.decode())
