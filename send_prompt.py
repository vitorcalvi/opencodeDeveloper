import requests
import json
import sys

# Configuration
BASE_URL = "http://brain:4000"
MODEL = "zai-coding-plan/glm-4.7"
PROMPT = "What is the capital of France?"

def create_session():
    """Creates a new session to hold the conversation context."""
    url = f"{BASE_URL}/api/sessions"
    try:
        # Try creating a session with an empty body or specific config
        response = requests.post(url, json={})
        if response.status_code in [200, 201]:
            session_data = response.json()
            # Handle different response formats (id in root or nested)
            session_id = session_data.get("id") or session_data.get("session_id")
            print(f"✅ Session Created: {session_id}")
            return session_id
        else:
            print(f"⚠️ Failed to create session (Status {response.status_code}): {response.text}")
            return None
    except Exception as e:
        print(f"❌ Connection Error: {e}")
        return None

def send_message(session_id, prompt, model):
    """Sends a message to the active session."""
    # Common endpoints for OpenCode/Agent servers
    endpoints = [
        f"/api/sessions/{session_id}/prompt",   # OpenCode specific
        f"/api/sessions/{session_id}/message",  # Common alternative
        f"/api/sessions/{session_id}/run"       # Action based
    ]

    # Try standard payload structures
    payloads = [
        {"prompt": prompt, "model": model},
        {"message": prompt, "model": model},
        {"messages": [{"role": "user", "content": prompt}], "model": model} # OpenAI style
    ]

    for endpoint in endpoints:
        url = f"{BASE_URL}{endpoint}"
        for payload in payloads:
            try:
                # print(f"Trying {url} with payload keys: {list(payload.keys())}...") 
                response = requests.post(url, json=payload)
                
                if response.status_code == 200:
                    print(f"✅ Success on {endpoint}")
                    return response.json()
                elif "Malformed JSON" not in response.text:
                    # If error is NOT 'Malformed JSON', it might be a valid endpoint with wrong logic
                    # We continue to try others, but this is a hint.
                    pass
            except Exception:
                continue
    
    print("❌ Could not trigger a valid response from known endpoints.")
    return None

def main():
    print(f"Connecting to OpenCode at {BASE_URL}...")
    
    # 1. Attempt to create a session
    session_id = create_session()
    
    if not session_id:
        # Fallback: Try generic OpenAI completion endpoint if session creation failed
        print("⚠️ Session creation failed. Trying direct completion endpoint...")
        url = f"{BASE_URL}/api/chat/completions" # or /v1/chat/completions
        payload = {
            "model": MODEL,
            "messages": [{"role": "user", "content": PROMPT}]
        }
        try:
            res = requests.post(url, json=payload)
            if res.status_code == 200:
                print(res.json())
                return
        except:
            pass
        print("❌ Unable to connect to a valid session or endpoint.")
        return

    # 2. Send the prompt to the session
    response = send_message(session_id, PROMPT, MODEL)
    
    if response:
        # Print the answer cleanly
        content = response.get("content") or response.get("text") or response.get("message")
        print("\n🔎 Response:")
        print(content)
        # Dump full JSON for debugging if needed
        # print(json.dumps(response, indent=2))

if __name__ == "__main__":
    main()
