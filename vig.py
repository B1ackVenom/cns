def encrypt(text, key):
    key = key.upper()
    result = ""
    i = 0

    for ch in text:
        if ch.isalpha():
            shift = ord(key[i % len(key)]) - ord('A')

            if ch.isupper():
                base = ord('A')
            else:
                base = ord('a')

            result += chr((ord(ch) - base + shift) % 26 + base)
            i += 1
        else:
            result += ch

    return result


def decrypt(text, key):
    key = key.upper()
    result = ""
    i = 0

    for ch in text:
        if ch.isalpha():
            shift = ord(key[i % len(key)]) - ord('A')

            if ch.isupper():
                base = ord('A')
            else:
                base = ord('a')

            result += chr((ord(ch) - base - shift) % 26 + base)
            i += 1
        else:
            result += ch

    return result


plaintext = input("Enter plaintext: ")
key = input("Enter key: ")

encrypted = encrypt(plaintext, key)
decrypted = decrypt(encrypted, key)

print("Encrypted:", encrypted)
print("Decrypted:", decrypted)
