FROM python:3.12-slim AS builder

# 安装编译依赖
RUN apt-get update && apt-get install -y \
        gcc \
        python3-dev \
        build-essential \
    && mkdir -p build \
    && pip wheel -w build tgcrypto

FROM python:3.12-slim

COPY --from=builder /build/*.whl /tmp/

# 安装 tgcrypto wheel 和 tg-signer
RUN pip install /tmp/*.whl \
    && pip install -U "tg-signer[tgcrypto]"

WORKDIR /opt/tg-signer
