const crypto = require("crypto");

const ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
const ALPHABET_MAP = {};

for (let i = 0; i < ALPHABET.length; i++) {
  ALPHABET_MAP[ALPHABET.charAt(i)] = i;
}

const BASE = 58;

const BITS_PER_DIGIT = Math.log(BASE) / Math.log(2);

function maxEncodedLen(n) {
  return Math.ceil(n / BITS_PER_DIGIT);
}

function sha256(string) {
  return crypto
    .createHash("sha256")
    .update(string)
    .digest("hex");
}

function ethToVlx(address_string) {
  const clean_address = address_string.replace(/^0x/i, "").toLowerCase();

  if (clean_address.length !== 40) {
    throw new Error("Invalid address length");
  }

  const checksum = sha256(sha256(clean_address)).substring(0, 8);

  const long_address = clean_address + checksum;
  buffer = Buffer.from(long_address, "hex");

  if (buffer.length === 0) {
    throw new Error("Invalid address");
  }

  let digits = [0];
  for (let i = 0; i < buffer.length; i++) {
    for (let j = 0; j < digits.length; j++) digits[j] <<= 8;

    digits[0] += buffer[i];

    let carry = 0;
    for (let j = 0; j < digits.length; ++j) {
      digits[j] += carry;

      carry = (digits[j] / BASE) | 0;
      digits[j] %= BASE;
    }

    while (carry) {
      digits.push(carry % BASE);

      carry = (carry / BASE) | 0;
    }
  }

  const zeros = maxEncodedLen(buffer.length * 8) - digits.length;

  for (let i = 0; i < zeros; i++) digits.push(0);

  return (
    "V" +
    digits
      .reverse()
      .map(function(digit) {
        return ALPHABET[digit];
      })
      .join("")
  );
}

function vlxToEth(address_string) {
  if (address_string.length === 0) return null;
  string = address_string.replace("V", "");
  let bytes = [0];
  for (let i = 0; i < string.length; i++) {
    const c = string[i];
    if (!(c in ALPHABET_MAP)) throw new Error("Non-base58 character");

    for (let j = 0; j < bytes.length; j++) bytes[j] *= BASE;
    bytes[0] += ALPHABET_MAP[c];

    let carry = 0;
    for (let j = 0; j < bytes.length; ++j) {
      bytes[j] += carry;

      carry = bytes[j] >> 8;
      bytes[j] &= 0xff;
    }

    while (carry) {
      bytes.push(carry & 0xff);

      carry >>= 8;
    }
  }

  const zeros = 24 - bytes.length;

  for (let i = 0; i < zeros; i++) {
    bytes.push(0);
  }
  const buff = Buffer.from(bytes.reverse());
  const long_address = buff.toString("hex");

  if (long_address.length !== 48) {
    throw new Error("Invalid address");
  }
  const address = long_address.slice(0, 40);
  const address_checksum = long_address.slice(40, 48);

  if (!address || !address_checksum) {
    throw new Error("Invalid address");
  }

  const checksum = sha256(sha256(address)).substring(0, 8);

  if (address_checksum !== checksum) {
    throw new Error("Invalid checksum");
  }

  return "0x" + address;
}


module.exports.vlxToEth = vlxToEth;
module.exports.ethToVlx = ethToVlx;