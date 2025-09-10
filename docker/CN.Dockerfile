FROM python:3.12-slim AS builder

# 安装编译依赖
RUN apt-get update && apt-get install -y \
        gcc \
        python3-dev \
        build-essential \
    && mkdir -p /build \
    && pip wheel -w /build tgcrypto

FROM python:3.12-slim

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=Asia/Shanghai

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -y tzdata

COPY --from=builder /build/*.whl /tmp/

# 安装 tgcrypto wheel 和 tg-signer
RUN pip install /tmp/*.whl \
    && pip install -U "tg-signer[tgcrypto]" \
    && pip install flask

WORKDIR /opt/tg-signer
COPY app.py /opt/tg-signer/

EXPOSE 8080
CMD ["python", "app.py"]
