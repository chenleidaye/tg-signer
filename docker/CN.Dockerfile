# =========================
# Builder 阶段：构建 tgcrypto wheel
# =========================
FROM python:3.12-slim AS builder

# 安装编译依赖
RUN apt-get update && apt-get install -y \
        gcc \
        python3-dev \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# 构建 tgcrypto wheel
RUN mkdir -p /build \
    && pip wheel -w /build tgcrypto

# =========================
# Final 镜像
# =========================
FROM python:3.12-slim

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=Asia/Shanghai

# 设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -y tzdata \
    && rm -rf /var/lib/apt/lists/*

# 拷贝 tgcrypto wheel 并安装
COPY --from=builder /build/*.whl /tmp/
RUN pip install --no-cache-dir /tmp/*.whl \
    && pip install --no-cache-dir tg-signer[tgcrypto] flask gunicorn

# 工作目录
WORKDIR /opt/tg-signer
COPY app.py /opt/tg-signer/

# 暴露端口
EXPOSE 8080

# Gunicorn 生产级启动，单 worker，防止 Zeabur 杀掉进程
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "1", "--timeout", "120", "--log-level", "info", "app:app"]
