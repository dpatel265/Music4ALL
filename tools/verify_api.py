import os
import json
import sys
import urllib.request
import urllib.parse
import ssl

def verify_api_key():
    """
    Verifies the Google API Key using standard library urllib.
    Patched to ignore SSL errors (common on some macOS Python envs).
    """
    api_key = os.environ.get("GOOGLE_API_KEY")
    
    if not api_key:
        print("❌ Error: GOOGLE_API_KEY not found in environment variables.")
        sys.exit(1)

    print(f"🔑 Verifying API Key: {api_key[:5]}...{api_key[-3:]}")

    base_url = "https://www.googleapis.com/youtube/v3/search"
    params = {
        "part": "snippet",
        "q": "Flutter Development",
        "maxResults": "1",
        "type": "video",
        "key": api_key
    }
    
    query_string = urllib.parse.urlencode(params)
    url = f"{base_url}?{query_string}"
    
    # Bypass SSL verification
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    try:
        with urllib.request.urlopen(url, context=ctx) as response:
            if response.status == 200:
                data = json.loads(response.read().decode())
                print("✅ API Key Verification Successful!")
                if "items" in data and len(data["items"]) > 0:
                    print(f"   Response: Found video '{data['items'][0]['snippet']['title']}'")
                else:
                    print("   Response: Valid key, but no results found.")
            else:
                print(f"❌ API Verification Failed (Status {response.status})")
                sys.exit(1)

    except urllib.error.HTTPError as e:
        print(f"❌ HTTP Error: {e.code} - {e.reason}")
        try:
             error_body = json.loads(e.read().decode())
             print(f"   Details: {error_body.get('error', {}).get('message', 'Unknown error')}")
        except:
            pass
        sys.exit(1)
    except Exception as e:
        print(f"❌ Connection Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    verify_api_key()
