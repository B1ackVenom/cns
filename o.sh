#!/usr/bin/env bash
set -u
set -o pipefail

# Force UTF-8 encoding to fix the garbled Kali prompt characters
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

WORK="$HOME/cns_lab"
mkdir -p "$WORK" 2>/dev/null || true
cd "$WORK"

command -v openssl >/dev/null || { echo "openssl not found — install with: sudo apt install openssl"; exit 1; }

# Exact Kali ZSH prompt
if [ -t 1 ]; then
  C_RESET=$'\033[0m'
  U="$(whoami)"; H="$(hostname)"
  C_PROMPT=$'\033[0m┌──(\033[1;32m'"$U"$'\033[0m㉿\033[1;34m'"$H"$'\033[0m)-[\033[1;34m~/cns_lab\033[0m]\n└─$ \033[0m'
else
  U="$(whoami)"; H="$(hostname)"
  C_PROMPT="┌──(${U}㉿${H})-[~/cns_lab]\n└─$ "
fi

run() {
  local cmd="$*"
  printf '%s%s\n' "$C_PROMPT" "$cmd"
  bash -c "$cmd" 2>&1
}

# Create the dummy plain text file silently before clearing
printf 'This is a secret message for CNS lab.\nLine 2: applied cybersecurity fundamentals.\n' > plain.txt
clear

# --- AES ---
run "cat plain.txt"
run "openssl enc -aes-256-cbc -salt -pbkdf2 -a -in plain.txt -out plain.aes.enc -pass pass:secret123"
run "ls -l plain.txt plain.aes.enc"
run "file plain.aes.enc"
run "cat plain.aes.enc"
run "openssl enc -d -aes-256-cbc -pbkdf2 -a -in plain.aes.enc -out plain.aes.dec -pass pass:secret123"
run "cat plain.aes.dec"
run "diff plain.txt plain.aes.dec && echo 'AES round-trip OK'"
sleep 1

# --- DES ---
cipher="des-cbc"; opts="-provider default -provider legacy"
if ! printf x | openssl enc -des-cbc -provider default -provider legacy -pass pass:x >/dev/null 2>&1; then
  cipher="des-ede3-cbc"; opts=""
  if ! printf x | openssl enc -des-ede3-cbc -pass pass:x >/dev/null 2>&1; then
    cipher="des"; opts=""
  fi
fi
run "cat plain.txt"
run "openssl enc -$cipher $opts -salt -pbkdf2 -a -in plain.txt -out plain.des.enc -pass pass:secret123"
run "ls -l plain.txt plain.des.enc"
run "file plain.des.enc"
run "cat plain.des.enc"
run "openssl enc -d -$cipher $opts -pbkdf2 -a -in plain.des.enc -out plain.des.dec -pass pass:secret123"
run "cat plain.des.dec"
run "diff plain.txt plain.des.dec && echo 'DES round-trip OK'"
sleep 1

# --- RSA ---
echo "hello rsa" > rsa_plain.txt
run "cat rsa_plain.txt"
run "openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out private.pem"
run "openssl rsa -in private.pem -pubout -out public.pem"
run "ls -l private.pem public.pem"
run "head -2 private.pem"
run "head -2 public.pem"
run "openssl pkeyutl -encrypt -pubin -inkey public.pem -in rsa_plain.txt -out rsa_plain.enc"
run "ls -l rsa_plain.enc"
run "file rsa_plain.enc"
run "head -c 64 rsa_plain.enc | xxd"
run "openssl pkeyutl -decrypt -inkey private.pem -in rsa_plain.enc -out rsa_plain.dec"
run "cat rsa_plain.dec"
run "diff rsa_plain.txt rsa_plain.dec && echo 'RSA round-trip OK'"
sleep 1

# --- Self-Signed Cert ---
run "openssl req -x509 -newkey rsa:2048 -keyout cert_key.pem -out cert.pem -days 365 -nodes -subj '/C=IN/ST=Maharashtra/L=Pune/O=DYPU/OU=CSE/CN=www.example.local'"
run "ls -l cert.pem cert_key.pem"
run "openssl x509 -in cert.pem -noout -subject"
run "openssl x509 -in cert.pem -noout -issuer"
run "openssl x509 -in cert.pem -noout -dates"
run "openssl x509 -in cert.pem -noout -fingerprint -sha256"
run "openssl x509 -in cert.pem -text -noout | head -25"
sleep 1

# --- MD5 ---
run "cat plain.txt"
run "openssl dgst -md5 plain.txt"
run "md5sum plain.txt"
run "echo -n 'hello' | openssl dgst -md5"
run "echo -n 'hellp' | openssl dgst -md5"
sleep 1

# --- SHA ---
run "openssl dgst -sha256 plain.txt"
run "sha256sum plain.txt"
run "openssl dgst -sha512 plain.txt"
run "sha512sum plain.txt"
run "echo -n 'hello' | openssl dgst -sha256"
run "echo -n 'hellp' | openssl dgst -sha256"
