import os
import base64
from dotenv import load_dotenv
from opencode_ai import Opencode

load_dotenv()

password = os.getenv("OPENCODE_SERVER_PASSWORD")
username = os.getenv("OPENCODE_SERVER_USERNAME", "opencode")
credentials = f"{username}:{password}"
encoded_credentials = base64.b64encode(credentials.encode()).decode("utf-8")

client = Opencode(
    base_url="http://brain:4000",
    default_headers={"Authorization": f"Basic {encoded_credentials}"}
)

try:
    # Create a new session
    session = client.session.create(extra_body={})
    print(f"Started Session: {session.id}")

    # Send the prompt
    response = client.session.chat(
        id=session.id,
        provider_id="zai-coding-plan",
        model_id="glm-4.7",
        parts=[
            {
                "type": "text",
                "text": "What is the capital of France?"
            }
        ]
    )

    # Extract the text answer from parts
    text_parts = [part for part in response.parts if part.get('type') == 'text']
    if text_parts:
        answer = text_parts[0].get('text', '')
        print(f"\nAnswer: {answer}")
    
    # Show token usage
    if response.info and 'tokens' in response.info:
        tokens = response.info['tokens']
        print(f"\nTokens - Input: {tokens['input']}, Output: {tokens['output']}, Reasoning: {tokens.get('reasoning', 0)}")
        print(f"Cost: ${response.info.get('cost', 0)}")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
