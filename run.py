import uvicorn

if __name__ == "__main__":
    # 로컬 개발용: 127.0.0.1(루프백)만 바인딩해 외부 인터넷 노출 차단.
    # 원격 접근이 필요하면 인증/방화벽을 먼저 붙인 뒤 host 를 변경할 것.
    uvicorn.run("app.main:app", host="127.0.0.1", port=8000, reload=False)