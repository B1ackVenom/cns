import hashlib

msg = input("Message: ").encode()
print("MD5    :", hashlib.md5(msg).hexdigest())
print("SHA-256:", hashlib.sha256(msg).hexdigest())
