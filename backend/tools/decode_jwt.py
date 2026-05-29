from jose import jwt
import os
import sys

secret = os.getenv("JWT_SECRET", "change-me-in-production")
if len(sys.argv) < 2:
    print("Usage: python decode_jwt.py <token>")
    sys.exit(1)

token = sys.argv[1]

decoded = jwt.decode(token, secret, algorithms=["HS256"])
print(decoded)