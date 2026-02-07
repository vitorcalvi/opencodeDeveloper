from opencode_ai import Opencode

# Connect to the running server shown in your 'ps fax'
client = Opencode(base_url="http://brain:4000")

try:
    # 1. Create a session (takes no arguments in this SDK version)
    session = client.session.create()
    print(f"Started Session: {session.id}")

    # 2. Trigger the prompt with the specific model
    # The 'prompt' method takes the session ID and the prompt configuration
    response = client.session.prompt(
        session.id,
        prompt="What is the capital of France?",
        model="zai-coding-plan/glm-4.7"
    )

    # 3. Print the output
    # OpenCode responses usually contain a 'content' or 'text' field
    print("-" * 20)
    print(response.content)

except Exception as e:
    print(f"Error: {e}")
