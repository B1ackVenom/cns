import random
import string

# Create alphabet with both cases
alphabet = list(string.ascii_letters)  # a-z then A-Z
key = alphabet.copy()

# Shuffle to create cipher key
random.shuffle(key)

#print(f"Alphabet: {alphabet}")
#print(f"Key:      {key}\n")

# Encrypt
pt = input("Enter Plain Text: ")
ct = ""
for char in pt:
    if char in alphabet:
        pos = alphabet.index(char)      # Find position
        ct += key[pos]           # Replace with key character
    else:
        ct += char               # Keep spaces and punctuation

# Decrypt
dec = ""
for char in ct:
    if char in key:
        pos = key.index(char)            # Find position in key
        dec += alphabet[pos]        # Get character from alphabet
    else:
        dec += char                # Keep spaces and punctuation

print(f"Plain:     {pt}")
print(f"Cipher:    {ct}")
print(f"Decrypted: {dec}")

