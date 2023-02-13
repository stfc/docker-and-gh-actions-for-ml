import uvicorn

if __name__ == "__main__":
    uvicorn.run("distilgpt2_api.api:app", reload=True)
