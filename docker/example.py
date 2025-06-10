import httpx

path = "/path/to/file"

with httpx.Client() as client:
    with open(path, "rb") as file:
        response = client.post(
            "http://localhost:8080/scan/body",
            headers={
                "accept": "text/plain",
                "Content-Type": "application/octet-stream"
            },
            content=file.read()
        )
        
        print(response.status_code)
        print(response.text)
