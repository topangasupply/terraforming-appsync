def hello_world(event, _):
    """Respond with world if greeting is hello."""
    if event["arguments"]["greeting"] == "hello":
        return {"response": "world"}
    else:
        return {"response": ""}
