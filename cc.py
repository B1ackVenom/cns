def encrypt(text):
    result = ""
    shift = 3

    for char in text:
        if char.isalpha():
            if char.isupper():
                result += chr((ord(char) - ord('A') + shift) % 26 + ord('A'))
            else:
                result += chr((ord(char) - ord('a') + shift) % 26 + ord('a'))
        else:
            result += char

    return result

def decrypt(text):
    result = ""
    shift = -3

    for char in text:
        if char.isalpha():
            if char.isupper():
                result += chr((ord(char) - ord('A') + shift) % 26 + ord('A'))
            else:
                result += chr((ord(char) - ord('a') + shift) % 26 + ord('a'))
        else:
            result += char

    return result

pt = input("Enter plain text: ")

encrypted = encrypt(pt)
print(f"Encrypted: {encrypted}")

decrypted = decrypt(encrypted)
print(f"Decrypted: {decrypted}")
